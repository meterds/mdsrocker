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
#'   (which are not found as dependency of the R `pkgs`.
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
  save_as = fs::path("scripts", glue::glue("install-{type}.sh"))
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
    "## build ARGs",
    "NCPUS=${NCPUS:--1}"
  )

  # system requirements
  if (length(sysreqs) > 0) {
    sysreqs = c(
      "",
      "#install system requirements",
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
    "#install binary R packages",
    "install2.r --error --skipinstalled -n $NCPUS \\",
    if (length(pkgs_binary) > 1) {
      paste0("  ", pkgs_binary[-length(pkgs_binary)], " \\")
    },
    paste0("  ", pkgs_binary[length(pkgs_binary)])
  )

  pkgs_source = c(
    "",
    "#install source R packages",
    glue::glue("install2.r --error --skipinstalled -n $NCPUS -r {repo} \\"),
    if (length(pkgs_source) > 1) {
      paste0("  ", pkgs_source[-length(pkgs_source)], " \\")
    },
    paste0("  ", pkgs_source[length(pkgs_source)])
  )

  if (type == "spatial") {
    extra = c(
      "",
      "#install whiteboxtools",
      "r -e 'whitebox::install_whitebox'"
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
#' @param image name of docker image to create, one of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`,
#'   plus R version as `tag`.
#' @param from `character` docker image (incl. *dockerhub* account)
#'   to use as basis.
#' @param tag `character` tag for the docker image, default to the current
#'   R version; `as.character(getRversion())`.
#' @param script `character` name of installation shell script to be
#'   executed in `docker build` process.
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
#' @importFrom purrr flatten_chr map
#'
#' @export
create_dockerfile = function(
  image,
  from,
  tag = as.character(getRversion()),
  script,
  save_as = fs::path("dockerfiles", glue::glue("{image}_{tag}.Dockerfile"))
) {

  image = checkmate::assert_choice(
    image,
      c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")
  )

  checkmate::assert_character(from, len = 1L)
  checkmate::assert_character(tag, len = 1L)

  checkmate::assert_file_exists(fs::path("scripts", script), access = "x")
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  # file content
  content =
    list(
      "from" = glue::glue("FROM {from}:{tag}"),
      "copy" = glue::glue("COPY /scripts/{script} /rocker_scripts"),
      "run" = glue::glue("RUN /rocker_scripts/{script}"),
      "execute" = c("# default for executing container", "CMD /bin/bash")
    ) |>
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
#' @param images names of docker images to create, subset of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`
#' @param tag `character` tag for the docker image, default to the current
#'   R version; `as.character(getRversion())`.
#' @param account `character` dockerhub account for pushing the images.
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
#'
#' @export
create_action_workflow = function(
  images,
  tag = as.character(getRversion()),
  account,
  save_as = fs::path(".github", "workflows", "publish-docker-images.yml")
) {

  checkmate::assert_subset(
    images,
    choices = c(
      "r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial"
    )
  )
  checkmate::assert_character(tag, len = 1L)
  checkmate::assert_character(account, len = 1L)
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  # script content

  ## define steps
  checkout_repo = c(
    "-",
    "  name: Check out the repo",
    "  uses: actions/checkout@v2"
  )

  docker_login = c(
    "-",
    "  name: Login to Docker Hub",
    "  uses: docker/login-action@v1",
    "  with:",
    "    username: ${{ secrets.DOCKERHUB_USERNAME }}",
    "    password: ${{ secrets.DOCKERHUB_PAT }}"
  )

  build_and_push = function(index, image, tag, account){
    c(
      "-",
      glue::glue("  name: Build and push Docker image {index}/4 -> {image}"),
      "  uses: docker/build-push-action@v2",
      "  with:",
      "    context: .",
      glue::glue("    file: dockerfiles/{image}_{tag}.Dockerfile"),
      "    push: true",
      glue::glue("    tags: {account}/{image}:{tag}")
    )
  }

  steps = c(
    list(
      checkout_repo,
      docker_login
    ),
    purrr::map2(
      seq_along(images), images,
      build_and_push,
      tag = tag,
      account = account
    )
  )

  steps = paste0("    ", unlist(steps))

  content =
    list(
      "name" = "name: Publish Docker Images",
      "on" = c("on:",
               "  schedule:", '    - cron: "30 5 * * SUN"',
               "  workflow_dispatch:"
      ),
      "jobs" = c("jobs:",
                 "  push_to_registry:", "    runs-on: ubuntu-latest",
                 "    steps:",
                 steps
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
