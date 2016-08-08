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

  con.url <- try(url(myURL))

  expect_that(inherits(con.url, "try-error"), equals(FALSE))

  closeAllConnections()

})
