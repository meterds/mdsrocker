# mdsrocker 0.0.0.9000 (2022-02-08)

#### ✨ features and improvements

  * add package infrastructure incl:
    - package data containing all the information regarding installation logic 
      (`rocker_installation`) and docker files (`rocker_dockerfiles`),
    - functions to create shell scripts with install logic 
      (`create_shellscript`), dockerfiles (`create_dockerfile`) and 
      Github Actions workflow (`create_github_workflow`)
    - `execute.R` script, which can be called to create/update the various
      files.
 
#### 🐛 bug fixes

#### 💬 documentation etc

  * Add content to `README.Rmd`  

#### 🍬 miscellaneous

  * Add a `NEWS.md` file to track changes to the package.