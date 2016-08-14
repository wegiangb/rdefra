#' Get Easting and Northing coordinates from DEFRA
#'
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

  enDF <- do.call(rbind, lapply(X = as.list(IDs), FUN = ukair_get_coordinates_internal))

  return(tibble::as_tibble(data.frame(enDF)))

}

#' Get Easting and Northing coordinates from DEFRA for 1 station
#'
#' @importFrom httr GET
#' @importFrom XML htmlParse xpathSApply xmlValue
#'
#' @noRd
#'

ukair_get_coordinates_internal <- function(uka_id){

  rootURL <- "http://uk-air.defra.gov.uk/networks/site-info?uka_id="

  myURL <- paste(rootURL, uka_id, sep = "")

  # download html
  html <- httr::GET(myURL)

  # parse html
  doc = XML::htmlParse(html, asText=TRUE)
  plain.text <- XML::xpathSApply(doc, '//*[@id="tab_info"]/p[8]/text()',
                                 XML::xmlValue)

  # split string into easting and northing and remove heading/trailing spaces
  en <- gsub("^\\s+|\\s+$", "", unlist(strsplit(plain.text, ",")))

  return(c("Easting" = as.numeric(en[1]), "Northing" = as.numeric(en[2])))

}
