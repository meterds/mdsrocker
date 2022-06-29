required = c("desc", "dplyr", "glue", "purrr", "tibble")

for (r in required) {
  if (!requireNamespace(r, quietly = TRUE)) {
    install.packages(r, quiet = TRUE)
  }
}

## shell scripts ----

pkgs = list(
  aws = c(
    "renv"
    , "units"
    , "xml2"
  )
  , cicd = c(
    "checkmate"
    , "covr"
    , "DT"
    , "lintr"
    , 'pkgdown'
    , 'renv'
    , 'rcmdcheck'
    , 'tinytest'
  )
  , spatial = c(
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

syslibs = list(
  aws = c("git", "jq", "libssl-dev", "libsasl2-dev"),
  cicd = NULL,
  spatial = NULL
)


# function arguments
mdsrocker_installation = list(
  pkgs = pkgs,
  syslibs = syslibs
) |>
  purrr::imap(~tibble::enframe(.x, name = "type", value = .y)) |>
  purrr::reduce(dplyr::inner_join, by = "type")

usethis::use_data(mdsrocker_installation, overwrite = TRUE)


## dockerfiles -----

account = desc::desc_get_field("Config/Dockerhub/Account")

mdsrocker_dockerfiles = tibble::tribble(
  ~image,           ~parent,                              ~script,               ~description,
  "r-aws-minimal",  "rocker/r-ver",                        "install_aws.sh",     "r-ver plus R packages `renv` & `units` and system libraries `git`, `jq`, `libssl-dev` & `libsasl2-dev`",
  "r-aws-spatial",  glue::glue("{account}/r-aws-minimal"), "install_spatial.sh", "r-aws-minimal plus a spatial libraries stack",
  "r-cicd-minimal", glue::glue("{account}/r-aws-minimal"), "install_cicd.sh",    "r-aws-minimal plus a set of CI/CD tools",
  "r-cicd-spatial", glue::glue("{account}/r-aws-spatial"), "install_cicd.sh",    "r-aws-spatial plus a set of CI/CD tools"
)

usethis::use_data(mdsrocker_dockerfiles, overwrite = TRUE)


# document ----
usethis::use_r("data")
