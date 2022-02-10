FROM cstepper/r-aws-minimal:4.1.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-minimal plus a set of CI/CD tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="1d3a8be55a25eb613d662fcf3550c0a3b1ef1d89"
LABEL org.opencontainers.image.source="https://github.com:cstepper/mdsrocker"
LABEL org.opencontainers.image.title="r-cicd-minimal"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.2"

COPY /scripts/install-cicd.sh /rocker_scripts

RUN /rocker_scripts/install-cicd.sh

# default for executing container
CMD /bin/bash

