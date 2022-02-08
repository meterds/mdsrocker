#' Installation Instructions for Docker Builds
#'
#' A data set containing the the requirements to install in the docker builds.
#'
#' @format A `tibble` with *3* rows and *3* columns:
#' * _type_: type of software bundle to install, one of
#'   `c("aws", "cicd", "spatial")`,
#' * _pkgs_: R pacakges to install in respective install scripts,
#' * _syslibs_: additionally system libraries
#'   (not required by specified R packages).
#'
#' @source METERGROUP
"rocker_installation"


#' Dockerfile Specifications
#'
#' A data set containing the the specifications for different dockerfiles.
#'
#' @format A `tibble` with *4* rows and *3* columns:
#' * _name_: name of the docker repository, one of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`,
#' * _from_: docker image (without `tag`) to use as basis,
#' * _script_: name of installation shell script to be
#'   executed in `docker build` process.
#'
#' @source METERGROUP
"rocker_dockerfiles"
