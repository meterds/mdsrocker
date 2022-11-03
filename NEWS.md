# mdsrocker 1.3.2.9000 (2022-11-03)

#### ✨ features and improvements

#### 🐛 bug fixes

#### 💬 documentation etc

#### 🍬 miscellaneous


# mdsrocker 1.3.2 (2022-09-12)

#### ✨ features and improvements

  * add `curl` and `reticulate` to `r-aws-minimal` image in order to be able
    to `renv::restore()` during `docker build` using this image (without
    adding all the required system libraries by hand in each project)


# mdsrocker 1.3.1 (2022-09-08)

#### ✨ features and improvements

  * modify image setup to be ready for use with *Python* - PART 2 (#12)
    + *unset* environment variable `RETICULATE_PYTHON` again
    + install `libbz2-dev python3-dev python3-venv` as system libraries
  * remove `vapour` package from *spatial* package list, as archived on CRAN
    as of 2022-09-08


# mdsrocker 1.3.0 (2022-09-01)

#### ✨ features and improvements

  * modify image setup to be ready for use with *Python* (#12)
    + set environment variable `RETICULATE_PYTHON=/usr/bin/python3`
    + install `python3-pip` as system library
    + add `pypkgs` to `mdsrocker_installation`: possibility to add Python
      packages to docker images
    + install *python* package `pipreqs` for all `aws`-base images
  * do not include *WhiteboxTools* to non-spatial images

#### 🐛 bug fixes

  * *gitlab-actions*:
    + *Publish Docker Images* action trigger modified, so that it only is
      triggered by the *Update Building System* when it successfully ran
      on the *main* branch.
    + updated some *actions* versions.


# mdsrocker 1.2.9 (2022-08-11)

#### ✨ features and improvements

  * add `software-properties-common` to all images (#10)
  * add `ubuntu-unstable` repo to sources for spatial images (#10)


# mdsrocker 1.2.8 (2022-07-12)

#### ✨ features and improvements

  * ensure system libs are updated & upgraded on image build (#8)


# mdsrocker 1.2.7 (2022-07-04)

#### ✨ features and improvements

  * add `curl` to list of system libraries in `r-aws-minimal`
  * add AWS CLI to `r-aws-minimal` (#6)


# mdsrocker 1.2.6 (2022-06-29)

#### ✨ features and improvements

  * add `libssl-dev` and `libsasl2-dev` to default syslibs for r-aws-minimal
  * add docker images for R 4.2.1, dropped R 4.1.2
  * add `vapour` to package list for r-xxx-spatial


# mdsrocker 1.2.5 (2022-05-24)

#### ✨ features and improvements

  * move package `xml2` from *cicd* to *aws* package list.


# mdsrocker 1.2.3 (2022-05-06)

#### ✨ features and improvements

  * add fix for failed downloads of *whitebox executable* (#4),
    see [whiteboxR issue](https://github.com/giswqs/whiteboxR/issues/76).

    Current Solution:
    + manual download and intergration of zipfile into package
    + COPY zip during docker build
    + add unzip part into `install_spatial.sh`


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
