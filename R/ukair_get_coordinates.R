#' Get Easting and Northing coordinates from DEFRA
#'
#' @description This function takes as input the UK AIR ID and returns Easting and Northing coordinates (British National Grid, EPSG:27700).
#'
#' @param ids contains the station identification code defined by DEFRA. It can be: a) an alphanumeric string, b) a vector of strings or c) a data frame. In the latter case, the column containing the codes should be named "UK.AIR.ID", all the other columns will be ignored.
#'
#' @details If the input is a data frame with some of the columns named "UK.AIR.ID", "Latitude" and "Longitude", the function only infills missing Latitude/Longitude values.
#'
#' @return A data.frame containing at least five columns named "UK.AIR.ID", "Easting", "Northing", "Latitude" and "Longitude".
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  # Case a: alphanumeric string
#'  ukair_get_coordinates("UKA12536")
#'
#'  # Case b: vector of strings
#'  ukair_get_coordinates(c("UKA15910", "UKA15956", "UKA16663", "UKA16097"))
#'
#'  # Case c: data frame
#'  ukair_get_coordinates(ukair_catalogue()[1:10,])
#'  }
#'

ukair_get_coordinates <- function(ids) {
  UseMethod("ukair_get_coordinates")
}

#' @export
ukair_get_coordinates.default <- function(ids) {
  stop("no available method for ", class(ids), call. = FALSE)
}

#' @export
ukair_get_coordinates.character <- function(ids){

  dfExtended <- id2coords(ids)

  # return a data.frame with coordinates
  return(tibble::as_tibble(dfExtended))

}

#' @export
ukair_get_coordinates.data.frame <- function(ids){

  nrows <- seq(1,dim(ids)[1])

  # By default we are expected to just infill missing coordinates
  if ("Latitude" %in% names(ids) & "Longitude" %in% names(ids)){
    nrows <- which(is.na(ids$Latitude) | is.na(ids$Longitude))
  }

  # otherwise, we force to extract coordinates for all the given IDs
  IDs <- as.character(ids$UK.AIR.ID[nrows])

  dfExtended <- id2coords(IDs)

  # return the new data.frame with infilled coordinates
  rows2fill <- which(ids$UK.AIR.ID %in% dfExtended$UK.AIR.ID)
  if(all(ids$UK.AIR.ID[rows2fill] == dfExtended$UK.AIR.ID)){
    ids$Latitude[rows2fill] <- dfExtended$Latitude
    ids$Longitude[rows2fill] <- dfExtended$Longitude
  }else{
    message("Check the order!")
  }

  suppressWarnings(output <- dplyr::left_join(ids, dfExtended,
                                              by = c("UK.AIR.ID",
                                                     "Latitude", "Longitude")))

  return(tibble::as_tibble(output))

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

#' Convert Easting and Northing to Latitude and Longitude
#'
#' @importFrom sp coordinates proj4string CRS spTransform
#'
#' @noRd
#'

id2coords <-function(IDs){

  # Get Easting and Northing
  enDF <- data.frame(t(sapply(IDs, ukair_get_coordinates_internal)))

  # Remove NAs
  rowsNoNAs <- which(!is.na(enDF$Easting) & !is.na(enDF$Northing))
  enDFnoNAs <- enDF[rowsNoNAs,]

  # Transform Easting and Northing to Latitude and Longitude
  # first, define spatial points
  sp::coordinates(enDFnoNAs) <- ~Easting+Northing
  sp::proj4string(enDFnoNAs) <- sp::CRS("+init=epsg:27700")
  # then, convert coordinates from British National Grid to WGS84
  latlon <- round(sp::spTransform(enDFnoNAs,
                                  sp::CRS("+init=epsg:4326"))@coords, 6)
  pt <- data.frame(latlon)
  names(pt) <- c("Longitude", "Latitude")

  dfExtended <- cbind(IDs[rowsNoNAs], enDFnoNAs@coords, pt)
  names(dfExtended)[1] <- "UK.AIR.ID"

  return(dfExtended)

}
