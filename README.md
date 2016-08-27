


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

# Dependencies & Installation

## Dependencies

The rdefra package depends on two things: 

* The Geospatial Data Abstraction Library (gdal). If you use linux/ubuntu, this can be installed with the following command: `sudo apt-get install -y r-cran-rgdal`. 

* Some additional CRAN packages. Check for missing dependencies and install them using the commands below:


```r
packs <- c('httr', 'xml2', 'lubridate', 'tibble', 'dplyr', 'sp', 'devtools',
           'leaflet', 'zoo', 'testthat')
new.packages <- packs[!(packs %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
```

## Installation

You can install this package from CRAN:


```r
install.packages("rdefra")
```


Or you can install the development version from Github with [devtools](https://github.com/hadley/devtools):


```r
devtools::install_github("cvitolo/r_rdefra", subdir = "rdefra")
```

Load the rdefra package:


```r
library(rdefra)
```

# Functions

The package logic assumes that the user access the UK-AIR database in two steps:

1. Browse the catalogue of available stations and selects some stations of interest.
2. Retrieves data for the selected stations.

## Get metadata catalogue
DEFRA monitoring stations can be downloaded and filtered using the function `ukair_catalogue()` with no input parameters, as in the example below. 


```r
# Get full catalogue
stations_raw <- ukair_catalogue()
```

The same function, can be used to filter the catalogue using the following input parameters:

* `site_name` IDs of specific site (UK.AIR.ID). By default this is left blank to get info on all the available sites.
* `pollutant` This is an integer between 1 and 10. Default is 9999, which means all the pollutants.
* `group_id` This is the identification number of a group of stations. Default is 9999 which means all available networks.
* `closed` This is "true" to include closed stations, "false" otherwise.
* `country_id` This is the identification number of the country, it can be an integer between 1 and 6. Default is 9999, which means all the countries.
* `region_id` This is the identification number of the region. 1 = Aberdeen City, etc. (for the full list see https://uk-air.defra.gov.uk/). Default is 9999, which means all the local authorities.


```r
stations_EnglandOzone <- ukair_catalogue(pollutant = 1, country_id = 1)
```

The example above shows how to retrieve the 104 stations in England in which ozone is measured.

## Get missing coordinates
Locating a station is extremely important to be able to carry out any spatial analysis. If coordinates are missing, for some stations in the catalogue, it might be possible to retrieve Easting and Northing (coordinates in the British National Grid) from DEFRA's web pages. Get E and N, transform them to latitude and longitude and populate the missing coordinates using the code below.


```r
# Scrape DEFRA website to get Easting/Northing
stations <- ukair_get_coordinates(stations_raw)
```

## Check hourly data availability
Pollution data started to be collected in 1972 and consists of hourly concentration of various species (in &#956;g/m<sup>3</sup>), such as ozone (O<sub>3</sub>), particulate matters (PM<sub>2.5</sub> and PM<sub>10</sub>), nitrogen dioxide (NO<sub>2</sub>), sulphur dioxide (SO<sub>2</sub>), and so on.

The ID under which they are available differs from the UK.AIR.ID. The catalogue does not contain this additional station ID (called SiteID hereafter) but DEFRA's web pages contain references to both the UK.AIR.ID and the SiteID. The function below uses as input the UK.AIR.ID and outputs the SiteID, if available. 


```r
stations$SiteID <- ukair_get_site_id(stations$UK.AIR.ID)
```

## Get hourly data

The time series for a given station can be retrieved in one line of code:


```r
# Get 1 year of hourly ozone data from London Marylebone Road monitoring station
df <- ukair_get_hourly_data("MY1", years=2015)

library(zoo)
plot(zoo(x = df$Ozone, order.by = as.POSIXct(df$datetime)), 
     main = "", xlab = "", ylab = expression(paste("Ozone concentration [",
                                                    mu, "g/m^3]")))
```

![](README_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

Highest concentrations seem to happen in late spring and at the beginning of summer. In order to check whether this happens every year, we can download multiple years of data and then compare them.


```r
# Get 3 years of hourly ozone data from the same monitoring station
years <- 2013:2015
df <- ukair_get_hourly_data("MY1", years)
df$year <- lubridate::year(df$datetime)

par(mfrow=c(3,1), mai = c(0.3, 0.6, 0.2, 0.2)) 
for(yearDF in years){
  df1 <- df[which(df$year == yearDF),]
  plot(zoo(x = df1$Ozone, order.by = as.POSIXct(df1$datetime)), 
     main = "", xlab = "", ylab = yearDF)
}
```

![](README_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

# Cached catalogue

For convenience, a cached version of the catalogue (last updated in August 2016) is included in the package and can be loaded using the following command:


```r
data('stations')
```

The cached catalogue contains all the available site IDs and coordinates and can be quickly used as lookup table to find out the correspondence between the UK.AIR.ID and SiteID, as well as to investigate station characteristics. 

# Applications

## Plotting stations' locations 

In the raw catalogue, 3806 stations contain valid coordinates. After scraping DEFRA's web pages, the number of stations with valid coordinates rises to 6567. In the figure below, blue circles show stations with available hourly data.


```r
validStations <- stations[which(!is.na(stations$SiteID)),]

library(leaflet)
leaflet(data = validStations) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, 
                   lat = ~Latitude, 
                   radius = 0.5, color="blue", popup = ~SiteID)
```

<!--html_preserve--><div id="htmlwidget-8201" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-8201">{"x":{"calls":[{"method":"addTiles","args":["http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"maxNativeZoom":null,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"continuousWorld":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":null,"unloadInvisibleTiles":null,"updateWhenIdle":null,"detectRetina":false,"reuseTiles":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap\u003c/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA\u003c/a>"}]},{"method":"addCircleMarkers","args":[[57.15736,57.144559,57.133888,54.353726,52.503849,55.792159,54.861595,53.555934,53.562916,51.07479,51.391127,54.599654,54.591255,54.596531,54.572586,54.60537,52.437165,52.47972,52.497634,52.51172,52.512197,53.74775,53.715504,53.790456,53.804891,53.572321,52.930276,50.739569,53.793391,53.771249,51.489449,50.84084,50.823543,50.823502,51.457177,51.456028,51.462839,51.407103,53.539108,53.559025,55.862284,52.202366,51.544207,52.687301,51.273989,51.481782,54.894834,51.056253,51.374265,51.638097,53.23058,53.244127,53.231722,51.149613,52.411567,52.413452,52.3944,51.653796,55.001226,55.002818,53.518872,55.943199,55.070033,51.518951,50.805774,55.951968,55.945585,55.315312,50.725081,56.822663,55.857733,55.860418,55.872038,55.860936,55.859174,55.865781,53.460084,56.010322,56.013145,54.684236,55.944082,51.680579,51.599299,51.571074,54.334945,50.792287,51.165866,51.489649,50.82778,53.744793,53.74878,53.758971,57.481309,53.403369,52.28881,52.294881,53.80378,53.819969,52.63868,52.631345,52.619823,52.221739,60.139221,53.221377,53.228892,53.408455,53.446946,53.346328,51.373479,51.466029,51.522287,51.589769,51.49521,51.405551,51.494921,51.495485,51.452577,51.558767,51.586026,51.584127,51.488789,51.617335,51.496326,51.445407,51.522527,51.521046,51.49055,51.36789,51.42099,51.425282,51.456956,51.494669,54.439513,50.793702,51.892293,53.32644,53.481517,53.371306,53.369023,53.478501,52.554445,54.569301,53.162302,51.781781,54.978246,54.986401,51.601203,52.273493,52.271889,52.273493,52.632032,52.628166,52.614192,52.621999,52.954732,52.969376,52.502437,51.751742,51.74481,55.657473,50.371673,51.579801,51.583953,50.828812,53.765593,51.453521,51.454899,51.453088,54.610735,51.456172,53.43186,53.48481,50.411462,50.413103,52.504306,52.520624,52.132418,53.58499,53.586337,53.579286,53.404949,53.37772,53.378622,53.410577,52.294399,51.035724,50.920267,50.908138,51.544205,51.480499,51.481992,51.777977,51.518166,52.071943,53.409939,53.403059,54.565822,54.516663,54.509181,52.98044,53.028213,50.916936,57.734457,54.906109,54.883614,54.91839,51.366361,51.62114,51.6327,51.477069,51.522529,52.581673,52.608207,52.605619,53.389284,51.493796,52.950489,54.616237,52.298497,53.365392,53.549144,53.494224,53.37287,52.588184,53.042218,50.597605,53.967513,53.951891],[-2.094275,-2.106471,-2.094198,-6.654556,-3.034177,-3.242898,-6.250874,-1.48516,-1.510439,-4.041925,-2.354148,-5.928832,-5.895453,-5.901673,-5.974941,-1.275033,-1.829999,-1.908078,-1.831504,-1.830581,-1.830859,-2.452721,-2.483815,-3.029287,-3.007182,-2.439578,-0.814715,-1.826743,-1.748701,-1.759773,-0.310128,-0.147571,-0.13728,-0.136927,-2.58562,-2.583518,-2.584483,0.020131,-2.289611,-2.293777,-3.205783,0.124449,-0.175262,-1.980814,1.098062,-3.176253,-2.94531,-2.683448,0.547974,-2.678724,-1.433612,-1.454952,-1.456937,-1.438227,-1.560224,-1.522127,-1.519614,-3.006947,-7.329116,-7.331176,-1.138072,-4.559725,-3.614226,-0.265623,0.271608,-3.195774,-3.182191,-3.206111,-3.532466,-5.101098,-4.255161,-4.245952,-4.270937,-4.238215,-4.258888,-4.243625,-2.472049,-3.704397,-3.710826,-2.450802,-4.734413,-3.133508,-0.068211,-1.325281,-0.80855,-3.196697,-0.167734,-0.308968,-0.170296,-0.338315,-0.341221,-0.305747,-4.241449,-1.752011,-1.533115,-1.542905,-1.546465,-1.576366,-1.124229,-1.133005,-1.127309,-2.736659,-1.185315,-0.534196,-0.537894,-2.98025,-2.962495,-2.844337,-0.291858,0.184807,-0.125889,-0.276222,-0.141651,0.018869,-0.180559,-0.178707,0.070773,-0.056599,-0.126486,-0.12525,-0.441617,-0.298781,-0.460866,-0.020143,-0.154608,-0.213493,-0.096666,-0.165486,-0.33965,-0.345608,-0.191166,-0.131934,-7.900322,0.181256,-0.462111,-9.903923,-2.237879,-2.239218,-2.243278,-2.244793,-0.772225,-1.220872,-3.144889,-4.69146,-1.61053,-1.595356,-2.977281,-0.885938,-0.879896,-0.885938,1.295023,1.291717,1.301971,1.299057,-1.146454,-1.188856,-2.003492,-1.257463,-1.260285,-3.196521,-4.142368,-3.761696,-3.77082,-1.068584,-2.680346,-0.955186,-0.940388,-0.944071,-1.0733,0.634891,-1.35445,-2.334133,-4.227672,-4.230297,-2.017635,-1.99555,-0.300312,-0.633011,-0.636805,-2.093784,-1.455817,-1.473301,-1.4781,-1.396142,1.4635,-2.735259,-1.463484,-1.39578,0.678414,-0.059554,-0.062299,1.049027,0.439541,-0.511114,-2.158201,-2.161108,-1.3159,-1.358553,-1.354315,-2.111899,-2.175138,-0.449542,-4.776588,-1.380078,-1.406875,-1.408392,-0.182786,-3.943325,-3.947374,0.317971,-0.042156,-2.010479,-2.033138,-2.030523,-2.615357,-0.200354,1.122012,-2.468926,0.290923,-2.731673,-2.63814,-2.506901,-3.022721,-2.129006,-3.002779,-3.716504,-1.086511,-1.075866],0.5,null,null,{"lineCap":null,"lineJoin":null,"clickable":true,"pointerEvents":null,"className":"","stroke":true,"color":"blue","weight":5,"opacity":0.5,"fill":true,"fillColor":"blue","fillOpacity":0.2,"dashArray":null},null,null,["ABD","ABD7","ABD8","ARM6","AH","ACTH","BALM","BAR2","BAR3","BPLE","BATH","BEL2","BEL4","BEL","BEL1","BIL","AGRN","BIRM","BIR2","BIR1","BIRT","BLAR","BLCB","BLAC","BLC2","BOLT","BOT","BORN","BRAD","BDMA","BRN","BRT3","BRIT","BRT2","BRIS","BRS2","BRS8","BY1","BURY","BURW","BUSH","CAM","CA1","CANK","CANT","CARD","CARL","MACK","CHAT","CHP","CHS6","CHLG","CHS7","CHBO","COAL","COV2","COV3","CWMB","DERY","DERR","DCST","DUMB","DUMF","EA8","EB","ED","ED3","ESK","EX","FW","GLA3","GLA","GGWR","GHSR","GLA4","GLKP","GLAZ","GRAN","GRA2","GDF","GKA8","CAE6","HG1","HAR","HM","HONI","HORE","HS1","HOVE","HULL","HUL2","HULR","INV2","LB","LEAM","LEAR","LEED","LED6","LEIR","LEIC","LECU","LEOM","LERW","LIN3","LINC","LIVR","LV6","LVP","A3","BEX","CLL2","BREN","BRI","BY2","CRD","CRD2","LON6","HK4","HG2","HG4","HRL","HR3","HIL","LW1","MY1","KC1","SK1","SUT3","TED","TED2","WA2","HORS","LN","LH","LUTR","MH","MAN3","MAHG","MAN4","MAN","MKTH","MID","MOLD","PEMB","NEWC","NCA3","NPT3","NTON","NTN3","NTO2","NOR2","NO10","NO12","NOR1","NOTT","NWBV","BOLD","OX","OX8","PEEB","PLYM","PT","PT4","PMTH","PRES","READ","REA5","REA1","REDC","ROCH","ROTH","ECCL","SASH","SALT","OLDB","WBRO","SDY","SCUN","SCN2","CW","SHBR","SHE2","SHDG","SHE","SIB","SOM","SA33","SOUT","SEND","SK5","SK2","OSY","HOPE","STEW","STOC","STK4","SOTR","EAGL","YARM","STKR","STOK","STOR","SV","SUND","SUN2","SUNR","SUT1","SWAN","SWA1","THUR","TH2","WAL","WAL2","WAL4","WAR","WL","WEYB","WC","WFEN","WSMR","WIG5","WIG3","TRAN","WOLV","WREX","YW","YK10","YK11"]]}],"limits":{"lat":[50.371673,60.139221],"lng":[-9.903923,1.4635]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## Analyse the spatial distribution of the monitoring stations

Below are two plots showing the spatial distribution of the monitoring stations. These are concentrated largely in urban areas and used to estimate the background level of concentration of pollutants.

![](README_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](README_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

## Use multiple cores to speed up data retrieval from numerous sites

Using parallel processing, the acquisition of data from hundreds of sites takes only few minutes:


```r
library(parallel)
library(dplyr)

# Calculate the number of cores
no_cores <- detectCores() - 1
 
# Initiate cluster
cl <- makeCluster(no_cores)

system.time(myList <- parLapply(cl, stations$SiteID[validStations], 
ukair_get_hourly_data, years=1999:2016))

stopCluster(cl)

df <- bind_rows(myList)
```

# Meta

* Please [report any issues or bugs](https://github.com/kehraProject/r_rdefra/issues).
* License: [GPL-3](https://opensource.org/licenses/GPL-3.0)
* Get citation information for `rdefra` in R doing `citation(package = 'rdefra')`

<br/>

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
