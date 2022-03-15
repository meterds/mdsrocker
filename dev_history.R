## 2022-03-14 ====

# use renv
mdseasy::renv_settings(settings = list(ignored.packages = ""))
mdseasy::renv_snapshot()

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
