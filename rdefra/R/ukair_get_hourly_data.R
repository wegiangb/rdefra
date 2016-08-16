#' Get hourly data for DEFRA stations
#'
#' @importFrom dplyr rbind_all
#' @importFrom tibble as_tibble
#'
#' @description This function fetches hourly data from DEFRA's air pollution monitoring stations.
#'
#' @param site_id This is the ID of a specific site.
#' @param years Years for which data should be downloaded.
#' @param keepUnits logical that if set to TRUE returns a column with unit after each column with measurements (this parameter is set to FALSE by default).
#'
#' @details The measurements are generally in ugm-3 (micrograms per cubic metre). Please double check the units before using these data.
#'
#' @return A data.frame containing hourly pollution data.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  ukair_get_hourly_data("ABD", 2014)
#'  ukair_get_hourly_data("ABD", 2014:2016)
#'  }
#'

ukair_get_hourly_data <- function(site_id = NULL,
                                  years = NULL,
                                  keepUnits = FALSE){

  if (is.null(site_id)) {

    stop("Please insert a valid ID.
         \nFor a list of valid IDs check the SiteID column in the cached
         catalogue: \n data(stations) \n na.omit(unique(stations$SiteID))")

  }

  if (is.null(years)) {

    stop("Please insert a valid year (or sequence of years).")

  }

  dat <- vector('list', length = length(years))
  id <- 1

  for(myYear in as.list(years)){

    id <- which(as.list(years) == myYear)

    df_tmp <- ukair_get_hourly_data_internal(site_id, myYear, keepUnits)

    # only append to output if data retrieval worked
    if(!is.null(df_tmp)){
      dat[[id]] <- df_tmp
    }

  }

  # remove empties
  torm <- unlist(lapply(dat, is.null))
  dat <- dat[!torm]

  newDAT <- dplyr::rbind_all(dat)

  if (is.null(newDAT)) {

    message(paste0("There are no data available for ",
                  site_id, " in ", paste(years, collapse = "-"),
                  ". Return NULL object."))

  }

  return(tibble::as_tibble(newDAT))

}

#' Get hourly data for 1 DEFRA station
#'
#' @importFrom httr http_error
#' @importFrom utils read.csv
#' @importFrom lubridate dmy_hm
#'
#' @noRd
#'

ukair_get_hourly_data_internal <- function(site_id, myYears, keepUnits){

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste0(rootURL, site_id, "_", myYears, ".csv")

  df <- try(read.csv(myURL, skip = 4)[-c(1),])

  if(class(df) == "try-error"){

    newDF <- NULL
    message(paste("No data available for station",site_id))

  }else{

    if (keepUnits){

      # Remove status and keep units columns
      col2rm <- which(substr(names(df),1,6) == "status")

    }else{

      # Remove status and units columns
      col2rm <- which(substr(names(df),1,6) == "status" |
                        substr(names(df),1,4) == "unit")

    }

    df <- df[, -col2rm]

    df$Date <- as.character(df$Date)
    df$time <- as.character(df$time)
    df$time[which(df$time == "24:00")] <- "00:00"

    newDF <- cbind("datetime" = lubridate::dmy_hm(paste(df$Date, df$time)),
                   "SiteID" = site_id,
                   df[,3:dim(df)[2]])

    return(newDF)

  }

}
