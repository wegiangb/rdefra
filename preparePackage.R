# Generate a template for a README.Rmd
devtools::use_readme_rmd('rdefra')
# Generate a template for a Code of Conduct
devtools::use_code_of_conduct('rdefra')

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

save(stations,
     file='~/Dropbox/Repos/r_rdefra/rdefra/data/stations.rda',
     compress='gzip')

# Check spelling mistakes
devtools::spell_check('rdefra',
                      ignore = c('metres', 'catalogue', 'DEFRA', 'EMEP',
                                 'EPSG', 'WGS'))

# Run R CMD check
devtools::check('rdefra')

# Run unit tests using testthat
devtools::test('rdefra')
