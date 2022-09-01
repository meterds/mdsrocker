FROM rocker/r-ver:4.2.0

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-ver plus basic utilities stack"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="fc3211bd75768d11bb2ced6f8adf2a655538e2d1"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-minimal"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.2.0"

ENV RETICULATE_PYTHON=/usr/bin/python3

COPY /scripts/install_aws.sh /rocker_scripts

RUN /rocker_scripts/install_aws.sh

# default for executing container
CMD /bin/bash

