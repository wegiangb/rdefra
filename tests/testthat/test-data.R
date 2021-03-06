context("Data")

test_that("Hourly data for station ABD/2014 should be available", {

  site_id <- "ABD"
  years <- 2014

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste(rootURL, site_id, "_", years, ".csv", sep = "")

  expect_that(httr::http_error(myURL), equals(FALSE))

  closeAllConnections()

})

test_that("Hourly data for station BTR3 should be available", {

  site_id <- "BTR3"
  years <- 2012:2016

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste(rootURL, site_id, "_", years, ".csv", sep = "")

  con.url <- try(url(myURL[[1]]))

  expect_that(inherits(con.url, "try-error"), equals(FALSE))
  expect_that(length(myURL), equals(5))

  closeAllConnections()

})

test_that("Metadata should be in the right format", {

  site_id <- "ABD"
  years <- 2000:2014

  x <- ukair_get_hourly_data(site_id, years)

  y <- attributes(x)$units

  expect_that("data.frame" %in% class(y), equals(TRUE))
  expect_that(all(names(y) == c("variable", "unit", "year")), equals(TRUE))

})

test_that("Data should be in the right format", {

  site_id <- "ABD"
  years <- 2014

  x <- ukair_get_hourly_data(site_id, years)

  expect_that(all(names(x)[1:2] == c("datetime", "SiteID")), equals(TRUE))

  closeAllConnections()

})

test_that("Try and retrieve hourly data", {

  skip_on_cran()

  x <- ukair_get_hourly_data(site_id = "ABD", years = "2014")

  expect_that(dim(x)[1] >= 8760, equals(TRUE))

  expect_that(x[1,1], equals(structure(list(
    datetime = structure(1388538000,
                         class = c("POSIXct", "POSIXt"),
                         tzone = "UTC")),
    .Names = "datetime",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,2], equals(structure(list(
    SiteID = structure(1L,
                       .Label = "ABD",
                       class = "factor")),
    .Names = "SiteID",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,3], equals(structure(list(
    PM.sub.10..sub..particulate.matter..Hourly.measured. = 16.1),
    .Names = "PM.sub.10..sub..particulate.matter..Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,4], equals(structure(list(
    Nitric.oxide = 1.6402),
    .Names = "Nitric.oxide",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,5], equals(structure(list(
    Nitrogen.dioxide = 11.28311),
    .Names = "Nitrogen.dioxide",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,6], equals(structure(list(
    Nitrogen.oxides.as.nitrogen.dioxide = 13.79805),
    .Names = "Nitrogen.oxides.as.nitrogen.dioxide",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,7], equals(structure(list(
    Non.volatile.PM.sub.10..sub...Hourly.measured. = 15.1),
    .Names = "Non.volatile.PM.sub.10..sub...Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,8], equals(structure(list(
    Non.volatile.PM.sub.2.5..sub...Hourly.measured. = 7.3),
    .Names = "Non.volatile.PM.sub.2.5..sub...Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,9], equals(structure(list(
    Ozone = 54.94827), .Names = "Ozone",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,10], equals(structure(list(
    PM.sub.2.5..sub..particulate.matter..Hourly.measured. = 9.2),
    .Names = "PM.sub.2.5..sub..particulate.matter..Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,11], equals(structure(list(
    Volatile.PM.sub.10..sub...Hourly.measured. = 1),
    .Names = "Volatile.PM.sub.10..sub...Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))
  expect_that(x[1,12], equals(structure(list(
    Volatile.PM.sub.2.5..sub...Hourly.measured. = 1.9),
    .Names = "Volatile.PM.sub.2.5..sub...Hourly.measured.",
    row.names = c(NA, -1L),
    class = c("tbl_df", "tbl", "data.frame"))))

  closeAllConnections()

})
