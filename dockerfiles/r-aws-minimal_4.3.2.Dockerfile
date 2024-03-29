FROM rocker/r-ver:4.3.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@addium.io>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-ver plus basic utilities stack including API tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="d99758b5d5e7fa89ff0962d9bd10f42761fb2641"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-minimal"
LABEL org.opencontainers.image.vendor="ADDIUM GmbH, Nuremberg"
LABEL org.opencontainers.image.version="4.3.2"

COPY /scripts/install_aws.sh /rocker_scripts

RUN /rocker_scripts/install_aws.sh

# default for executing container
CMD /bin/bash

