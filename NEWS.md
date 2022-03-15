# mdsrocker 1.0.1.9003 (2022-03-15)

#### ✨ features and improvements

  * add *Dockerfiles* for R version *4.1.3* (released on 2022-03-10)

#### 🐛 bug fixes

#### 💬 documentation etc

#### 🍬 miscellaneous


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
