FROM rocker/r-ver:4.2.0

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-ver plus R packages `renv` & `units` and system libraries `git`, `jq`, `libssl-dev` & `libsasl2-dev`"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="07b99b43fb3f120faadbd31db60c7be084ed9fb1"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-minimal"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.2.0"

COPY /scripts/install_aws.sh /rocker_scripts

COPY /inst/extdata/WhiteboxTools_linux_amd64.zip /tmp

RUN /rocker_scripts/install_aws.sh

# default for executing container
CMD /bin/bash

