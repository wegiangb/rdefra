#' Get catalogue of DEFRA stations
#'
#' @description This function fetches the catalogue of monitoring stations from DEFRA's website.
#'
#' @param site_name This is the name of a specific site (by default this is left blank to get info on all the available sites.
#' @param pollutant This is a number from 1 to 99.
#' @param group_id This is the identification number of a group of stations.
#' @param closed This is "true" to include closed stations, "false" otherwise.
#' @param country_id This is the identification number of the country, it can be a number from 1 to 9. Default is 9999, which means all the countries.
#' @param region_id This is the identification number of the region, it can be a number from 1 to 9. Default is 9999, which means all the regions.
#' @param location_type This is the identification number of the location, it can be a number from 1 to 9. Default is 9999, which means all the locations.
#' @param search default is "Search+Network".
#' @param view default is "advanced".
#' @param action default is "results".
#'
#' @details \code{Pollutant} is defined based on the following convention: 1 = ozone, 2 = .
#'
#' @return A named vector containing Easting and Northing coordinates.
#'
#' @examples
#' # catalogue()
#'

catalogue <- function(site_name = "", pollutant = 9999, group_id = 9999,
                      closed = "true", country_id = 9999, region_id = 9999,
                      location_type = 9999, search = "Search+Network",
                      view = "advanced", action = "results"){

  # library(RCurl)
  # library(XML)

  rootURL <- "http://uk-air.defra.gov.uk/networks/find-sites?"

  myURL <- paste(rootURL, "&site_name=", site_name, "&pollutant=", pollutant,
                 "&group_id=", group_id, "&closed=", closed, "&country_id=",
                 country_id, "&region_id=", region_id, "&location_type=",
                 location_type, "&search=", search, "&view=",
                 view, "&action=", action, sep = "")

  # download html
  html <- getURL(myURL, followlocation = TRUE)

  # parse html
  doc = htmlParse(html, asText=TRUE)
  hrefs <- xpathSApply(doc, '//*[@id="center-2col"]/p[3]/a', xmlGetAttr, 'href')

  df <- read.csv(hrefs)

  return(df)

}
