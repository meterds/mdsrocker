# read relevant information from DESCRIPTION ----
account = desc::desc_get_field("Config/Dockerhub/Account")
rversions = desc::desc_get_list("Config/Docker/Rversions")

# generate scripts ----

## shell scripts ----
purrr::pwalk(
  mdsrocker::mdsrocker_installation,
  mdsrocker::create_shellscript
)

## dockerfiles ----
for (rver in rversions) {
  purrr::pwalk(
    mdsrocker::mdsrocker_dockerfiles,
    mdsrocker::create_dockerfile,
    tag = rver
  )
}

# github actions workflow ----
mdsrocker::create_action_workflow_publish_docker_images(
  account = account,
  images = mdsrocker::mdsrocker_dockerfiles$image,
  rversions = rversions
)
