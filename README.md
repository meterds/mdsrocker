
# mdsrocker

[![Docker Image
CI](https://github.com/meterds/mdsrocker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/meterds/mdsrocker/actions/workflows/docker-image.yml)

The Docker image `mdsrocker` adds a set of geospatial packages to the
[r-ver](https://hub.docker.com/r/rocker/r-ver) base R image and is
designed towards pipelines of spatial packages at METER Data Science.
The image can be pulled from
[Dockerhub](https://hub.docker.com/r/meterds/mdsrocker).

Currently, the following packages are included:

<table>
<thead>
<tr>
<th style="text-align:left;">
Package
</th>
<th style="text-align:left;">
Title
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
elevatr
</td>
<td style="text-align:left;">
Access Elevation Data from Various APIs
</td>
</tr>
<tr>
<td style="text-align:left;">
gdalcubes
</td>
<td style="text-align:left;">
Earth Observation Data Cubes from Satellite Image Collections
</td>
</tr>
<tr>
<td style="text-align:left;">
lwgeom
</td>
<td style="text-align:left;">
Bindings to Selected ‘liblwgeom’ Functions for Simple Features
</td>
</tr>
<tr>
<td style="text-align:left;">
mapview
</td>
<td style="text-align:left;">
Interactive Viewing of Spatial Data in R
</td>
</tr>
<tr>
<td style="text-align:left;">
ncdf4
</td>
<td style="text-align:left;">
Interface to Unidata netCDF (Version 4 or Earlier) Format Data Files
</td>
</tr>
<tr>
<td style="text-align:left;">
openeo
</td>
<td style="text-align:left;">
Client Interface for ‘openEO’ Servers
</td>
</tr>
<tr>
<td style="text-align:left;">
raster
</td>
<td style="text-align:left;">
Geographic Data Analysis and Modeling
</td>
</tr>
<tr>
<td style="text-align:left;">
rgdal
</td>
<td style="text-align:left;">
Bindings for the ‘Geospatial’ Data Abstraction Library
</td>
</tr>
<tr>
<td style="text-align:left;">
rgeos
</td>
<td style="text-align:left;">
Interface to Geometry Engine - Open Source (‘GEOS’)
</td>
</tr>
<tr>
<td style="text-align:left;">
rstac
</td>
<td style="text-align:left;">
Client Library for SpatioTemporal Asset Catalog
</td>
</tr>
<tr>
<td style="text-align:left;">
s2
</td>
<td style="text-align:left;">
Spherical Geometry Operators Using the S2 Geometry Library
</td>
</tr>
<tr>
<td style="text-align:left;">
satellite
</td>
<td style="text-align:left;">
Handling and Manipulating Remote Sensing Data
</td>
</tr>
<tr>
<td style="text-align:left;">
sf
</td>
<td style="text-align:left;">
Simple Features for R
</td>
</tr>
<tr>
<td style="text-align:left;">
sp
</td>
<td style="text-align:left;">
Classes and Methods for Spatial Data
</td>
</tr>
<tr>
<td style="text-align:left;">
stars
</td>
<td style="text-align:left;">
Spatiotemporal Arrays, Raster and Vector Data Cubes
</td>
</tr>
<tr>
<td style="text-align:left;">
starsExtra
</td>
<td style="text-align:left;">
Miscellaneous Functions for Working with ‘stars’ Rasters
</td>
</tr>
<tr>
<td style="text-align:left;">
terra
</td>
<td style="text-align:left;">
Spatial Data Analysis
</td>
</tr>
<tr>
<td style="text-align:left;">
units
</td>
<td style="text-align:left;">
Measurement Units for R Vectors
</td>
</tr>
<tr>
<td style="text-align:left;">
whitebox
</td>
<td style="text-align:left;">
‘WhiteboxTools’ R Frontend
</td>
</tr>
</tbody>
</table>

Additionally, the following non-spatial packages are installed:

<table>
<thead>
<tr>
<th style="text-align:left;">
Package
</th>
<th style="text-align:left;">
Title
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
remotes
</td>
<td style="text-align:left;">
R Package Installation from Remote Repositories, Including ‘GitHub’
</td>
</tr>
<tr>
<td style="text-align:left;">
rcmdcheck
</td>
<td style="text-align:left;">
Run ‘R CMD check’ from ‘R’ and Capture Results
</td>
</tr>
<tr>
<td style="text-align:left;">
tinytest
</td>
<td style="text-align:left;">
Lightweight and Feature Complete Unit Testing Framework
</td>
</tr>
</tbody>
</table>
