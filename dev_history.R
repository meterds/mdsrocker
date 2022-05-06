## 2022-05-04 ====


# NOTE:
# the update of the whitebox zipfile must be done regulary.
# I suggest each time we add a new R version to the DESCRIPTON,
# wie can run the download to keep track of changes.

# add whitebox binary exe zip file to package
# (we use this as fallback, if the download fails during
# `whitebox::install_whitebox()` in the Github Actions call)
fs::dir_create("inst/extdata")
to = getOption("timeout")
options(timeout = 3600)
utils::download.file(
  "https://www.whiteboxgeo.com/WBT_Linux/WhiteboxTools_linux_amd64.zip",
  destfile = "inst/extdata/WhiteboxTools_linux_amd64.zip"
)
options(timeout = to)


# evaluation of docker images
# (which are created with Github Actions and pushed to dockerhub)
edit_file("inst/documentation/install-whitebox.Rmd")




mdseasy::easy_version(element = "dev", check_renv = FALSE, push = FALSE)

## 2022-05-02 ====

# R 4.2.0
mdseasy::easy_version(element = "dev", check_renv = FALSE, push = FALSE)

# installation of whiteboxtools exe
# see https://github.com/giswqs/whiteboxR/issues/76
# seems that downloading the zip-file from whiteboxgeo.com fails regularly

## 2022-04-12 ====

# fix for installation of whiteboxtools
mdseasy::easy_version(element = "dev", check_renv = FALSE, push = FALSE)

## 2022-03-16 ====

# major overhaul
mdseasy::easy_version(element = "dev", check_renv = FALSE)

## 2022-02-07 ====

# put everything in an R package framework
mdseasy::create_mdspackage(".", tinytest = FALSE, pages = FALSE, open = FALSE)

# fill description
use_package("R", "Depends", min_version = "4.1")

# functions for file createion
usethis::use_r("create")

# use data for storing the content
usethis::use_data_raw(name = "datasets")
usethis::use_r("data")


# execute (for actually creating the files)
usethis::edit_file("execute.R")

## 2021-12-17 ====

# add README
usethis::use_readme_rmd()

# add dev_history.R
mdseasy::easy_dev_history()
usethis::use_build_ignore("dev_history.R")

# use README
usethis::use_readme_rmd()
devtools::build_readme()
