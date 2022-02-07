FROM rocker/r-ver:4.1.2

COPY /scripts/install-aws.sh /rocker_scripts

RUN chmod +x /rocker_scripts/install-aws.sh
RUN /rocker_scripts/install-aws.sh

# default for executing container
CMD /bin/bash
