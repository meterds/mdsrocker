FROM meterds/r-aws-minimal:4.3.0

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@addium.io>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="ce2a54a1ba812312b9d39ff296f6f4133998b2d5"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-minimal"
LABEL org.opencontainers.image.vendor="ADDIUM GmbH, Nuremberg"
LABEL org.opencontainers.image.version="4.3.0"

COPY /scripts/install_cicd.sh /rocker_scripts

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

