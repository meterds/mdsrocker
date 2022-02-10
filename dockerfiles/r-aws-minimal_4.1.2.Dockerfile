FROM rocker/r-ver:4.1.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-ver plus R packages `renv` & `units` and system library `jq`"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="e4008a7b299101f195612ce3cd806b4678c3061a"
LABEL org.opencontainers.image.source="https://github.com:cstepper/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-minimal"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.2"

COPY /scripts/install-aws.sh /rocker_scripts

RUN /rocker_scripts/install-aws.sh

# default for executing container
CMD /bin/bash

