## 2022-05-04 ====

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
