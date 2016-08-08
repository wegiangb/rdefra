# Create a compressed version for the dataset 'regions'
load("~/regions.rda")
tools::checkRdaFiles("~/regions.rda")

save(regions,
     file='~/Dropbox/Repos/r_rdefra/extraData/regions.rda',
     compress='xz')
# or, to compress in place: tools::resaveRdaFiles(paths = '~/Dropbox/Repos/r_rdefra/extraData/regions.rda', compress = 'xz')

# Create a compressed version for the dataset 'stations'
load("~/stations.rda")
tools::checkRdaFiles("~/stations.rda")

save(stations,
     file='~/Dropbox/Repos/r_rdefra/rdefra/data/stations.rda',
     compress='gzip')

# Run unit tests using testthat
devtools::test('rdefra')

# Run R CMD check or devtools::check()
devtools::check('rdefra')

# Generate a template for a README.Rmd
devtools::use_readme_rmd()
