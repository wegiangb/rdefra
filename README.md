


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

In the raw catalogue, 3806 stations contain valid coordinates. After scraping DEFRA's web pages, the number of stations with valid coordinates rises to 3806. In the figure below, blue circles show stations with available hourly data.


```r
validStations <- stations[which(!is.na(stations$SiteID)),]

library(leaflet)
leaflet(data = validStations) %>% addTiles() %>% 
  addCircleMarkers(lng = ~Longitude, 
                   lat = ~Latitude, 
                   radius = 0.5, color="blue", popup = ~SiteID)
```

<!--html_preserve--><div id="htmlwidget-1573" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-1573">{"x":{"calls":[{"method":"addTiles","args":["http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"maxNativeZoom":null,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"continuousWorld":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":null,"unloadInvisibleTiles":null,"updateWhenIdle":null,"detectRetina":false,"reuseTiles":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap\u003c/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA\u003c/a>"}]},{"method":"addCircleMarkers","args":[[57.15736,57.144555,57.133888,54.353728,52.50385,55.79216,54.861595,53.55593,53.56292,51.074793,51.391127,54.59965,54.591256,54.59653,54.572586,54.60537,52.437165,52.479724,52.49763,52.511722,52.512194,53.747751,53.715504,53.79046,53.80489,53.57232,52.93028,50.73957,53.79339,53.771245,51.489448,50.840836,50.82354,50.8235,51.45718,51.45603,51.462839,51.4071,53.53911,53.559029,55.862281,52.20237,51.54421,52.687298,51.27399,51.48178,54.894834,51.05625,51.374264,51.638094,53.230583,53.244131,53.231722,51.149617,52.411563,52.41345,52.394399,51.6538,55.001225,55.002818,53.518868,55.943197,55.070033,51.51895,50.805778,55.95197,55.945589,55.31531,50.725083,56.82266,55.85773,55.860414,55.872038,55.860936,55.85917,55.865782,53.46008,56.010319,56.013142,54.684233,55.944079,51.680579,51.5993,51.571078,54.334944,50.792287,51.165865,51.48965,50.82778,53.74479,53.74878,53.758971,57.481308,53.40337,52.28881,52.294884,53.80378,53.819972,52.638677,52.631348,52.619823,52.22174,60.13922,53.221373,53.22889,53.40845,53.446944,53.34633,51.37348,51.46603,51.52229,51.589769,51.49521,51.40555,51.49492,51.495483,51.45258,51.55877,51.58603,51.584128,51.48879,51.617333,51.49633,51.44541,51.52253,51.52105,51.49055,51.36789,51.42099,51.425286,51.45696,51.49467,54.43951,50.7937,51.892293,53.326444,53.48152,53.371306,53.369026,53.4785,52.554444,54.569297,53.162306,51.781784,54.97825,54.986405,51.601203,52.27349,52.271886,52.27349,52.63203,52.62817,52.614193,52.622,52.95473,52.969377,52.502436,51.751745,51.744806,55.657472,50.37167,51.5798,51.58395,50.82881,53.76559,51.45352,51.454896,51.45309,54.610735,51.45617,53.43186,53.48481,50.411463,50.4131,52.50431,52.52062,52.132417,53.58499,53.58634,53.579283,53.40495,53.37772,53.378622,53.41058,52.2944,51.03572,50.920265,50.90814,51.544206,51.480499,51.48199,51.77798,51.518167,52.071944,53.40994,53.40306,54.565819,54.516667,54.50918,52.980436,53.02821,50.916932,57.734456,54.906106,54.88361,54.91839,51.36636,51.62114,51.632696,51.47707,51.52253,52.58167,52.60821,52.605621,53.38928,51.4938,52.95049,54.616238,52.2985,53.365391,53.54914,53.49422,53.37287,52.58818,53.04222,50.5976,53.967513,53.951889],[-2.094278,-2.106472,-2.094198,-6.654558,-3.034178,-3.2429,-6.250873,-1.485153,-1.510436,-4.041924,-2.354155,-5.928833,-5.89546,-5.901667,-5.974944,-1.275039,-1.829999,-1.908078,-1.831498,-1.830583,-1.830861,-2.452724,-2.483815,-3.029283,-3.007175,-2.439583,-0.814722,-1.826744,-1.748694,-1.759774,-0.310121,-0.147572,-0.137281,-0.136924,-2.585622,-2.583519,-2.584482,0.020128,-2.289611,-2.293772,-3.205782,0.124456,-0.175269,-1.980821,1.098061,-3.17625,-2.945307,-2.68345,0.54797,-2.678731,-1.433611,-1.454946,-1.456944,-1.438228,-1.560228,-1.522133,-1.519612,-3.006953,-7.329115,-7.331179,-1.138073,-4.55973,-3.614233,-0.265617,0.271611,-3.195775,-3.182186,-3.206111,-3.532465,-5.101102,-4.255161,-4.245959,-4.270936,-4.238214,-4.258889,-4.243631,-2.472056,-3.704399,-3.710833,-2.450799,-4.734421,-3.133508,-0.068218,-1.325283,-0.80855,-3.196702,-0.167734,-0.308975,-0.170294,-0.338322,-0.341222,-0.305749,-4.241451,-1.752006,-1.533119,-1.542911,-1.546472,-1.576361,-1.124228,-1.133006,-1.127311,-2.736665,-1.185319,-0.534189,-0.537895,-2.980249,-2.9625,-2.844333,-0.291853,0.184806,-0.125889,-0.276223,-0.141655,0.018869,-0.180564,-0.178709,0.070766,-0.056592,-0.126486,-0.125254,-0.441614,-0.298777,-0.460861,-0.020139,-0.154611,-0.213492,-0.096667,-0.165489,-0.339647,-0.345606,-0.191164,-0.131931,-7.900328,0.18125,-0.46211,-9.903917,-2.237881,-2.239218,-2.24328,-2.2448,-0.772222,-1.220874,-3.144889,-4.691462,-1.610528,-1.595362,-2.977281,-0.885933,-0.879898,-0.885933,1.295019,1.291714,1.301976,1.299064,-1.146447,-1.188851,-2.003497,-1.257463,-1.260278,-3.196527,-4.142361,-3.76169,-3.770822,-1.068583,-2.680353,-0.95518,-0.940382,-0.944067,-1.0733,0.634889,-1.354444,-2.334139,-4.227678,-4.2303,-2.017629,-1.995556,-0.300306,-0.633015,-0.636811,-2.093786,-1.455815,-1.473306,-1.478096,-1.396139,1.463497,-2.735253,-1.463484,-1.395778,0.678408,-0.05955,-0.0623,1.049031,0.439548,-0.511111,-2.1582,-2.161111,-1.3159,-1.358547,-1.354319,-2.111898,-2.175133,-0.449548,-4.776583,-1.380081,-1.406878,-1.408391,-0.182789,-3.943329,-3.947374,0.317969,-0.042155,-2.010483,-2.033144,-2.030523,-2.615358,-0.200361,1.122017,-2.468931,0.290917,-2.73168,-2.638139,-2.506899,-3.022722,-2.129008,-3.002778,-3.71651,-1.086514,-1.075861],0.5,null,null,{"lineCap":null,"lineJoin":null,"clickable":true,"pointerEvents":null,"className":"","stroke":true,"color":"blue","weight":5,"opacity":0.5,"fill":true,"fillColor":"blue","fillOpacity":0.2,"dashArray":null},null,null,["ABD","ABD7","ABD8","ARM6","AH","ACTH","BALM","BAR2","BAR3","BPLE","BATH","BEL2","BEL4","BEL","BEL1","BIL","AGRN","BIRM","BIR2","BIR1","BIRT","BLAR","BLCB","BLAC","BLC2","BOLT","BOT","BORN","BRAD","BDMA","BRN","BRT3","BRIT","BRT2","BRIS","BRS2","BRS8","BY1","BURY","BURW","BUSH","CAM","CA1","CANK","CANT","CARD","CARL","MACK","CHAT","CHP","CHS6","CHLG","CHS7","CHBO","COAL","COV2","COV3","CWMB","DERY","DERR","DCST","DUMB","DUMF","EA8","EB","ED","ED3","ESK","EX","FW","GLA3","GLA","GGWR","GHSR","GLA4","GLKP","GLAZ","GRAN","GRA2","GDF","GKA8","CAE6","HG1","HAR","HM","HONI","HORE","HS1","HOVE","HULL","HUL2","HULR","INV2","LB","LEAM","LEAR","LEED","LED6","LEIR","LEIC","LECU","LEOM","LERW","LIN3","LINC","LIVR","LV6","LVP","A3","BEX","CLL2","BREN","BRI","BY2","CRD","CRD2","LON6","HK4","HG2","HG4","HRL","HR3","HIL","LW1","MY1","KC1","SK1","SUT3","TED","TED2","WA2","HORS","LN","LH","LUTR","MH","MAN3","MAHG","MAN4","MAN","MKTH","MID","MOLD","PEMB","NEWC","NCA3","NPT3","NTON","NTN3","NTO2","NOR2","NO10","NO12","NOR1","NOTT","NWBV","BOLD","OX","OX8","PEEB","PLYM","PT","PT4","PMTH","PRES","READ","REA5","REA1","REDC","ROCH","ROTH","ECCL","SASH","SALT","OLDB","WBRO","SDY","SCUN","SCN2","CW","SHBR","SHE2","SHDG","SHE","SIB","SOM","SA33","SOUT","SEND","SK5","SK2","OSY","HOPE","STEW","STOC","STK4","SOTR","EAGL","YARM","STKR","STOK","STOR","SV","SUND","SUN2","SUNR","SUT1","SWAN","SWA1","THUR","TH2","WAL","WAL2","WAL4","WAR","WL","WEYB","WC","WFEN","WSMR","WIG5","WIG3","TRAN","WOLV","WREX","YW","YK10","YK11"]]}],"limits":{"lat":[50.37167,60.13922],"lng":[-9.903917,1.463497]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
