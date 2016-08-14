context("Data")

test_that("Are hourly data for station ABD/2014 available?", {

  site_id <- "ABD"
  years <- 2014

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste(rootURL, site_id, "_", years, ".csv", sep = "")

  expect_that(http_error(myURL), equals(FALSE))

  closeAllConnections()

})

test_that("Are hourly data for station BTR3 available?", {

  site_id = "BTR3"
  years <- 2012:2016

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste(rootURL, site_id, "_", years, ".csv", sep = "")

  con.url <- try(url(myURL[[1]]))

  expect_that(inherits(con.url, "try-error"), equals(FALSE))
  expect_that(length(myURL), equals(5))

  closeAllConnections()

})

test_that("Is data in the right format?", {

  site_id <- "ABD"
  years <- 2014

  x <- ukair_get_hourly_data(site_id, years)

  expect_that(names(x)[1] == "datetime", equals(TRUE))
  expect_that(names(x)[2] == "SiteID", equals(TRUE))
  closeAllConnections()

})

testthat::skip_on_cran()
test_that("Try and retrieve hourly data", {

  x <- ukair_get_hourly_data(site_id = "ABD", years = "2014")

  # dput(x, 'rdefra/inst/tests/testthat/example01')
  y <- as_tibble(dget(system.file(package = 'rdefra',
                                  'inst/tests/testthat/example01')))

  # This function returns TRUE wherever elements are the same, including NA's,
  # and FALSE everywhere else.
  compareNA <- function(v1,v2) {
    same <- (v1 == v2) | (is.na(v1) & is.na(v2))
    same[is.na(same)] <- FALSE
    return(same)
  }

  expect_that(x$SiteID[[1]] == "ABD", equals(TRUE))
  expect_that(x$datetime[1], equals(ymd_hms("2014-01-01 01:00:00 UTC")))
  expect_that(dim(x)[1] >= 8760, equals(TRUE))

  expect_that(all(compareNA(x[,1], y[,1])), equals(TRUE))
  expect_that(all(compareNA(x[,2], y[,2])), equals(TRUE))
  expect_that(all(compareNA(x[,3], y[,3])), equals(TRUE))
  expect_that(all(compareNA(x[,4], y[,4])), equals(TRUE))
  expect_that(all(compareNA(x[,5], y[,5])), equals(TRUE))
  expect_that(all(compareNA(x[,6], y[,6])), equals(TRUE))
  expect_that(all(compareNA(x[,7], y[,7])), equals(TRUE))
  expect_that(all(compareNA(x[,8], y[,8])), equals(TRUE))
  expect_that(all(compareNA(x[,9], y[,9])), equals(TRUE))
  expect_that(all(compareNA(x[,10], y[,10])), equals(TRUE))
  expect_that(all(compareNA(x[,11], y[,11])), equals(TRUE))
  expect_that(all(compareNA(x[,12], y[,12])), equals(TRUE))

  closeAllConnections()

})
