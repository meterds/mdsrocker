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
rocker_installation =
  list(pkgs = pkgs, syslibs = syslibs) |>
  purrr::imap(~tibble::enframe(.x, name = "type", value = .y)) |>
  purrr::reduce(dplyr::inner_join, by = "type")

usethis::use_data(rocker_installation, overwrite = TRUE)


## dockerfiles -----

account = desc::desc_get_field("Config/Dockerhub/Account")

rocker_dockerfiles = tibble::tribble(
  ~image,           ~from,                                ~script,
  "r-aws-minimal",  "rocker/r-ver",                        "install-aws.sh",
  "r-aws-spatial",  glue::glue("{account}/r-aws-minimal"), "install-spatial.sh",
  "r-cicd-minimal", glue::glue("{account}/r-aws-minimal"), "install-cicd.sh",
  "r-cicd-spatial", glue::glue("{account}/r-aws-spatial"), "install-cicd.sh"
)

usethis::use_data(rocker_dockerfiles, overwrite = TRUE)
