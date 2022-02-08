FROM rocker/r-ver:4.1.2

COPY /scripts/install-aws.sh /rocker_scripts

RUN /rocker_scripts/install-aws.sh

# default for executing container
CMD /bin/bash

