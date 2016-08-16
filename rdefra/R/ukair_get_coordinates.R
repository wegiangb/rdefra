#' Get Easting and Northing coordinates from DEFRA
#'
#' @importFrom httr GET content
#' @importFrom xml2 xml_find_all
#' @importFrom tibble as_tibble
#'
#' @description This function takes as input the UK AIR ID and returns Easting and Northing coordinates (British National Grid, EPSG:27700).
#'
#' @param IDs An alphanumeric string (or vector of strings) containing the UK AIR ID defined by DEFRA.
#'
#' @return A named vector containing Easting and Northing coordinates.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  ukair_get_coordinates("UKA12536")
#'  ukair_get_coordinates(c("UKA15910", "UKA15956", "UKA16663", "UKA16097"))
#'  }
#'

ukair_get_coordinates <- function(IDs){

  IDs <- as.character(IDs)

  enDF <- t(sapply(IDs, ukair_get_coordinates_internal))

  return(tibble::as_tibble(data.frame(enDF)))

}

#' Get Easting and Northing coordinates from DEFRA for 1 station
#'
#' @importFrom httr GET
#' @importFrom xml2 xml_find_all
#'
#' @noRd
#'

ukair_get_coordinates_internal <- function(uka_id){

  page_fetch <- httr::GET(url = "http://uk-air.defra.gov.uk",
                          path = "networks/site-info",
                          query = list(uka_id = uka_id))

  # download content
  page_content <- httr::content(page_fetch)

  # Extract tab row containing Easting and Northing
  page_tab <- xml2::xml_find_all(page_content,
                                 "//*[contains(@id,'tab_info')]")[[2]]

  # extract and clean all the columns
  vals <- trimws(xml2::xml_text(page_tab))
  # Extract string containing easting and northing
  x <- strsplit(vals, "Easting/Northing:")[[1]][2]
  x <- strsplit(x, "Latitude/Longitude:")[[1]][1]
  # split string into easting and northing and remove heading/trailing spaces
  en <- gsub("^\\s+|\\s+$", "", unlist(strsplit(x, ",")))

  if(!is.null(en)){

    enNumeric <- c("Easting" = as.numeric(en[1]),
                   "Northing" = as.numeric(en[2]))

  }else{

    enNumeric <- NULL
    message(paste("No coordinates available for station",uka_id))

  }

  return(enNumeric)

}
