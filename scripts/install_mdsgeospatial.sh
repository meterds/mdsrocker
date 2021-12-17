#!/bin/bash

# NOTE:
# generate installation commands by running sysreqs.R and copying final output

set -e

# always set this for scripts but don't declare as ENV..
export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

# install general utils
apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  git \
  jq \
  libxml2-dev \
  libxt6 \
  pandoc

# install spatial system requirements
apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  gdal-bin \
  gsfonts \
  imagemagick \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgdal-dev \
  libgeos-dev \
  libmagick++-dev \
  libnetcdf-dev \
  libpng-dev \
  libproj-dev \
  libssl-dev \
  libudunits2-dev \
  make \
  zlib1g-dev

# install R packages for CI/CD
install2.r --error --skipinstalled -n $NCPUS \
  remotes \
  rcmdcheck \
  tinytest

# install geospatial R packages (plus dependencies)
install2.r --error --skipinstalled -n $NCPUS -r https://cran.rstudio.com \
  elevatr \
  gdalcubes \
  lwgeom \
  mapview \
  ncdf4 \
  openeo \
  raster \
  rgdal \
  rgeos \
  rstac \
  s2 \
  satellite \
  sf \
  sp \
  stars \
  starsExtra \
  terra \
  units \
  whitebox

# install whiteboxtools
r -e "whitebox::install_whitebox()"

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages
