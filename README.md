


<!-- Edit the README.Rmd only!!! The README.md is generated automatically from README.Rmd. -->

rdefra: Interact with the UK AIR Pollution Database from DEFRA
---------------

[![DOI](https://zenodo.org/badge/9118/kehraProject/r_rdefra.svg)](https://zenodo.org/badge/latestdoi/9118/kehraProject/r_rdefra)
[![Build Status](https://travis-ci.org/kehraProject/r_rdefra.svg)](https://travis-ci.org/kehraProject/r_rdefra.svg?branch=master)
[![codecov.io](https://codecov.io/github/kehraProject/r_rdefra/coverage.svg?branch=master)](https://codecov.io/github/kehraProject/r_rdefra?branch=master)
[![CRAN Status Badge](http://www.r-pkg.org/badges/version/rdefra)](http://cran.r-project.org/web/packages/rdefra)
[![CRAN Total Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rdefra)](http://cran.rstudio.com/web/packages/rdefra/index.html)
[![CRAN Monthly Downloads](http://cranlogs.r-pkg.org/badges/rdefra)](http://cran.rstudio.com/web/packages/rdefra/index.html)

The package [rdefra](https://cran.r-project.org/package=rdefra) allows to retrieve air pollution data from the Air Information Resource [UK-AIR](https://uk-air.defra.gov.uk/) of the Department for Environment, Food and Rural Affairs in the United Kingdom. UK-AIR does not provide a public API for programmatic access to data, therefore this package scrapes the HTML pages to get relevant information.

This package follows a logic similar to other packages such as [waterData](https://cran.r-project.org/package=waterdata) and [rnrfa](https://cran.r-project.org/package=rnrfa): sites are first identified through a catalogue, data are imported via the station identification number, then data are visualised and/or used in analyses. The metadata related to the monitoring stations are accessible through the function `ukair_catalogue()`, missing stations' coordinates can be obtained using the function `ukair_get_coordinates()`, and time series data related to different pollutants can be obtained using the function `ukair_get_hourly_data()`.

The package is designed to collect data efficiently. It allows to download multiple years of data for a single station with one line of code and, if used with the parallel package, allows the acquisition of data from hundreds of sites in only few minutes.

For similar functionalities see also the [openair](https://cran.r-project.org/package=openair) package, which relies on a local copy of the data on servers at King's College (UK), and the [ropenaq](https://CRAN.R-project.org/package=ropenaq) which provides UK-AIR latest measured levels (see https://uk-air.defra.gov.uk/latest/currentlevels) as well as data from other countries.

### Dependencies
The rdefra package depends on a number of CRAN packages. Check for missing dependencies and install them:

```R
packs <- c('RCurl', 'XML', 'plyr', 'rgdal', 'sp', 'devtools')
new.packages <- packs[!(packs %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
```

### Installation

You can install this package from CRAN:


```r
install.packages("rdefra")
```


Or you can install the development version from Github with [devtools](https://github.com/hadley/devtools):


```r
library(devtools)
install_github("cvitolo/r_rdefra", subdir = "rdefra")
```

Load the rdefra package:


```r
library(rdefra)
```

### Functions
DEFRA monitoring stations can be downloaded and filtered using the function `ukair_catalogue()`. A cached version (downloaded in Feb 2016) is in `data(stations)`.


```r
# Get full catalogue
stations <- ukair_catalogue()
```

Some of these have no coordinates but Easting (E) and Northing (N) are available on the DEFRA website. Get E and N, transform them to latitude and longitude and populate the missing coordinates using the code below.


```r
# Find stations with no coordinates
myRows <- which(is.na(stations$Latitude) | is.na(stations$Longitude))
# Get the ID of stations with no coordinates
stationList <- as.character(stations$UK.AIR.ID[myRows])
# Scrape DEFRA website to get Easting/Northing
EN <- ukair_get_coordinates(stationList)
# Only keep non-NA Easting/Northing coordinates
noNA <- which(!is.na(EN$Easting) & !is.na(EN$Northing))
yesNA <- which(is.na(EN$Easting) & is.na(EN$Northing))
```

Create spatial points from metadata table (coordinates are in WGS84):

```r
library(rgdal)
library(sp)
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

```r
stationsNew$SiteID <- ukair_get_site_id(as.character(stationsNew$UK.AIR.ID))
validStations <- which(!is.na(stationsNew$SiteID))
IDstationHdata <- stationsNew$SiteID[validStations] 
```

In the figure below, blue circles show stations with valid coordinates within the UK-AIR database (Air Information Resource) while red circles show locations for which hourly data is available.


```r
library(leaflet)
leaflet(data = stationsNew) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.5) %>% 
  addCircleMarkers(lng = ~Longitude[validStations], 
                   lat = ~Latitude[validStations], 
                   radius = 0.5, color="red", popup = ~SiteID[validStations])
```

![UK-AIR monitoring stations (August 2016)](paper/MonitoringStations.png)

How many of the above stations are in England and have hourly records?

```r
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

Pollution data started to be collected in 1972 and consists of hourly concentration of various species (in &#956;g/m<sup>3</sup>), such as ozone (O<sub>3</sub>), particulate matters (PM<sub>2.5</sub> and PM<sub>10</sub>), nitrogen dioxide (NO<sub>2</sub>), sulphur dioxide (SO<sub>2</sub>), and so on. Building the time series for a given station can be done in one line of code:


```r
df <- ukair_get_hourly_data("BTR3", years=2012:2016)
```

Using parallel processing, the acquisition of data from hundreds of sites takes only few minutes:


```r
library(parallel)
library(dplyr)

# Calculate the number of cores
no_cores <- detectCores() - 1
 
# Initiate cluster
cl <- makeCluster(no_cores)

system.time(myList <- parLapply(cl, IDstationHdata, 
ukair_get_hourly_data, years=1999:2016))

stopCluster(cl)

df <- rbind_all(myList)
```

### Meta

* Please [report any issues or bugs](https://github.com/kehraProject/r_rdefra/issues).
* License: [GPL-3](https://opensource.org/licenses/GPL-3.0)
* Get citation information for `rdefra` in R doing `citation(package = 'rdefra')`

<br/>

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
