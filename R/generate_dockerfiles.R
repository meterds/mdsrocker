#*******************************************************************************
#
# generate dockerfiles
#
# Author:     christoph
# Date:       2022-02-07
#*******************************************************************************

# function ----

generate_dockerfile = function(
  name,
  from,
  tag = "4.1.2",
  script,
  save_as = fs::path("dockerfiles", glue::glue("{name}_{tag}.Dockerfile"))
) {

  name = checkmate::assert_choice(
    name,
    c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")
  )

  checkmate::assert_character(from, len = 1L)
  checkmate::assert_character(tag, len = 1L)

  checkmate::assert_file_exists(fs::path("scripts", script), access = "x")
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  # script content
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
  usethis::ui_done("Writing dockerfile {ui_path(save_as)}")
  invisible(TRUE)

}


# apply ----

# dockerfile_data
account = "cstepper" # "meterds"

dockerfile_data = tibble::tribble(
  ~name,            ~from,                                ~script,
  "r-aws-minimal",  "rocker/r-ver",                        "install-aws.sh",
  "r-aws-spatial",  glue::glue("{account}/r-aws-minimal"), "install-spatial.sh",
  "r-cicd-minimal", glue::glue("{account}/r-aws-minimal"), "install-cicd.sh",
  "r-cicd-spatial", glue::glue("{account}/r-aws-spatial"), "install-cicd.sh"
)

# execute
purrr::pwalk(dockerfile_data, generate_dockerfile)
