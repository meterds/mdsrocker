#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

# build ARGs
NCPUS=${NCPUS:--1}

# re-install gpg-agent and software-properties-common
# for Ubuntu-22.04 (as otherwise add-apt-repository fails)
apt-get -qq update \
  && apt-get -y upgrade \
  && apt-get -y --no-install-recommends install \
  gpg-agent \
  software-properties-common

# add ubuntugis-unstable repo to get latest versions of gdal & co.
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable

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
  gdal-bin \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libgdal-dev \
  libgeos-dev \
  libicu-dev \
  libnetcdf-dev \
  libpng-dev \
  libproj-dev \
  libsqlite3-dev \
  libssl-dev \
  libudunits2-dev \
  make \
  pandoc \
  zlib1g-dev

# install whitebox executable
WBT_ZIPFILE=/tmp/WhiteboxTools_linux_amd64.zip
unzip $WBT_ZIPFILE -d /usr/local/bin
rm $WBT_ZIPFILE

# install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  Rcpp \
  sp \
  glue \
  vctrs \
  rlang \
  magrittr \
  lifecycle \
  cli \
  purrr \
  parallelly \
  listenv \
  digest \
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
  BH \
  fastmap \
  promises \
  later \
  xfun \
  colorspace \
  viridisLite \
  RColorBrewer \
  munsell \
  labeling \
  farver \
  plyr \
  rappdirs \
  memoise \
  cachem \
  tinytex \
  jquerylib \
  fontawesome \
  highr \
  evaluate \
  cpp11 \
  yaml \
  ellipsis \
  uuid \
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
  viridis \
  scales \
  leaflet.providers \
  crosstalk \
  sfheaders \
  geometries \
  repr \
  timechange \
  generics \
  IRdisplay \
  lubridate \
  crayon \
  abind \
  RcppEigen \
  nabor \
  whitebox

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.posit.co/cran/latest \
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
  fs \
  stringi \
  sass \
  stringr \
  bslib \
  systemfonts \
  rmarkdown \
  knitr \
  svglite \
  htmlwidgets \
  rapidjsonr \
  jsonify \
  leaflet \
  geojsonsf \
  servr \
  satellite \
  leafpop \
  leafem \
  mapview \
  httr2 \
  openeo \
  rstac \
  stars \
  data.table \
  nngeo \
  starsExtra

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages

## Strip binary installed lybraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
strip /usr/local/lib/R/site-library/*/libs/*.so
