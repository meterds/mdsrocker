FROM meterds/r-aws-minimal:4.3.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@addium.io>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a spatial libraries stack"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="d99758b5d5e7fa89ff0962d9bd10f42761fb2641"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-spatial"
LABEL org.opencontainers.image.vendor="ADDIUM GmbH, Nuremberg"
LABEL org.opencontainers.image.version="4.3.2"

ENV R_WHITEBOX_EXE_PATH=/usr/local/bin/WBT/whitebox_tools

COPY /scripts/install_spatial.sh /rocker_scripts

COPY /inst/extdata/WhiteboxTools_linux_amd64.zip /tmp

RUN /rocker_scripts/install_spatial.sh

# default for executing container
CMD /bin/bash

