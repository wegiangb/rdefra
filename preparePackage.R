# Generate a template for a README.Rmd
devtools::use_readme_rmd('rdefra')

# Generate a template for a Code of Conduct
devtools::use_code_of_conduct('rdefra')

# Check spelling mistakes
devtools::spell_check('rdefra',
                      ignore = c('metres', 'catalogue', 'DEFRA', 'EMEP',
                                 'EPSG', 'WGS'))

# Run R CMD check
devtools::check('rdefra')
# The above will also run the unit tests using testthat
# devtools::test('rdefra')

# Create a compressed version for the dataset 'regions'
load("~/Dropbox/Repos/r_rdefra/extraData/regions.rda")
tools::checkRdaFiles("~/Dropbox/Repos/r_rdefra/extraData/regions.rda")

save(regions,
     file='~/Dropbox/Repos/r_rdefra/extraData/regions.rda',
     compress='xz')
# or, to compress in place: tools::resaveRdaFiles(paths = '~/Dropbox/Repos/r_rdefra/extraData/regions.rda', compress = 'xz')

# Create a compressed version for the dataset 'stations'
load("~/Dropbox/Repos/r_rdefra/rdefra/data/stations.rda")
tools::checkRdaFiles("~/Dropbox/Repos/r_rdefra/rdefra/data/stations.rda")

stations_raw <- ukair_catalogue()

stations <- ukair_get_coordinates(stations_raw, en = TRUE, force_coords = TRUE)
length(which(!is.na(stations$Latitude)))
length(which(!is.na(stations$Longitude)))

stations$SiteID <- ukair_get_site_id(stations$UK.AIR.ID)
length(which(!is.na(stations$SiteID)))

save(stations,
     file='~/r_rdefra/rdefra/data/stations.rda',
     compress='xs')

# Build README (better to use rmarkdown than knitr!)
rmarkdown::render("README.Rmd", "all")

# Build vignette (better to use rmarkdown than knitr!)
rmarkdown::render("rdefra/vignettes/rdefra_vignette.Rmd", "all")

# Create the Appveyor config file for continuous integration on Windows
devtools::use_appveyor(pkg = "fuse")
# move the newly created appveyor.yml to the root directory and modify it
