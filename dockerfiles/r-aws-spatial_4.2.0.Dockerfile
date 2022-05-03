FROM meterds/r-aws-minimal:4.2.0

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a spatial libraries stack"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="2542da47521170a09bdfdfb2ba7c3736c7a69939"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-spatial"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.2.0"

ENV R_WHITEBOX_EXE_PATH=/usr/local/bin/WBT/whitebox_tools

COPY /scripts/install_spatial.sh /rocker_scripts

RUN /rocker_scripts/install_spatial.sh

# default for executing container
CMD /bin/bash

