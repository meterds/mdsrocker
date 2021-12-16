pkgs = c(
    "elevatr"
    , "gdalcubes"
    , "lwgeom"
    , "mapview"
    , "ncdf4"
    , "raster"
    , "rgdal"
    , "s2"
    , "satellite"
    , "sf"
    , "sp"
    , "stars"
    , "starsExtra"
    , "terra"
    , "units"
)

sysdeps = lapply(
    pkgs
    , FUN = \(i) {
        remotes::system_requirements(os = "ubuntu-20.04", package = i)
    }
) |>
    unlist() |>
    unique() |>
    sort() |>
    gsub(pattern = "apt-get install -y ", replacement = "")

cat("apt get -qq update \\\n",
    "&& apt-get install -y --no-install-recommends \\\n"
    , paste0(sysdeps, collapse = " \\\n ")
)

cat(
    paste0(
        "install.packages(c('"
        , paste0(pkgs, collapse = "', '")
        , "'), repos = 'https://cran.rstudio.com')"
    )
)
