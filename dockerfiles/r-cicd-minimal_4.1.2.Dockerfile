FROM meterds/r-aws-spatial:4.1.2

COPY /scripts/install_cicd.sh /rocker_scripts

RUN chmod +x /rocker_scripts/install_cicd.sh
RUN /rocker_scripts/install_cicd.sh

# default for executing container
CMD /bin/bash
