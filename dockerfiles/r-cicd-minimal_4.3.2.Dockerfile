FROM meterds/r-aws-minimal:4.3.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@addium.io>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="9f7dc21c8a57b57bbe7dc6fa1c4d08e9859b2606"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-minimal"
LABEL org.opencontainers.image.vendor="ADDIUM GmbH, Nuremberg"
LABEL org.opencontainers.image.version="4.3.2"

COPY /scripts/install_cicd.sh /rocker_scripts

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

