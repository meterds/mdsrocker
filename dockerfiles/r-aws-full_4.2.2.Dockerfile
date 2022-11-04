FROM meterds/r-aws-spatial:4.2.2

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-spatial plus a set of API tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="3363241f094c0d2b6738f1fdcb81be72f7a32c8b"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-full"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.2.2"

COPY /scripts/install_full.sh /rocker_scripts

RUN /rocker_scripts/install_full.sh

# default for executing container
CMD /bin/bash

