#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

#install system requirements
apt-get -qq update \
  && apt-get -y --no-install-recommends install \
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

#install R packages
install2.r --error --skipinstalled -n $NCPUS -r https://cran.rstudio.com \
  elevatr \
  gdalcubes \
  lwgeom \
  mapview \
  ncdf4 \
  openeo \
  raster \
  rgdal \
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

#install whiteboxtools
r -e 'whitebox::install_whitebox'

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages
