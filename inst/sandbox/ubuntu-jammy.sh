#*******************************************************************************
#
# Ubuntu 22.04 - adding repositories (e.g. deadsnakes or ubuntugis-unstable)
#
# Author:     christoph
# Date:       2022-11-08
#*******************************************************************************

## general settings ============================================================

# define image
IMG="rocker/r-ver:4.2.2"
# IMG="rocker/r-ver:4.2.1"

# meter images
# IMG="meterds/r-aws-minimal:4.2.2"
# IMG="meterds/r-aws-minimal:4.2.1"

# pull defined image
docker image pull ${IMG}

## spin-up container ===========================================================
docker run -it --rm ${IMG} /bin/bash

# inside running container =====================================================

# os version
lsb_release -a # ubuntu-22.04

# package availability
dpkg -p software-properties-common # not available
dpkg -p gpg-agent # not available

# install packages
apt-get -qq update \
  && apt-get -y upgrade \
  && apt-get -y --no-install-recommends install \
  gpg-agent \
  software-properties-common

# add repository
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
