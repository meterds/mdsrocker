#' Installation Instructions for Docker Builds
#'
#' A data set containing the the requirements to install in the docker builds.
#'
#' @format A `tibble` with *3* rows and *3* columns:
#' * _type_: type of software bundle to install, one of
#'   `c("aws", "cicd", "spatial")`,
#' * _syslibs_: additionally system libraries
#'   (not required by specified R packages),
#' * _extra_: additional software packages,
#' * _pypkgs_: Python packages to install,
#' * _rpkgs_: R packages to install in respective install scripts.
#'
#' @source METERGROUP
"mdsrocker_installation"


#' Dockerfile Specifications
#'
#' A data set containing the the specifications for different dockerfiles.
#'
#' @format A `tibble` with *4* rows and *4* columns:
#' * _image_: name of the docker image, one of
#'   `c("r-aws-minimal", "r-aws-spatial", "r-cicd-minimal", "r-cicd-spatial")`,
#' * _description_: description of software packed in the docker image,
#' * _parent_: parent docker image (incl. _dockerhub_ account)
#'   from which to build,
#' * _script_: name of installation shell script to be
#'   executed in `docker build` process.
#'
#' @source METERGROUP
"mdsrocker_dockerfiles"
