FROM meterds/r-aws-spatial:4.1.3

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-spatial plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="7970a7628300c1d5907b2cb9a90600269d9ea060"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-spatial"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.3"

COPY /scripts/install_cicd.sh /rocker_scripts

COPY /inst/extdata/WhiteboxTools_linux_amd64.zip /tmp

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

