# mdsrocker 1.1.7 (2022-03-17)

#### ✨ features and improvements

  * `create_action_workflow_publish_docker_images` now creates different
    job matrices for each R version (in order to run in parallel).


# mdsrocker 1.1.5 (2022-03-16)

#### 🐛 bug fixes

  * update TOKEN settings for *Cancel previous runs* step in
    `update-building-system.yml`


# mdsrocker 1.1.0 (2022-03-16)

#### ✨ features and improvements

  * update `DESCRIPTION` and create functions to handle multiple R versions
    (necessary for new R version *4.1.3*, released on 2022-03-10).
    + all desired R version can be noted in the `DESCRIPTION` field
      `Config/Docker/Rversions`.
  * add workflow `update-building-system.yml`:
    + runs the `execute.R` script to update all relevant scripts/files
      (shell scripts, dockerfiles, publish-docker-images.yml)
    + automatically commit changes to repo
    + trigger `Publish Docker Images` workflow
  * `create_action_workflow_publish_docker_images`:
    + now with *matrix* strategy for *Docker images* x *R versions*
    + conditional handling of *tags*

#### 🐛 bug fixes

  * `auto_label`: correct handling of `url` (depending on used git protocol
    `ssh` or `https`).


# mdsrocker 1.0.1 (2022-02-14)

#### ✨ features and improvements

  * add `git` to *r-aws-minimal* image (necessary for use in `renv::restore`
    when installing METER R-packages from Gitlab).


# mdsrocker 1.0.0 (2022-02-11)

#### ✨ features and improvements

  * add package infrastructure incl:
    - package data containing all the information regarding installation logic
      (`rocker_installation`) and docker files (`rocker_dockerfiles`),
    - functions to create shell scripts with install logic
      (`create_shellscript`), dockerfiles (`create_dockerfile`) and
      Github Actions workflow (`create_github_workflow`)
    - `execute.R` script, which can be called to create/update the various
      files.

#### 💬 documentation etc

  * Add content to `README.Rmd`

#### 🍬 miscellaneous

  * Add a `NEWS.md` file to track changes to the package.
