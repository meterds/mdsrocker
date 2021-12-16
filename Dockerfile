FROM rocker/r-ver:4.1.2

RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends \
    gdal-bin \
    gsfonts \
    imagemagick \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgdal-dev \
    libgeos-dev \
    libmagick++-dev \
    libnetcdf-dev \
    libpng-dev \
    libproj-dev \
    libssl-dev \
    libudunits2-dev \
    make \
    zlib1g-dev \
    > /dev/null

RUN Rscript -e "install.packages(c('elevatr', 'gdalcubes', 'lwgeom', 'mapview', 'ncdf4', 'openeo', 'raster', 'rgdal', 'rgeos', 'rstac', 's2', 'satellite', 'sf', 'sp', 'stars', 'starsExtra', 'terra', 'units', 'whitebox'), repos = 'https://cran.rstudio.com')" \
    && Rscript -e "install.packages(c('remotes', 'rcmdcheck', 'tinytest))" \
    && Rscript -e "whitebox::install_whitebox()"

# default for executing container
CMD /bin/bash
