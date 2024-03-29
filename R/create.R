#' Create Shell Script with Installation Instructions
#'
#' Different shell scripts with installation instructions are required
#' for the various docker images.
#'
#' @param type type of software bundle to install, one of
#'   `c("aws", "spatial", "cicd")`
#' @param rpkgs `character` vector of R packages to install
#' @param syslibs `character` vector of system libraries to install
#'   (which are not found as dependency of the `rpkgs`).
#' @param pypkgs `character` vector of Python packages to install
#' @param extra `character` vector of additional software packages to install
#' @param os definition of operating system;
#'   default to `tolower(system("lsb_release -si", intern = TRUE))`.
#' @param os_release definition of operating system release version;
#'   default to `system("lsb_release -sr", intern = TRUE)`.
#' @param save_as path for storing the installation instruction file; default
#'   to `fs::path("scripts", glue::glue("install-{type}.sh"))`.
#'
#' @return Logical indicating whether a write occurred, invisibly.
#'
#' @importFrom checkmate assert_character assert_choice assert_path_for_output
#' @importFrom cli cli_alert_success
#' @importFrom fs path
#' @importFrom glue glue
#' @importFrom purrr map reduce
#' @importFrom remotes package_deps system_requirements
#'
#' @export
create_shellscript = function(
    type,
    rpkgs,
    syslibs = NULL,
    pypkgs = NULL,
    extra = NULL,
    os = tolower(system("lsb_release -si", intern = TRUE)),
    os_release = system("lsb_release -sr", intern = TRUE),
    save_as = fs::path("scripts", glue::glue("install_{type}.sh"))
) {

  type = checkmate::assert_choice(type, c("aws", "spatial", "cicd"))

  checkmate::assert_character(rpkgs, min.len = 1L)
  checkmate::assert_character(syslibs, null.ok = TRUE)
  checkmate::assert_character(pypkgs, null.ok = TRUE)
  checkmate::assert_character(extra, null.ok = TRUE)
  checkmate::assert_character(os, len = 1L)
  checkmate::assert_character(os_release, len = 1L)
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  ## find R package dependencies
  repo = "https://packagemanager.posit.co/cran/latest"

  deps = rpkgs |>
    purrr::map(
      ~remotes::package_deps(
        packages = .x,
        repos = repo
      )$package
    ) |>
    unlist() |>
    unique()


  ## find system requirements
  sysreqs = deps |>
    purrr::set_names() |>
    purrr::map(
      ~remotes::system_requirements(
        os = os,
        # TODO:
        # change back as soon as CRAN version of `remotes` supports "22.04"
        # keep hard-coded "20.04" for the meanwhile
        # os_release = os_release,
        os_release = "20.04",
        package = .x
        )
    ) |>
    purrr::map(
      ~gsub(pattern = "apt-get install -y ", replacement = "", x = .x)
    )

  # split packages
  # - use binaries for those without any sysreq; install the others from source
  deps_has_sysreqs = lengths(sysreqs) == 0L
  rpkgs_binary = deps[deps_has_sysreqs]
  rpkgs_source = deps[!deps_has_sysreqs]

  # additional system libraries
  sysreqs = c(unlist(sysreqs), syslibs)

  sysreqs = sysreqs |>
    unique() |>
    sort()

  # script content
  header = c(
    "#!/bin/bash",
    "",
    "set -e",
    "",
    "# always set this for scripts but don't declare as ENV.",
    "export DEBIAN_FRONTEND=noninteractive",
    "",
    "# build ARGs",
    "NCPUS=${NCPUS:--1}"
  )

  ## add ubuntugis-unstable repo for spatial images
  if (type == "spatial") {
    header = c(
      header,
      "",
      "# re-install gpg-agent and software-properties-common",
      "# for Ubuntu-22.04 (as otherwise add-apt-repository fails)",
      "apt-get -qq update \\",
      "  && apt-get -y upgrade \\",
      "  && apt-get -y --no-install-recommends install \\",
      "  gpg-agent \\",
      "  software-properties-common",
      "",
      "# add ubuntugis-unstable repo to get latest versions of gdal & co.",
      "add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable"
    )
  }

  # system requirements
  if (length(sysreqs) > 0) {
    sysreqs = c(
      "",
      "# a function to install apt packages only if they are not installed",
      "function apt_install() {",
      '  if ! dpkg -s "$@" >/dev/null 2>&1; then',
      '  if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then',
      "  apt-get -qq update",
      "  fi",
      '  apt-get install -y --no-install-recommends "$@"',
      "  fi",
      "}",
      "",
      "# install system requirements",
      "apt_install \\",
      if (length(sysreqs) > 1) {
        paste0("  ", sysreqs[-length(sysreqs)], " \\")
      },
      paste0("  ", sysreqs[length(sysreqs)])
    )
  }

  # extra software packages required
  additional = character()

  if ("AWS CLI version 2" %in% extra) {
    additional = c(
      additional,
      "",
      "# install AWS CLI",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscli.zip'",
      "unzip -qq /tmp/awscli.zip -d /tmp",
      "./tmp/aws/install",
      "rm /tmp/awscli.zip",
      "rm -r /tmp/aws"
    )
  }

  if ("WhiteboxTools" %in% extra) {
    additional = c(
      additional,
      "",
      "# install whitebox executable",
      "WBT_ZIPFILE=/tmp/WhiteboxTools_linux_amd64.zip",
      "unzip $WBT_ZIPFILE -d /usr/local/bin",
      "rm $WBT_ZIPFILE"
    )
  }

  # Python packages (install via pip)
  if (length(pypkgs) > 0) {
    pypkgs = c(
      "",
      "# install Python packages",
      "python3 -m pip install --no-cache-dir --upgrade \\",
      "  pip",
      "python3 -m pip install --no-cache-dir \\",
      if (length(pypkgs) > 1) {
        paste0("  ", pypkgs[-length(pypkgs)], " \\")
      },
      paste0("  ", pypkgs[length(pypkgs)])
    )
  }

  # R packages update
  rpkgs_update = character()
  if (type == "aws") {
    rpkgs_update = c(
      rpkgs_update,
      "",
      "# update R packages",
      "R_LIBS_SITE=/usr/local/lib/R/site-library",
      "ln -s ${R_LIBS_SITE}/littler/examples/update.r /usr/local/bin/update.r",
      "update.r -n $NCPUS"
    )
  }

  # R packages (install via littler)
  rpkgs_binary = c(
    "",
    "# install binary R packages",
    "install2.r --error --skipinstalled -n $NCPUS \\",
    if (length(rpkgs_binary) > 1) {
      paste0("  ", rpkgs_binary[-length(rpkgs_binary)], " \\")
    },
    paste0("  ", rpkgs_binary[length(rpkgs_binary)])
  )

  rpkgs_source = c(
    "",
    "# install source R packages",
    glue::glue("install2.r --error --skipinstalled -n $NCPUS -r {repo} \\"),
    if (length(rpkgs_source) > 1) {
      paste0("  ", rpkgs_source[-length(rpkgs_source)], " \\")
    },
    paste0("  ", rpkgs_source[length(rpkgs_source)])
  )

  # cleanup
  cleanup = c(
    "",
    "# clean up",
    "rm -rf /var/lib/apt/lists/*",
    "rm -r /tmp/downloaded_packages",
    "",
    "## Strip binary installed lybraries from RSPM",
    "## https://github.com/rocker-org/rocker-versioned2/issues/340",
    "strip /usr/local/lib/R/site-library/*/libs/*.so"
  )

  # combine all-together
  all_content = c(
    header, sysreqs, additional, pypkgs, rpkgs_update, rpkgs_binary, rpkgs_source, cleanup
  )

  # write to file
  con = file(save_as)
  on.exit(close(con), add = TRUE)

  writeLines(all_content, con = con)

  # make executable
  system(glue::glue("chmod +x {save_as}"))

  # return
  cli::cli_alert_success(
    "Writing installation instructions to {.file {save_as}}"
  )
  invisible(TRUE)

}


#' Create Dockerfile
#'
#' Different dockerfiles are required for the various docker images.
#'
#' @details
#' We add some labels to the docker images, following the Open Container
#' Initiative (OCI). See the
#' [list of predefined annotation keys](https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys)
#' for more information.
#'
#' @param image name of docker image to create, one of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`,
#'   plus R version as `tag`.
#' @param parent `character` parent docker image (incl. *dockerhub* account)
#'   from which to build.
#' @param script `character` name of installation shell script to be
#'   executed in `docker build` process.
#' @param description content of docker image.
#' @param ... arguments passed on to internal helper functions
#'   (e.g. `verbose = TRUE`).
#' @param tag `character` tag for the docker image, default to the current
#'   R version; `as.character(getRversion())`.
#' @param labels named `list` with labels (see **Details**). If `NULL`,
#'   filled with predefined keys.
#' @param save_as path for storing the dockerfile; default
#'   to `fs::path("dockerfiles", glue::glue("{image}_{tag}.Dockerfile"))`.
#'
#' @return Logical indicating whether a write occurred, invisibly.
#'
#' @importFrom checkmate assert_character assert_choice
#' @importFrom checkmate assert_file_exists assert_path_for_output
#' @importFrom cli cli_alert_success
#' @importFrom fs path
#' @importFrom glue glue
#' @importFrom purrr discard flatten_chr imap map
#' @importFrom stringr str_remove
#'
#' @export
create_dockerfile = function(
    image,
    parent,
    script,
    description,
    ...,
    tag = as.character(getRversion()),
    labels = NULL,
    save_as = fs::path("dockerfiles", glue::glue("{image}_{tag}.Dockerfile"))
) {

  image = checkmate::assert_choice(
    image,
    c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")
  )

  checkmate::assert_character(description, len = 1L)
  checkmate::assert_character(parent, len = 1L)
  checkmate::assert_character(tag, len = 1L)

  checkmate::assert_file_exists(fs::path("scripts", script), access = "x")
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  # file content
  if (is.null(labels)) {
    labels = auto_labels(image, description, tag)
  }

  labels = labels |>
    purrr::imap(
      ~glue::glue('LABEL org.opencontainers.image.{.y}="{.x}"')
    )

  content =
    list(
      "from" = glue::glue("FROM {parent}:{tag}"),
      "labels" = purrr::flatten_chr(labels),
      # https://vsupalov.com/docker-arg-env-variable-guide/
      if (image == "r-aws-spatial") {
        "env" = "ENV R_WHITEBOX_EXE_PATH=/usr/local/bin/WBT/whitebox_tools"
      },
      "copy_sh" = glue::glue("COPY /scripts/{script} /rocker_scripts"),
      if (image %in% c("r-aws-spatial", "r-cicd-spatial")) {
        "copy_wbt" = glue::glue("COPY /inst/extdata/WhiteboxTools_linux_amd64.zip /tmp")
      },
      "run" = glue::glue("RUN /rocker_scripts/{script}"),
      "execute" = c("# default for executing container", "CMD /bin/bash")
    ) |>
    purrr::discard(is.null) |>
    purrr::map(~c(.x, ""))

  # combine all-together
  all_content = purrr::flatten_chr(content)

  # write to file
  con = file(save_as)
  on.exit(close(con), add = TRUE)

  writeLines(all_content, con = con)

  # return
  cli::cli_alert_success("Writing dockerfile {.file {save_as}}")
  invisible(TRUE)

}


#' Create Github Actions Workflow for Docker Image Publish
#'
#' A github actions workflow for building and pushing a stack of docker images.
#'
#' @param account `character` dockerhub account for pushing the images.
#' @param images names of docker images to create, subset of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`
#' @param rversions `character` vector of R versions; necessary for setting up
#'    the matrix for the Github Actions Workflow.
#' @param save_as path for storing the yml file; default
#'   to `fs::path(".github", "workflows", "publish-docker-images.yml")`.
#'
#' @return Logical indicating whether a write occurred, invisibly.
#'
#' @importFrom checkmate assert_character assert_subset
#' @importFrom checkmate assert_path_for_output
#' @importFrom cli cli_alert_success
#' @importFrom fs path
#' @importFrom glue glue
#' @importFrom purrr flatten_chr map map2
#' @importFrom rversions r_versions
#'
#' @export
create_action_workflow_publish_docker_images = function(
    account,
    images,
    rversions,
    save_as = fs::path(".github", "workflows", "publish-docker-images.yml")
) {

  checkmate::assert_character(account, len = 1L)
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  checkmate::assert_subset(
    images,
    choices = c(
      "r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial"
    )
  )

  images_array = paste(
    paste0("'", images, "'"),
    collapse = ", "
  )

  rversions = sort(rversions)
  rversion_latest = rversions[length(rversions)]
  # check supplied r versions
  rversions_fail = !rversions %in% rversions::r_versions()$version
  if (any(rversions_fail)) {
    rversions_fail = rversions[which(rversions_fail)]
    msg = sprintf(
      "Supplied R version(s) not found: %s",
      paste(rversions_fail, collapse = ", ")
    )
    stop(msg, call. = FALSE)
  }

  rversions_array = paste(
    paste0("'", rversions, "'"),
    collapse = ", "
  )


  # script content

  ## define steps
  docker_login = c(
    "-",
    "  name: Login to Docker Hub",
    "  uses: docker/login-action@v2",
    "  with:",
    "    username: ${{ secrets.DOCKERHUB_USERNAME }}",
    "    password: ${{ secrets.DOCKERHUB_PAT }}"
  )

  create_tags = c(
    "-",
    "  name: Create Tags for Docker image",
    "  uses: haya14busa/action-cond@v1",
    "  id: condtag",
    "  with:",
    glue::glue(
      "    cond: ${{ matrix.rversion == '<rversion_latest>' }}"
      , .open = "<", .close = ">"
    ),
    glue::glue(
      '    if_true: "<account>/${{ matrix.image }}:latest, <account>/${{ matrix.image }}:${{ matrix.rversion }}"'
      , .open = "<", .close = ">"
    ),
    glue::glue(
      '    if_false: "<account>/${{ matrix.image }}:${{ matrix.rversion }}"'
      , .open = "<", .close = ">"
    )
  )

  build_push = c(
    "-",
    "  name: Build and push Docker image",
    "  uses: docker/build-push-action@v3",
    "  with:",
    '    file: dockerfiles/${{ matrix.image }}_${{ matrix.rversion }}.Dockerfile',
    '    push: true',
    '    tags: ${{ steps.condtag.outputs.value }}'
  )

  steps = c(
    list(
      docker_login,
      create_tags,
      build_push
    )
  )

  steps = paste0("    ", unlist(steps))

  content =
    list(
      "name" = "name: Publish Docker Images",
      "on" = c(
        "on:",
        "  schedule:",
        '    - cron: "30 5 * * SUN"',
        "  workflow_run:",
        "    workflows:",
        '      - "Update Building System"',
        "    types:",
        "      - completed",
        "    branches:",
        "      - main",
        # "  push:",
        # "    branches:",
        # "      - main",
        # "    paths:",
        # "      - 'scripts/**'",
        # "      - 'dockerfiles/**'",
        # "      - '.github/workflows/publish-docker-images.yml'",
        "  workflow_dispatch:"
      ),
      "jobs" = unlist(
        c(
          "jobs:",
          "",
          "  cancel_previous_runs:",
          "    runs-on: ubuntu-latest",
          "    steps:",
          "    -",
          "      name: Cancel Previous Runs",
          "      uses: styfle/cancel-workflow-action@0.11.0",
          "      with:",
          "        access_token: ${{ secrets.GITHUB_TOKEN }}",
          purrr::map(
            rversions,
            push_to_registry,
            images_array = images_array,
            steps = steps
          )
        )
      )
    ) |>
    purrr::map(~c(.x, ""))

  # combine all-together
  all_content = purrr::flatten_chr(content)

  # write to file
  con = file(save_as)
  on.exit(close(con), add = TRUE)

  writeLines(all_content, con = con)

  # return
  cli::cli_alert_success("Writing github action workflow {.file {save_as}}")
  invisible(TRUE)

}

# helpers ----------------------------------------------------------------------

#' @importFrom glue glue
#' @importFrom stringr str_replace_all

push_to_registry = function(rver, images_array, steps){
  r_ver = stringr::str_replace_all(rver, "\\.", "_")
  c(
    "",
    glue::glue("  push_to_registry-R_{r_ver}:"),
    "    needs: cancel_previous_runs",
    "    runs-on: ubuntu-latest",
    "    strategy:",
    "      fail-fast: true",
    "      max-parallel: 1",
    "      matrix:",
    glue::glue("        rversion: ['{rver}']"),
    glue::glue("        image: [{images_array}]"),
    "    name: ${{ matrix.image }} - ${{ matrix.rversion }}",
    "    steps:",
    steps
  )
}


#' @importFrom cli cli_alert_info
#' @importFrom desc desc_get_field desc_get_maintainer
#' @importFrom gert git_info git_remote_info
#' @importFrom purrr safely
#' @importFrom stringr str_detect str_remove str_replace

auto_labels = function(image, description, tag, verbose = TRUE) {

  # retrieve remote repo url
  safe_git_remote_info = purrr::safely(gert::git_remote_info)
  remote_info = safe_git_remote_info()

  if (is.null(remote_info$error)) {
    source = remote_info$result$url
    cli::cli_alert_info("Found repository remote URL: {.url {source}}")
  } else {
    source = "https://github.com/meterds/mdsrocker.git"
    cli::cli_alert_warning(
      "Cannot reach git remote, use fallback for remote URL: {.url {source}}"
    )
  }

  source = source |>
    stringr::str_remove(pattern = "\\.git$")

  if (stringr::str_detect(source, pattern = "^git@")) {
    source = source |>
      stringr::str_replace(pattern = ":", replacement = "/") |>
      stringr::str_replace(pattern = "^git@", replacement = "https://")
  }

  list(
    authors = desc::desc_get_maintainer(),
    base.name = "docker.io/library/ubuntu:focal",
    description = description,
    licenses = desc::desc_get_field("License"),
    revision = gert::git_info()$commit,
    source = source,
    title = image,
    vendor = readLines("LICENSE.md", n = 3)[3] |>
      stringr::str_remove(
        pattern = "Copyright\\s\\(c\\)\\s[:digit:]{4}\\s"
      ),
    version = tag
  )
}
