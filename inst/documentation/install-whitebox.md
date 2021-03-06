mdsrocker-install-whiteboxtools
================
Christoph Stepper
2022-05-04

## Installation of WhiteboxTools Binary

We want to have *WhiteboxTools* installed during the Github Actions
Workflow.

### Problem

Originally we used `"whitebox::install_whitebox()` within the
*install_spatial.sh* file. As mentioned in this [whiteboxR
issue](https://github.com/giswqs/whiteboxR/issues/76), it happens from
time to time, that the download of the *WhiteboxTools zip file* from
<https://www.whiteboxgeo.com> fails.

### Current Solution

We integrated the *WhiteboxTools zip file* into our *mdsrocker*
repository (`"inst/extdata/WhiteboxTools_linux_amd64.zip"`) manually.

During the Github Actions Workflow run, we simply use this and extract
it to the defined path.

## Docker images

Let’s have a look at the most recently built docker images.

First download the docker images from dockerhub.

``` bash
tags=("4.1.2" "4.1.3" "4.2.0")

# pull docker images
for t in "${tags[@]}"
do
    img="meterds/r-aws-spatial:$t"
    # echo $img
    docker pull $img -q
done

# list of docker images
docker image ls
```

    ## docker.io/meterds/r-aws-spatial:4.1.2
    ## docker.io/meterds/r-aws-spatial:4.1.3
    ## docker.io/meterds/r-aws-spatial:4.2.0
    ## REPOSITORY              TAG       IMAGE ID       CREATED       SIZE
    ## meterds/r-aws-spatial   4.1.3     a0155fe1ad55   2 hours ago   2.15GB
    ## meterds/r-aws-spatial   4.2.0     598ae230cf1a   2 hours ago   2.15GB
    ## meterds/r-aws-spatial   4.1.2     200c1238a01c   2 hours ago   2.14GB

And then check if the *whitebox binary* can be found.

``` bash
tags=("4.1.2" "4.1.3" "4.2.0")

# walk through images and check whether whiteboxtools is installed
for t in "${tags[@]}"
do
    img="meterds/r-aws-spatial:$t"
    echo $img
    docker run --rm $img Rscript -e "whitebox::check_whitebox_binary()"
done
```

    ## meterds/r-aws-spatial:4.1.2
    ## [1] TRUE
    ## meterds/r-aws-spatial:4.1.3
    ## [1] TRUE
    ## meterds/r-aws-spatial:4.2.0
    ## [1] TRUE
