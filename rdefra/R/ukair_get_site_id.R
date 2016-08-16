#' Get site IDs for DEFRA stations
#'
#' @description Given the UK AIR ID (from the \code{ukair_catalogue()}), this function fetches the catalogue of monitoring stations from DEFRA's website.
#'
#' @param IDs An alphanumeric string (or vector of strings) containing the UK AIR ID defined by DEFRA.
#'
#' @return A named vector containing the site IDs.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  ukair_get_site_id("UKA00399")
#'  }
#'

ukair_get_site_id <- function(IDs){

  IDs <- as.character(IDs)

  enDF <- t(sapply(IDs, ukair_get_site_id_internal))

  return(as.character(enDF))

}

#' Internal function to get site IDs for 1 DEFRA station
#'
#' @importFrom httr GET content
#' @importFrom xml2 xml_attr xml_find_all
#'
#' @noRd
#'

ukair_get_site_id_internal <- function(uka_id){

  page_fetch <- httr::GET(url = "http://uk-air.defra.gov.uk",
                          path = "networks/site-info",
                          query = list(uka_id = uka_id,
                                       search = "View+Site+Information",
                                       action = "site"))

  # download content
  page_content <- httr::content(page_fetch)

  # Extract tab row containing Easting and Northing
  page_tab <- xml2::xml_find_all(page_content, '//*[@id="g4"]/td[4]/a[4]')
  hrefs <- xml2::xml_attr(page_tab, 'href')

  if(is.null(hrefs)){

    siteID <- NA
    message("No ID available for the specified station")

  }else{

      siteID <- gsub("^.*\\=", "", hrefs)

  }

  return(siteID)

}
