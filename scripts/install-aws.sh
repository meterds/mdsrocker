#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

## build ARGs
NCPUS=${NCPUS:--1}

#install system requirements
apt-get -qq update \
  && apt-get -y --no-install-recommends install \
  jq

#install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  renv

#install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages