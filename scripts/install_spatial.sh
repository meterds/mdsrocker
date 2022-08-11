#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

# build ARGs
NCPUS=${NCPUS:--1}

# add ubuntugis-unstable repo to get latest versions of gdal & co.
add-apt-repository ppa:ubuntugis/ubuntugis-unstable


# install system requirements
apt-get -qq update \
  && apt-get -y upgrade \
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

# install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  Rcpp \
  sp \
  rlang \
  magrittr \
  purrr \
  cli \
  glue \
  parallelly \
  listenv \
  digest \
  vctrs \
  lifecycle \
  globals \
  future \
  proxy \
  wk \
  e1071 \
  DBI \
  classInt \
  sys \
  askpass \
  R6 \
  mime \
  jsonlite \
  furrr \
  progressr \
  ps \
  processx \
  callr \
  later \
  promises \
  xfun \
  colorspace \
  viridisLite \
  RColorBrewer \
  munsell \
  labeling \
  farver \
  plyr \
  cpp11 \
  yaml \
  fastmap \
  uuid \
  htmlwidgets \
  htmltools \
  brew \
  base64enc \
  utf8 \
  pkgconfig \
  pillar \
  fansi \
  withr \
  tibble \
  isoband \
  gtable \
  gridExtra \
  ggplot2 \
  lazyeval \
  leaflet.providers \
  viridis \
  scales \
  markdown \
  crosstalk \
  sfheaders \
  geometries \
  repr \
  generics \
  rappdirs \
  IRdisplay \
  lubridate \
  crayon \
  abind \
  BH \
  RcppEigen \
  nabor \
  whitebox

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  terra \
  png \
  raster \
  units \
  s2 \
  openssl \
  curl \
  slippymath \
  sf \
  httr \
  elevatr \
  ncdf4 \
  gdalcubes \
  lwgeom \
  httpuv \
  systemfonts \
  svglite \
  rapidjsonr \
  jsonify \
  leaflet \
  geojsonsf \
  webshot \
  servr \
  satellite \
  leafpop \
  leafem \
  mapview \
  httr2 \
  openeo \
  rgdal \
  rstac \
  stars \
  data.table \
  nngeo \
  starsExtra \
  vapour

# install whitebox executable
WBT_ZIPFILE=/tmp/WhiteboxTools_linux_amd64.zip
unzip $WBT_ZIPFILE -d /usr/local/bin
rm $WBT_ZIPFILE

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages
