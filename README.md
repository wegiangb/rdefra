rdefra: an R package to interact with the UK AIR pollution database from DEFRA
=======

DEFRA serves air pollution data from a variety of monitoring networks. 

There is no public API and this package just scrapes the website for information. 


# Dependencies
The rnrfa package is dependent on a number of CRAN packages. Install them first:

```R
install.packages(c("RCurl", "XML", "plyr", "devtools"))
library(devtools)
```


# Installation
This package is currently under development and available via devtools:

```R
install_github("cvitolo/rdefra")
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
myRows <- which(is.na(stations$Latitude) | is.na(stations$Longitude))
stationList <- as.character(stations$UK.AIR.ID[myRows])
EN <- EastingNorthing(stationList)
noNA <- which(!is.na(EN$Easting) & !is.na(EN$Northing))

require(rgdal); require(sp)
pt <- EN[noNA,]
coordinates(pt) <- ~Easting+Northing
proj4string(pt) <- CRS("+init=epsg:27700")
pt <- data.frame(spTransform(pt, CRS("+init=epsg:4326"))@coords)  

stations$Longitude[myRows][noNA] <- pt$Easting
stations$Latitude[myRows][noNA] <- pt$Northing

stations <- stations[-which(is.na(stations$Latitude) | is.na(stations$Longitude)),]
```

Check whether there are flat files available
```R
stations$SiteID <- getSiteID(stations$UK.AIR.ID)
validStations <- which(!is.na(stations$SiteID))
IDstationHdata <- stations$SiteID[validStations] 
```

There are 6559 stations with valid coordinates within the UK-AIR (Air Information Resource, blue circles) database, for 221 (red circles) of them hourly data is available and their location is shown in the map below.

```R
library(leaflet)
leaflet(data = stationsNew) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, lat = ~Latitude, radius = 0.5) %>% 
  addCircleMarkers(lng = ~Longitude[validStations], 
  lat = ~Latitude[validStations], radius = 0.5, color="red")
```

Pollution data started to be collected in 1972, and building the time series for a given station can be done in one line of code:

```R
df <- get1Hdata("ABD", years=1999:2016)
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
