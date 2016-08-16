context("Metadata")

test_that("DEFRA should be running", {

  site_name = ""; pollutant = 9999; group_id = 9999
  closed = "true"; country_id = 9999; region_id = 9999
  location_type = 9999

  catalogue_fetch <- GET(url = "http://uk-air.defra.gov.uk",
                         path = "networks/find-sites",
                         query = list(site_name = site_name,
                                      pollutant = pollutant,
                                      group_id = group_id,
                                      closed = closed,
                                      country_id = country_id,
                                      region_id = region_id,
                                      location_type = location_type,
                                      search = "Search+Network",
                                      view = "advanced",
                                      action = "results"))

  # download html
  expect_that(http_error(catalogue_fetch), equals(FALSE))

  closeAllConnections()

})

test_that("The metadata catalogue should be up-to-date (at least 6568 stations).", {

  x <- ukair_catalogue()

  expect_that(dim(x)[1] >= 6568, equals(TRUE))

  closeAllConnections()

})

test_that("Find easting and northing coordinates of a single site: UKA12536.", {

  uka_id <- "UKA12536"

  x <- ukair_get_coordinates(uka_id)

  expect_that(all(names(x) == c("Easting", "Northing")), equals(TRUE))
  expect_that(x[[1]] == 509500, equals(TRUE))
  expect_that(x[[2]] == 201800, equals(TRUE))

  closeAllConnections()

})

test_that("Find easting and northing coordinates of a single site: UKA15910.", {

  uka_id <- "UKA15910"

  x <- ukair_get_coordinates(uka_id)

  expect_that(all(names(x) == c("Easting", "Northing")), equals(TRUE))
  expect_that(x[[1]] == 487639, equals(TRUE))
  expect_that(x[[2]] == 158876, equals(TRUE))

  closeAllConnections()

})

test_that("Find easting and northing coordinates of multiple sites.", {

  IDs <- c("UKA15910", "UKA15956", "UKA16663", "UKA16097")
  x <- ukair_get_coordinates(IDs)

  expect_that(all(names(x) == c("Easting", "Northing")), equals(TRUE))
  expect_that(all(x[[1]] == c(487639, 495503, 488750, 558864)), equals(TRUE))
  expect_that(all(x[[2]] == c(158876, 158871, 159750, 146166)), equals(TRUE))

  closeAllConnections()

})

test_that("Find site identification number from the UK AIR ID string.", {

  uka_id <- "UKA00399"
  x <- ukair_get_site_id(uka_id)

  expect_that(x == "ABD", equals(TRUE))

  closeAllConnections()

})
