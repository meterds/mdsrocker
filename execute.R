if (!requireNamespace("purrr", quietly = TRUE)) {
  install.packages("purrr", quiet = TRUE)
}


## shell scripts ----
purrr::pwalk(mdsrocker::rocker_installation, mdsrocker::create_shellscript)

## dockerfiles ----
purrr::pwalk(mdsrocker::rocker_dockerfiles, mdsrocker::create_dockerfile)

## github actions ----
mdsrocker::create_action_workflow(
  images = mdsrocker::rocker_dockerfiles$name,
  account = "cstepper"
)
