FROM meterds/r-aws-spatial:4.1.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-spatial plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="3e6c2b01714d4a2bb10d9f03e6dfe02c56a27163"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-spatial"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.2"

COPY /scripts/install_cicd.sh /rocker_scripts

RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash

