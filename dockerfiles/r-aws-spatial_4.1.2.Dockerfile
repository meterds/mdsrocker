FROM meterds/r-aws-minimal:4.1.2

COPY /scripts/install_spatial.sh /rocker_scripts

RUN chmod +x /rocker_scripts/install_spatial.sh
RUN /rocker_scripts/install_spatial.sh

# default for executing container
CMD /bin/bash
