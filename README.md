
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mdsrocker

<!-- badges: start -->

[![Docker Image
CI](https://github.com/meterds/mdsrocker/actions/workflows/publish-docker-images.yml/badge.svg)](https://github.com/meterds/mdsrocker/actions/workflows/publish-docker-images.yml)
<!-- badges: end -->

The goal of *mdsrocker* is to provide a framework for building a stack
of version-stable docker images based on
[rocker/r-ver](https://hub.docker.com/r/rocker/r-ver), an *ubuntu*-based
docker image containing version-stable *base R* & a set of src build
tools.

We follow the *version tag* approach of the *rocker*-project, using the
image tag for specifying which version of R is desired
(e.g. `rocker/r-ver: 4.1.3`). Omit the tag or specify `:latest` to
always receive the latest versions.

## Image stack

<table>
<thead>
<tr>
<th style="text-align:left;">
image
</th>
<th style="text-align:left;">
description
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
<a href="https://hub.docker.com/r/meterds/r-aws-minimal" style="     " >r-aws-minimal</a>
</td>
<td style="text-align:left;">
r-ver plus R packages `renv` & `units` and system libraries `git` & `jq`
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://hub.docker.com/r/meterds/r-aws-spatial" style="     " >r-aws-spatial</a>
</td>
<td style="text-align:left;">
r-aws-minimal plus a spatial libraries stack
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://hub.docker.com/r/meterds/r-cicd-minimal" style="     " >r-cicd-minimal</a>
</td>
<td style="text-align:left;">
r-aws-minimal plus a set of CI/CD tools
</td>
</tr>
<tr>
<td style="text-align:left;">
<a href="https://hub.docker.com/r/meterds/r-cicd-spatial" style="     " >r-cicd-spatial</a>
</td>
<td style="text-align:left;">
r-aws-spatial plus a set of CI/CD tools
</td>
</tr>
</tbody>
</table>

## Architecture

This building system is designed as an R package.

### Data

All relevant information is stored in *two* `data.frames` (as package
data):

-   `mdsrocker_installation`: *three* different software bundles for the
    various scopes of the docker images, each containing a list of R
    packages and system libraries (not required by the R packages) to
    install.

<table>
<thead>
<tr>
<th style="text-align:left;">
type
</th>
<th style="text-align:left;">
pkgs
</th>
<th style="text-align:left;">
syslibs
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
aws
</td>
<td style="text-align:left;">
renv , units
</td>
<td style="text-align:left;">
git, jq
</td>
</tr>
<tr>
<td style="text-align:left;">
cicd
</td>
<td style="text-align:left;">
checkmate, covr , DT , lintr , pkgdown , renv , rcmdcheck, tinytest ,
xml2
</td>
<td style="text-align:left;">
NULL
</td>
</tr>
<tr>
<td style="text-align:left;">
spatial
</td>
<td style="text-align:left;">
elevatr , gdalcubes , lwgeom , mapview , ncdf4 , openeo , raster , rgdal
, rstac , s2 , satellite , sf , sp , stars , starsExtra, terra , units ,
whitebox
</td>
<td style="text-align:left;">
NULL
</td>
</tr>
</tbody>
</table>

-   `mdsrocker_dockerfiles`: *four* dockerfile specifications, each
    containing the relevant information for generating the dockerfiles.

<table>
<thead>
<tr>
<th style="text-align:left;">
image
</th>
<th style="text-align:left;">
parent
</th>
<th style="text-align:left;">
script
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
r-aws-minimal
</td>
<td style="text-align:left;">
rocker/r-ver
</td>
<td style="text-align:left;">
install_aws.sh
</td>
</tr>
<tr>
<td style="text-align:left;">
r-aws-spatial
</td>
<td style="text-align:left;">
meterds/r-aws-minimal
</td>
<td style="text-align:left;">
install_spatial.sh
</td>
</tr>
<tr>
<td style="text-align:left;">
r-cicd-minimal
</td>
<td style="text-align:left;">
meterds/r-aws-minimal
</td>
<td style="text-align:left;">
install_cicd.sh
</td>
</tr>
<tr>
<td style="text-align:left;">
r-cicd-spatial
</td>
<td style="text-align:left;">
meterds/r-aws-spatial
</td>
<td style="text-align:left;">
install_cicd.sh
</td>
</tr>
</tbody>
</table>

### Scripts & Files

In this building system,

-   standalone shell scripts containing all the install logic are
    located under the `scripts/` directory,
-   dockerfiles used in the Github Actions workflow to build the images
    are located under `dockerfiles/`, and
-   two github actions workflows are stored under `.github/workflows/`:
    -   `update-building-system.yml`: re-builds all scripts if any
        changes were done in the repository (e.g. adding an R version to
        the `DESCRIPTION` file or adding some R packages to the software
        bundles),
    -   `publish-docker-images.yml`: actually builds and pushes the
        defined image stack.

### Updating

All scripts are automatically updated in the Github Actions Workflow
`update-building-system.yml` (by running `execute.R`) when commited and
pushed.

For adding changes (e.g. additional R packages), do:

1.  *git pull* the latest changes in the remote repository,
2.  *run*:
    -   `mdseasy::easy_version(element = "dev", check_renv = FALSE, push = FALSE)`
3.  *update* and *run* the code generating the package data in
    `data-raw/datasets.R`,
4.  *run*:
    -   `devtools::document()`
    -   `devtools::check()`
5.  *update* `NEWS.md`
6.  *run*
    -   `gert::git_commit_all("YOUR COMMIT MESSAGE")`
    -   `mdseasy::easy_version()`

# Execution

The Github Actions workflow `publish-docker-images.yml` is:

-   triggered by pushed changes to the workflow itself (usually applied
    via the `update-building-system.yml` workflow),
-   scheduled to run every Sunday,
-   or can be started manually on Github.
