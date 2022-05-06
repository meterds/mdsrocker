# mdsrocker 1.2.2.9000 (2022-05-04)

#### ✨ features and improvements

  * add fix for failed downloads of *whitebox executable*, 
    see [this github issue](https://github.com/giswqs/whiteboxR/issues/76).
    Current Solution: 
    + manual download and intergration of zipfile into package
    + COPY zip during docker build
    + add unzip part into `install_spatial.sh`
    

#### 🐛 bug fixes

#### 💬 documentation etc

#### 🍬 miscellaneous



  * add fix for failed downloads of whitebox executable, see [this github issue](https://github.com/giswqs/whiteboxR/issues/76)


# mdsrocker 1.2.2 (2022-05-03)

#### ✨ features and improvements

  * update for *R 4.2.0*


# mdsrocker 1.2.1 (2022-04-12)

#### 🐛 bug fixes

  * `create_dockerfile`: define System Environment Variable
    `R_WHITEBOX_EXE_PATH=/usr/local/bin/WBT/whitebox_tools` in *r-aws-spatial*
    image docker files (which is also accessible by containers started from
    final image, so that `whitebox::wbt_init` should find the installed
    executable). See https://vsupalov.com/docker-arg-env-variable-guide/ for
    more info.
  * `create_shellscript`: make use of the *env var* when installing
    the *whiteboxtools* during *docker build*
    (`whitebox::install_whitebox(pkg_dir = "/usr/local/bin")`)


# mdsrocker 1.1.11 (2022-03-17)

#### ✨ features and improvements

  * `create_action_workflow_publish_docker_images`
    + creates different job matrices for each R version
      (in order to run in parallel).
    + is triggered by completed workflow run of `Update Building System`
    + has a job to cancel all "uncompleted" previous workflow runs


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
