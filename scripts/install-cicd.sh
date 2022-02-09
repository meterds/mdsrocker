#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

#install system requirements
apt-get -qq update \
  && apt-get -y --no-install-recommends install \
  git \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libfribidi-dev \
  libharfbuzz-dev \
  libicu-dev \
  libjpeg-dev \
  libpng-dev \
  libssl-dev \
  libtiff-dev \
  libxml2-dev \
  make \
  pandoc

#install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  backports \
  checkmate \
  sys \
  askpass \
  R6 \
  mime \
  jsonlite \
  lazyeval \
  yaml \
  withr \
  crayon \
  rex \
  digest \
  magrittr \
  rlang \
  later \
  Rcpp \
  fastmap \
  base64enc \
  htmltools \
  promises \
  jquerylib \
  crosstalk \
  htmlwidgets \
  DT \
  glue \
  xfun \
  highr \
  evaluate \
  utf8 \
  vctrs \
  pkgconfig \
  pillar \
  tibble \
  rematch2 \
  fansi \
  diffobj \
  rstudioapi \
  rprojroot \
  waldo \
  ps \
  processx \
  praise \
  pkgload \
  lifecycle \
  ellipsis \
  desc \
  cli \
  callr \
  brio \
  xmlparsedata \
  testthat \
  tinytex \
  cpp11 \
  cachem \
  memoise \
  rappdirs \
  whisker \
  purrr \
  downlit \
  renv \
  prettyunits \
  xopen \
  sessioninfo \
  pkgbuild \
  tinytest

#install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  openssl \
  curl \
  httr \
  covr \
  stringi \
  stringr \
  remotes \
  xml2 \
  knitr \
  cyclocomp \
  lintr \
  textshaping \
  systemfonts \
  fs \
  sass \
  rmarkdown \
  ragg \
  bslib \
  pkgdown \
  rcmdcheck

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages