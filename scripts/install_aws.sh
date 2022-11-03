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

# add deadsnakes for python3.9
add-apt-repository ppa:deadsnakes/ppa

# install system requirements
apt_install \
  curl \
  git \
  jq \
  libbz2-dev \
  libcurl4-openssl-dev \
  libpng-dev \
  libsasl2-dev \
  libsodium-dev \
  libssl-dev \
  libudunits2-dev \
  libxml2-dev \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  software-properties-common

# install AWS CLI
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscli.zip'
unzip /tmp/awscli.zip -d /tmp
./tmp/aws/install
rm /tmp/awscli.zip
rm -r /tmp/aws

# install Python packages
python3.9 -m pip install --no-cache-dir --upgrade \
  pip
python3.9 -m pip install --no-cache-dir \
  pipreqs \
  poetry

# update R packages
R_LIBS_SITE=/usr/local/lib/R/site-library
ln -s ${R_LIBS_SITE}/littler/examples/update.r /usr/local/bin/update.r
update.r -n $NCPUS

# install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  backports \
  checkmate \
  renv \
  rprojroot \
  Rcpp \
  withr \
  rappdirs \
  jsonlite \
  here \
  RcppTOML

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  curl \
  png \
  reticulate \
  units \
  xml2

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages

## Strip binary installed lybraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
