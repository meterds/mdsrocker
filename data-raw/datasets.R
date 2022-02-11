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
    , "xml2"
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
  aws = c("jq"),
  cicd = NULL,
  spatial = NULL
)


# function arguments
mdsrocker_installation =
  list(pkgs = pkgs, syslibs = syslibs) |>
  purrr::imap(~tibble::enframe(.x, name = "type", value = .y)) |>
  purrr::reduce(dplyr::inner_join, by = "type")

usethis::use_data(mdsrocker_installation, overwrite = TRUE)


## dockerfiles -----

account = desc::desc_get_field("Config/Dockerhub/Account")

mdsrocker_dockerfiles = tibble::tribble(
  ~image,           ~description,                                                     ~parent,                              ~script,
  "r-aws-minimal",  "r-ver plus R packages `renv` & `units` and system library `jq`", "rocker/r-ver",                        "install_aws.sh",
  "r-aws-spatial",  "r-aws-minimal plus a spatial libraries stack",                   glue::glue("{account}/r-aws-minimal"), "install_spatial.sh",
  "r-cicd-minimal", "r-aws-minimal plus a set of CI/CD tools",                        glue::glue("{account}/r-aws-minimal"), "install_cicd.sh",
  "r-cicd-spatial", "r-aws-spatial plus a set of CI/CD tools",                        glue::glue("{account}/r-aws-spatial"), "install_cicd.sh"
)

usethis::use_data(mdsrocker_dockerfiles, overwrite = TRUE)
