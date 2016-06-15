rdefra: an R package to interact with the UK AIR pollution database from DEFRA
=======

[![DOI](https://zenodo.org/badge/9118/cvitolo/r_rdefra.svg)](https://zenodo.org/badge/latestdoi/9118/cvitolo/r_rdefra)
[![CRAN Status Badge](http://www.r-pkg.org/badges/version/rdefra)](http://cran.r-project.org/web/packages/rdefra)
[![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rdefra)](http://cran.rstudio.com/web/packages/rdefra/index.html)
[![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/rdefra)](http://cran.rstudio.com/web/packages/rdefra/index.html)

DEFRA serves air pollution data from a variety of monitoring networks. 

There is no public API and this package just scrapes the website for information. 


**To cite this software:** 

Vitolo C., Russell A. and Tucker A. (2016). rdefra: Interact with the UK AIR pollution database from DEFRA. R package version 0.1. https://CRAN.R-project.org/package=rdefra. DOI: http://dx.doi.org/10.5281/zenodo.55270


# Dependencies
The rdefra package is dependent on a number of CRAN packages. Install them first:

```R
install.packages(c("RCurl", "XML", "plyr", "devtools", "rgdal", "sp"))
library(devtools)
```


# Installation
This package is currently under development and available via devtools:

```R
install_github("cvitolo/r_rdefra", subdir = "rdefra")
```

Now, load the rdefra package:

```R
library(rdefra)
```

# Functions
DEFRA monitoring stations can be downloaded and fitered using the function `catalogue()`. A cached version (downloaded in Feb 2016) is in `data(stations)`. 
```R
# Get full catalogue
stations <- catalogue()
```

Some of these have no coordinates but Easting (E) and Northing (N) are available on the DEFRA website. Get E and N, transform them to latitude and longitude and populate the missing coordinates using the code below.

```R
# Find stations with no coordinates
myRows <- which(is.na(stations$Latitude) | is.na(stations$Longitude))
# Get the ID of stations with no coordinates
stationList <- as.character(stations$UK.AIR.ID[myRows])
# Scrape DEFRA website to get Easting/Northing
EN <- EastingNorthing(stationList)
# Only keep non-NA Easting/Northing coordinates
noNA <- which(!is.na(EN$Easting) & !is.na(EN$Northing))
yesNA <- which(is.na(EN$Easting) & is.na(EN$Northing))

require(rgdal); require(sp)
# Define spatial points
pt <- EN[noNA,]
coordinates(pt) <- ~Easting+Northing
proj4string(pt) <- CRS("+init=epsg:27700")
# Convert coordinates from British National Grid to WGS84
pt <- data.frame(spTransform(pt, CRS("+init=epsg:4326"))@coords)  
names(pt) <- c("Longitude", "Latitude")

# Populate the catalogue with newly calculated coordinates
stations[myRows[yesNA],c("UK.AIR.ID", "Longitude", "Latitude")]
stationsNew <- stations
stationsNew$Longitude[myRows][noNA] <- pt$Longitude
stationsNew$Latitude[myRows][noNA] <- pt$Latitude

# Keep only stations with coordinates
noCoords <- which(is.na(stationsNew$Latitude) | is.na(stationsNew$Longitude))
stationsNew <- stationsNew[-noCoords,]
```

Check whether there are hourly data available
```R
stationsNew$SiteID <- getSiteID(as.character(stationsNew$UK.AIR.ID))
validStations <- which(!is.na(stationsNew$SiteID))
IDstationHdata <- stationsNew$SiteID[validStations] 
```

There are 6563 stations with valid coordinates within the UK-AIR (Air Information Resource, blue circles) database, for 225 of them hourly data is available and their location is shown in the map below (red circle).

```R
library(leaflet)
leaflet(data = stationsNew) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.5) %>% 
  addCircleMarkers(lng = ~Longitude[validStations], 
                   lat = ~Latitude[validStations], 
                   radius = 0.5, color="red", popup = ~SiteID[validStations])
```

How many of the above stations are in England and have hourly records?
```R
stationsNew <- stationsNew[!is.na(stationsNew$SiteID),]

library(raster) 
adm <- getData('GADM', country='GBR', level=1)
England <- adm[adm$NAME_1=='England',]
stationsSP <- SpatialPoints(stationsNew[, c('Longitude', 'Latitude')], 
                            proj4string=CRS(proj4string(England)))

library(sp)
x <- over(stationsSP, England)[,1]
x <- which(!is.na(x))
stationsNew <- stationsNew[x,]

library(leaflet)
leaflet(data = stationsNew) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, 
                   radius = 0.5, color="red", popup = ~SiteID)
```

Pollution data started to be collected in 1972, however hourly data is available only from XXXX. Building the time series for a given station can be done in one line of code:

```R
df <- get1Hdata("BAR2", years=1972:2016)
```

Using parallel processing, the acquisition of data from hundreds of sites takes only few minutes:

```R
library(parallel)
library(plyr)

# Calculate the number of cores
no_cores <- detectCores() - 1
 
# Initiate cluster
cl <- makeCluster(no_cores)

system.time(myList <- parLapply(cl, IDstationHdata, 
get1Hdata, years=1999:2016))

stopCluster(cl)

df <- rbind.fill(myList)
```


# Leave your feedback
I would greatly appreciate if you could leave your feedbacks via email (cvitolodev@gmail.com).
