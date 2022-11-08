#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

# build ARGs
NCPUS=${NCPUS:--1}

# a function to install apt packages only if they are not installed
function apt_install() {
  if ! dpkg -s "$@" >/dev/null 2>&1; then
  if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
  apt-get -qq update
  fi
  apt-get install -y --no-install-recommends "$@"
  fi
}

# install system requirements
apt_install \
  apt-utils \
  curl \
  git \
  jq \
  libbz2-dev \
  libcurl4-openssl-dev \
  libglpk-dev \
  libgmp3-dev \
  libicu-dev \
  libpng-dev \
  libsasl2-dev \
  libsodium-dev \
  libssl-dev \
  libudunits2-dev \
  libxml2-dev \
  make \
  pandoc \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  software-properties-common \
  zlib1g-dev

# install AWS CLI
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscli.zip'
unzip /tmp/awscli.zip -d /tmp
./tmp/aws/install
rm /tmp/awscli.zip
rm -r /tmp/aws

# install Python packages
python3 -m pip install --no-cache-dir --upgrade \
  pip
python3 -m pip install --no-cache-dir \
  pipreqs \
  poetry \
  requests

# update R packages
R_LIBS_SITE=/usr/local/lib/R/site-library
ln -s ${R_LIBS_SITE}/littler/examples/update.r /usr/local/bin/update.r
update.r -n $NCPUS

# install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  rlang \
  lifecycle \
  glue \
  cli \
  withr \
  vctrs \
  magrittr \
  bit \
  cpp11 \
  tidyselect \
  R6 \
  purrr \
  bit64 \
  assertthat \
  backports \
  checkmate \
  utf8 \
  fansi \
  pkgconfig \
  pillar \
  tibble \
  generics \
  dplyr \
  sys \
  askpass \
  mime \
  Rcpp \
  jsonlite \
  digest \
  base64enc \
  later \
  promises \
  ellipsis \
  swagger \
  crayon \
  renv \
  rprojroot \
  rappdirs \
  here \
  RcppTOML \
  xfun \
  yaml \
  highr \
  evaluate \
  ps \
  processx \
  callr \
  base64url \
  zoo

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  arrow \
  curl \
  openssl \
  xml2 \
  httr \
  paws.common \
  paws.storage \
  paws.security.identity \
  paws.networking \
  paws.management \
  paws.machine.learning \
  paws.end.user.computing \
  paws.developer.tools \
  paws.database \
  paws.customer.engagement \
  paws.cost.management \
  paws.compute \
  paws.application.integration \
  paws.analytics \
  paws \
  sodium \
  httpuv \
  webutils \
  stringi \
  plumber \
  png \
  reticulate \
  stringr \
  knitr \
  igraph \
  data.table \
  targets \
  fs \
  tarchetypes \
  units

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages

## Strip binary installed lybraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
