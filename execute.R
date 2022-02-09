## shell scripts ----
purrr::pwalk(mdsrocker::rocker_installation, mdsrocker::create_shellscript)

## dockerfiles ----
purrr::pwalk(mdsrocker::rocker_dockerfiles, mdsrocker::create_dockerfile)

## github actions ----
mdsrocker::create_action_workflow(
  images = mdsrocker::rocker_dockerfiles$image,
  account = desc::desc_get_field("Config/Dockerhub/Account")

)