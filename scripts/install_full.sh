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
  libcurl4-openssl-dev \
  libglpk-dev \
  libgmp3-dev \
  libicu-dev \
  libsodium-dev \
  libssl-dev \
  libxml2-dev \
  make \
  pandoc \
  zlib1g-dev

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
  xfun \
  yaml \
  highr \
  evaluate \
  ps \
  processx \
  backports \
  callr \
  base64url

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  arrow \
  openssl \
  xml2 \
  httr \
  curl \
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
  stringr \
  knitr \
  igraph \
  data.table \
  targets \
  fs \
  tarchetypes

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages

## Strip binary installed lybraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
