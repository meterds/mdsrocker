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

#install R packages
install2.r --error --skipinstalled -n $NCPUS \
  checkmate \
  covr \
  DT \
  lintr \
  pkgdown \
  renv \
  rcmdcheck \
  tinytest \
  xml2

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages
