context("Metadata")

test_that("DEFRA should be running", {

  site_name = ""; pollutant = 9999; group_id = 9999
  closed = "true"; country_id = 9999; region_id = 9999
  location_type = 9999

  catalogue_fetch <- httr::GET(url = "http://uk-air.defra.gov.uk",
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

  # URL: catalogue_fetch[[1]]

  # download html
  expect_that(http_error(catalogue_fetch), equals(FALSE))

  closeAllConnections()

})

test_that("Up-to-date metadata catalogue should have at least 6569 stations.", {

  x <- ukair_catalogue()

  expect_that(dim(x)[1] >= 6568, equals(TRUE))

  closeAllConnections()

})

test_that("Find site identification number from the UK AIR ID string.", {

  uka_id <- "UKA00399"
  x <- ukair_get_site_id(uka_id)

  expect_that(x == "ABD", equals(TRUE))

  expect_that(is.na(ukair_get_site_id("UKA11248")), equals(TRUE))

  closeAllConnections()

})

skip_on_travis()
test_that("Find easting and northing coordinates of site UKA12536.", {

  uka_id <- "UKA12536"

  x <- ukair_get_coordinates(uka_id)

  expect_that(all(names(x) == c("UK.AIR.ID", "Easting", "Northing",
                                "Longitude", "Latitude")), equals(TRUE))
  expect_that(x$Longitude == -0.416786, equals(TRUE))
  expect_that(x$Latitude == 51.704266, equals(TRUE))

  closeAllConnections()

})

# test_that("Find easting and northing coordinates of site UKA15910.", {
#
#   uka_id <- "UKA15910"
#
#   x <- ukair_get_coordinates(uka_id)
#
#   expect_that(all(names(x) == c("UK.AIR.ID", "Easting", "Northing",
#                                 "Longitude", "Latitude")), equals(TRUE))
#   expect_that(x$Longitude == -0.743709, equals(TRUE))
#   expect_that(x$Latitude == 51.322247, equals(TRUE))
#
#   closeAllConnections()
#
# })
#
# test_that("Find easting and northing coordinates of multiple sites.", {
#
#   IDs <- c("UKA15910", "UKA15956", "UKA16663", "UKA16097")
#   x <- ukair_get_coordinates(IDs)
#
#   expect_that(all(names(x) == c("UK.AIR.ID", "Easting", "Northing",
#                                 "Longitude", "Latitude")), equals(TRUE))
#   expect_that(all(x$Longitude == c(-0.743709, -0.63089, -0.727552, 0.272107)),
#               equals(TRUE))
#   expect_that(all(x$Latitude == c(51.322247, 51.320938, 51.329932, 51.192638)),
#               equals(TRUE))
#
#   closeAllConnections()
#
# })
#
# test_that("Infill missing coordinates from data frame.", {
#
#   stations <- ukair_catalogue()[1:10,]
#   x <- ukair_get_coordinates(stations)
#
#   expect_that(all(is.na(x[,c("Latitude", "Longitude")])), equals(FALSE))
#
#   closeAllConnections()
#
# })
