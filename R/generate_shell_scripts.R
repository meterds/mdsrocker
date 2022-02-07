#*******************************************************************************
#
# generate shell scripts for docker image creation
#
# Author:     christoph
# Date:       2022-02-07
#*******************************************************************************

# function ----

generate_shell_script = function(
  type,
  pkgs,
  os = "ubuntu-20.04",
  additional_sysreqs = NULL,
  save_as = fs::path("scripts", glue::glue("install-{type}.sh")),
  open = FALSE
) {

  type = checkmate::assert_choice(type, c("aws", "cicd", "spatial"))

  checkmate::assert_character(pkgs, min.len = 1L)
  checkmate::assert_character(os, len = 1L)
  checkmate::assert_character(additional_sysreqs, null.ok = TRUE)
  checkmate::assert_path_for_output(save_as, overwrite = TRUE)

  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  ## find system requirements
  sysreqs = Map(
    \(pkg) remotes::system_requirements(os = os, package = pkg),
    pkgs
  )

  sysreqs = sysreqs |>
    lapply(
      gsub, pattern = "apt-get install -y ", replacement = ""
    )

  sysreqs = sysreqs |>
    unlist()

  # additional system requirements
  sysreqs = c(sysreqs, additional_sysreqs)

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
  pkgs = c(
    "",
    "#install R packages",
    if (type == "spatial") {
    "install2.r --error --skipinstalled -n $NCPUS -r https://cran.rstudio.com \\"
    } else {
    "install2.r --error --skipinstalled -n $NCPUS \\"
    },
    if (length(pkgs) > 1) {
      paste0("  ", pkgs[-length(pkgs)], " \\")
    },
    paste0("  ", pkgs[length(pkgs)])
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
    header, sysreqs, pkgs, extra, cleanup
  )


  # write to file
  con = file(save_as)
  on.exit(close(con), add = TRUE)

  writeLines(all_content, con = con)
  usethis::ui_done("Writing installation instructions to {ui_path(save_as)}")

  if (open) {
    usethis::edit_file(fs::path(save_as))
  }

  invisible(TRUE)

}


# apply ----

# packages
pkgs = list(
  "aws" = c("renv")
  , "cicd" = c(
    "checkmate"
    , "covr"
    , "DT"
    , "lintr"
    , 'pkgdown'
    , 'renv'
    , 'rcmdcheck'
    , 'tinytest'
    , "xml2"
  )
  , "spatial" = c(
    "elevatr"
    , "gdalcubes"
    , "lwgeom"
    , "mapview"
    , "ncdf4"
    , "openeo"
    , "raster"
    , "rgdal"
    , "rstac"
    , "s2"
    , "satellite"
    , "sf"
    , "sp"
    , "stars"
    , "starsExtra"
    , "terra"
    , "units"
    , "whitebox"
  )
)

# function arguments
script_data = pkgs |>
  tibble::enframe(name = "type", value = "pkgs") |>
  dplyr::mutate(additional_sysreqs = dplyr::case_when(
    type == "aws" ~ list(c("jq"))
  )
  )

# execute
purrr::pwalk(script_data, generate_shell_script)
