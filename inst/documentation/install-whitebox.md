mdsrocker-install-whiteboxtools
================
Christoph Stepper
2022-05-04

## Installation of WhiteboxTools Binary

We want to have *WhiteboxTools* installed during the Github Actions
Workflow using `whitebox::install_whitebox()`.

As mentioned in this [whiteboxR
issue](https://github.com/giswqs/whiteboxR/issues/76), it happens from
time to time, that the download of the *WhiteboxTools zip file* from
<https://www.whiteboxgeo.com> fails.

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
    ## REPOSITORY              TAG       IMAGE ID       CREATED        SIZE
    ## meterds/r-aws-spatial   4.1.2     cdc962ab49d6   18 hours ago   2.14GB
    ## meterds/r-aws-spatial   4.1.3     287fdcfd6989   18 hours ago   2.17GB
    ## meterds/r-aws-spatial   4.2.0     55d2ac6a8d04   37 hours ago   1.99GB

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
    ## [1] FALSE
