FROM rocker/r-ver:4.1.2

COPY /scripts/install_mdsgeospatial.sh /rocker_scripts

RUN chmod +x /rocker_scripts/install_mdsgeospatial.sh
RUN /rocker_scripts/install_mdsgeospatial.sh

# default for executing container
CMD /bin/bash
