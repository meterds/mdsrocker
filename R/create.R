#' Create Shell Script with Installation Instructions
#'
#' Different shell scripts with installation instructions are required
#' for the various docker images.
#'
#' @param type type of software bundle to install, one of
#'   `c("aws", "cicd", "spatial")`
#' @param pkgs `character` vector of R packages to install
#' @param os definition of operating system; default to `"ubuntu-20.04"`.
#' @param syslibs `character` vector of system libraries to install
#'   (which are not found as dependency of the R `pkgs`).
#' @param save_as path for storing the installation instruction file; default
#'   to `fs::path("scripts", glue::glue("install-{type}.sh"))`.
#'
#' @return Logical indicating whether a write occurred, invisibly.
#'
#' @importFrom checkmate assert_character assert_choice assert_path_for_output
#' @importFrom cli cli_alert_success
#' @importFrom fs path
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom remotes package_deps system_requirements
#'
#' @export
create_shellscript = function(
  type,
  pkgs,
  os = "ubuntu-20.04",
  syslibs = NULL,
  save_as = fs::path("scripts", glue::glue("install_{type}.sh"))
) {

  type = checkmate::assert_choice(type, c("aws", "cicd", "spatial"))

  checkmate::assert_character(pkgs, min.len = 1L)
  checkmate::assert_character(os, len = 1L)
  checkmate::assert_character(syslibs, null.ok = TRUE)
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  ## find package dependencies
  repo = "https://packagemanager.rstudio.com/cran/latest"

  deps = pkgs |>
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
    purrr::map(~remotes::system_requirements(os = os, package = .x)) |>
    purrr::map(
      ~gsub(pattern = "apt-get install -y ", replacement = "", x = .x)
      )

  # split packages
  # - use binaries for those without any sysreq; install the others from source
  deps_has_sysreqs = lengths(sysreqs) == 0L
  pkgs_binary = deps[deps_has_sysreqs]
  pkgs_source = deps[!deps_has_sysreqs]

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

  # system requirements
  if (length(sysreqs) > 0) {
    sysreqs = c(
      "",
      "# install system requirements",
      "apt-get -qq update \\",
      "  && apt-get -y --no-install-recommends install \\",
      if (length(sysreqs) > 1) {
        paste0("  ", sysreqs[-length(sysreqs)], " \\")
      },
      paste0("  ", sysreqs[length(sysreqs)])
    )
  }

  # packages
  pkgs_binary = c(
    "",
    "# install binary R packages",
    "install2.r --error --skipinstalled -n $NCPUS \\",
    if (length(pkgs_binary) > 1) {
      paste0("  ", pkgs_binary[-length(pkgs_binary)], " \\")
    },
    paste0("  ", pkgs_binary[length(pkgs_binary)])
  )

  pkgs_source = c(
    "",
    "# install source R packages",
    glue::glue("install2.r --error --skipinstalled -n $NCPUS -r {repo} \\"),
    if (length(pkgs_source) > 1) {
      paste0("  ", pkgs_source[-length(pkgs_source)], " \\")
    },
    paste0("  ", pkgs_source[length(pkgs_source)])
  )

  if (type == "spatial") {
    extra = c(
      "",
      "# install whiteboxtools into defined directory",
      "r -e 'whitebox::install_whitebox(pkg_dir = Sys.getenv(\"R_WHITEBOX_EXE_PATH\"))'"
    )
  } else {
    extra = character()
  }


  # cleanup
  cleanup = c(
    "",
    "# clean up",
    "rm -rf /var/lib/apt/lists/*",
    "rm -r /tmp/downloaded_packages"
  )

  # combine all-together
  all_content = c(
    header, sysreqs, pkgs_binary, pkgs_source, extra, cleanup
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
        "env" = "ENV R_WHITEBOX_EXE_PATH=/usr/local/bin/whitebox_tools"
      },
      "copy" = glue::glue("COPY /scripts/{script} /rocker_scripts"),
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
    "  uses: docker/login-action@v1",
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
    "  uses: docker/build-push-action@v2",
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
          "      uses: styfle/cancel-workflow-action@0.9.1",
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
