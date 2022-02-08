FROM cstepper/r-aws-minimal:4.1.2

COPY /scripts/install-spatial.sh /rocker_scripts

RUN /rocker_scripts/install-spatial.sh

# default for executing container
CMD /bin/bash

