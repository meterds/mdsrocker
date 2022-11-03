FROM meterds/r-aws-spatial:4.1.3

LABEL org.opencontainers.image.authors="Christoph Stepper <christoph.stepper@metergroup.com>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:focal"
LABEL org.opencontainers.image.description="r-aws-spatial plus a set of API tools"
LABEL org.opencontainers.image.licenses="MIT + file LICENSE"
LABEL org.opencontainers.image.revision="6fbb7925dfd99482dc7c8abc513d5fbe44b7b780"
LABEL org.opencontainers.image.source="https://github.com/meterds/mdsrocker"
LABEL org.opencontainers.image.title="r-aws-full"
LABEL org.opencontainers.image.vendor="METER Group AG, Munich"
LABEL org.opencontainers.image.version="4.1.3"

COPY /scripts/install_full.sh /rocker_scripts

RUN /rocker_scripts/install_full.sh

# default for executing container
CMD /bin/bash

