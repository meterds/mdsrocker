required = c("desc", "dplyr", "glue", "purrr", "tibble")

for (r in required) {
  if (!requireNamespace(r, quietly = TRUE)) {
    install.packages(r, quiet = TRUE)
  }
}

## shell scripts ----

syslibs = list(
  aws = c(
    "apt-utils"
    , "curl"
    , "git"
    , "jq"
    , "libbz2-dev"
    , "libpng-dev"
    , "libssl-dev"
    , "libsasl2-dev"
    , "libsodium-dev"
    , "python3-dev"
    , "python3-pip"
    , "python3-venv"
    , "software-properties-common"
  )
  , spatial = NULL
  , cicd = NULL
)

extra = list(
  aws = c("AWS CLI version 2")
  , cicd = NULL
  , spatial = c("WhiteboxTools")
)

pypkgs = list(
  aws = c("pipreqs", "poetry", "requests")
  , cicd = NULL
  , spatial = NULL
)

rpkgs = list(
  aws = c(
    "arrow"
    , "checkmate"
    , "curl"
    , "dplyr"
    , "paws"
    , "plumber"
    , "renv"
    , "reticulate"
    , "targets"
    , "tarchetypes"
    , "units"
    , "xml2"
    , "zoo"
  )
  , spatial = c(
    "elevatr"
    , "gdalcubes"
    , "lwgeom"
    , "mapview"
    , "ncdf4"
    , "openeo"
    , "raster"
    # , "rgdal"
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
  , cicd = c(
    "covr"
    , "DT"
    , "lintr"
    , 'pkgdown'
    , 'rcmdcheck'
    , 'tinytest'
  )
)

# function arguments
mdsrocker_installation = list(
  syslibs = syslibs
  , extra = extra
  , pypkgs = pypkgs
  , rpkgs = rpkgs
) |>
  purrr::imap(~tibble::enframe(.x, name = "type", value = .y)) |>
  purrr::reduce(dplyr::inner_join, by = "type")

usethis::use_data(mdsrocker_installation, overwrite = TRUE)


## dockerfiles -----

account = desc::desc_get_field("Config/Dockerhub/Account")

mdsrocker_dockerfiles = tibble::tribble(
    ~image,           ~parent,                               ~script,               ~description,
  "r-aws-minimal",  "rocker/r-ver",                         "install_aws.sh",     "r-ver plus basic utilities stack including API tools",
  "r-aws-spatial",  glue::glue("{account}/r-aws-minimal"),  "install_spatial.sh", "r-aws-minimal plus a spatial libraries stack",
  "r-cicd-minimal", glue::glue("{account}/r-aws-minimal"),  "install_cicd.sh",    "r-aws-minimal plus a set of CI/CD tools",
  "r-cicd-spatial", glue::glue("{account}/r-aws-spatial"),  "install_cicd.sh",    "r-aws-spatial plus a set of CI/CD tools"
)

usethis::use_data(mdsrocker_dockerfiles, overwrite = TRUE)


# document ----
usethis::use_r("data")
