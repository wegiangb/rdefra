context("Metadata")

test_that("Is the DEFRA server running?", {

  site_name = ""; pollutant = 9999; group_id = 9999
  closed = "true"; country_id = 9999; region_id = 9999
  location_type = 9999; search = "Search+Network"
  view = "advanced"; action = "results"

  rootURL <- "http://uk-air.defra.gov.uk/networks/find-sites?"

  myURL <- paste(rootURL, "&site_name=", site_name, "&pollutant=", pollutant,
                 "&group_id=", group_id, "&closed=", closed, "&country_id=",
                 country_id, "&region_id=", region_id, "&location_type=",
                 location_type, "&search=", search, "&view=",
                 view, "&action=", action, sep = "")

  # download html
  html <- GET(myURL)
  expect_that(http_error(html), equals(FALSE))

  closeAllConnections()

})

test_that("Is metadata catalogue up-to-date? If so, there should be at least 6568 stations.", {

  x <- ukair_catalogue()

  expect_that(dim(x)[1] >= 6568, equals(TRUE))

  closeAllConnections()

})

test_that("Find easting and northing coordinates of a single site.", {

  x <- ukair_get_coordinates("UKA12536")

  expect_that(all(names(x) == c("Easting", "Northing")), equals(TRUE))
  expect_that(x[[1]] == 509500, equals(TRUE))
  expect_that(x[[2]] == 201800, equals(TRUE))

  y <- ukair_get_coordinates(c("UKA15910", "UKA15956", "UKA16663", "UKA16097"))

  closeAllConnections()

})

test_that("Find easting and northing coordinates of multiple sites.", {

  x <- ukair_get_coordinates(c("UKA15910", "UKA15956", "UKA16663", "UKA16097"))

  expect_that(all(names(x) == c("Easting", "Northing")), equals(TRUE))
  expect_that(all(x[[1]] == c(487639, 495503, 488750, 558864)), equals(TRUE))
  expect_that(all(x[[2]] == c(158876, 158871, 159750, 146166)), equals(TRUE))

  closeAllConnections()

})

test_that("Find site identification number from the UK AIR ID string.", {

  x <- ukair_get_site_id("UKA00399")

  expect_that(x == "ABD", equals(TRUE))

  closeAllConnections()

})
