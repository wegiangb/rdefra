#' Get hourly data for DEFRA stations
#'
#' @description This function fetches hourly data from DEFRA's air pollution monitoring stations.
#'
#' @param site_id This is the ID of a specific site.
#' @param years Years for which data should be downloaded.
#' @param keep_units logical set to FALSE by default. If set to TRUE the output becomes a list with two elements: data and units.
#'
#' @details The measurements are generally in \eqn{\mu g/m^3} (micrograms per cubic metre). To check the units, refer to the table of attributes (see example below). Please double check the units on the DEFRA website, as they might change over time.
#'
#' @return A data.frame containing hourly pollution data.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  # Get data for 1 year
#'  output <- ukair_get_hourly_data("ABD", 2014)
#'
#'  # Get data for multiple years
#'  output <- ukair_get_hourly_data("ABD", 2014:2016)
#'
#'  }
#'

ukair_get_hourly_data <- function(site_id = NULL, years = NULL,
                                  keep_units = FALSE){

  if (is.null(site_id)) {

    stop("Please insert a valid ID.
         \nFor a list of valid IDs check the SiteID column in the cached
         catalogue: \n data(stations) \n na.omit(unique(stations$SiteID))")

  }

  if (is.null(years)) {

    stop("Please insert a valid year (or sequence of years).")

  }

  data <- vector('list', length = length(years))
  if (keep_units == TRUE) unitsDATA <- vector('list', length = length(years))
  id <- 1

  for(myYear in as.list(years)){

    id <- which(as.list(years) == myYear)

    df_tmp <- ukair_get_hourly_data_internal(site_id, myYear, keep_units)

    if (keep_units == TRUE) {

      # only append to output if data retrieval worked
      if(!is.null(df_tmp$data)) {
        data[[id]] <- df_tmp$data
        unitsDATA[[id]] <- df_tmp$units
      }

    }else{

      # only append to output if data retrieval worked
      if(!is.null(df_tmp)) data[[id]] <- df_tmp

    }

  }

  # remove empties and bind data
  torm <- unlist(lapply(data, is.null))
  data <- data[!torm]
  newDATA <- dplyr::bind_rows(data)

  if (is.null(newDATA)) {

    message(paste0("There are no data available for ",
                   site_id, " in ", paste(years, collapse = "-"),
                   ". Return NULL object."))

  }

  if (keep_units == TRUE) {
    # remove empties and bind units
    torm <- unlist(lapply(unitsDATA, is.null))
    unitsDATA <- unitsDATA[!torm]
    newMETA <- dplyr::bind_rows(unitsDATA)

    return(list("data" = tibble::as_tibble(newDATA),
                "units" = tibble::as_tibble(newMETA)))
  }else{
    return(tibble::as_tibble(newDATA))
  }

}

#' Get hourly data for 1 DEFRA station
#'
#' @importFrom httr http_error
#' @importFrom utils read.csv
#' @importFrom lubridate dmy_hm
#'
#' @noRd
#'

ukair_get_hourly_data_internal <- function(site_id, years, keep_units){

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste0(rootURL, site_id, "_", years, ".csv")

  df <- try(read.csv(myURL, skip = 4)[-c(1),])

  if(class(df) == "try-error"){

    newDF <- NULL
    message(paste("No data available for station",site_id))

  }else{

    # Build the attribute table to store units
    colUnits <- which(substr(names(df),1,4) == "unit")
    colVars <- colUnits - 2
    unitsDF <- tibble::tibble("variable" = names(df)[colVars],
                            "unit" = as.character(unlist(df[1,colUnits])))

    # Remove status and units columns
    col2rm <- which(substr(names(df),1,6) == "status" |
                      substr(names(df),1,4) == "unit")

    df <- df[, -col2rm]

    df$Date <- as.character(df$Date)
    df$time <- as.character(df$time)
    df$time[which(df$time == "24:00")] <- "00:00"

    newDF <- cbind("datetime" = lubridate::dmy_hm(paste(df$Date, df$time,
                                                        tz = "Europe/London")),
                   "SiteID" = site_id,
                   df[,3:dim(df)[2]])

    # Attributes are not preserved!
    # attr(newDF, "units") <- unitsDF
    # Create a list, instead!
    if (keep_units == TRUE) {
      output <- list("data" = newDF, "units" = unitsDF)
    }else{
      output <- newDF
    }

    return(output)

  }

}
