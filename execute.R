## shell scripts ----
purrr::pwalk(mdsrocker::mdsrocker_installation, mdsrocker::create_shellscript)

## dockerfiles ----
rversions = desc::desc_get_list("Config/Docker/Rversions")
for (rver in rversions) {
  purrr::pwalk(
    mdsrocker::mdsrocker_dockerfiles,
    mdsrocker::create_dockerfile,
    tag = rver)
}

## github actions ----
mdsrocker::create_action_workflow_publish_docker_images(
 account = desc::desc_get_field("Config/Dockerhub/Account"),
 images = mdsrocker::mdsrocker_dockerfiles$image,
 rversions = rversions
)
