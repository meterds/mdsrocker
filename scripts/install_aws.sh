#!/bin/bash

set -e

# always set this for scripts but don't declare as ENV.
export DEBIAN_FRONTEND=noninteractive

# build ARGs
NCPUS=${NCPUS:--1}

# install system requirements
apt-get -qq update \
  && apt-get -y upgrade \
  && apt-get -y --no-install-recommends install \
  curl \
  git \
  jq \
  libsasl2-dev \
  libssl-dev \
  libudunits2-dev \
  libxml2-dev \
  software-properties-common

# install binary R packages
install2.r --error --skipinstalled -n $NCPUS \
  renv \
  Rcpp

# install source R packages
install2.r --error --skipinstalled -n $NCPUS -r https://packagemanager.rstudio.com/cran/latest \
  units \
  xml2

# install AWS CLI
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscli.zip'
unzip /tmp/awscli.zip -d /tmp
./tmp/aws/install
rm /tmp/awscli.zip
rm -r /tmp/aws

# clean up
rm -rf /var/lib/apt/lists/*
rm -r /tmp/downloaded_packages
