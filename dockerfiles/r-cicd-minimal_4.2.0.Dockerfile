FROM meterds/r-aws-minimal:4.2.0

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@addium.io>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="68796cf04933aaa2f8b911c16c9a89d389c9de6d"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-minimal"
LABEL org.opencontainers.image.vendor="ADDIUM GmbH, Nuremberg"
LABEL org.opencontainers.image.version="4.2.0"

COPY /scripts/install_cicd.sh /rocker_scripts

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

