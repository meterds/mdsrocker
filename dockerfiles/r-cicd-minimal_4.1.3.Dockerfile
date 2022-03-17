FROM meterds/r-aws-minimal:4.1.3

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="60b91c72939315f7ebcbd3f13e8413a76ce9b0b2"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-minimal"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.3"

COPY /scripts/install_cicd.sh /rocker_scripts

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

