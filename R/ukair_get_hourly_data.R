#' Get hourly data for DEFRA stations
#'
#' @description This function fetches hourly data from DEFRA's air pollution
#' monitoring stations.
#'
#' @param site_id This is the ID of a specific site.
#' @param years Years for which data should be downloaded.
#'
#' @details The measurements are generally in \eqn{\mu g/m^3} (micrograms per
#' cubic metre). To check the units, refer to the table of attributes (see
#' example below). Please double check the units on the DEFRA website, as they
#' might change over time.
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
#'  # Get units
#'  attributes(output)$units
#'
#'  }
#'

ukair_get_hourly_data <- function(site_id = NULL, years = NULL){

  if (is.null(site_id)) {

    stop("Please insert a valid ID.
         \nFor a list of valid IDs check the SiteID column in the cached
         catalogue: \n data(stations) \n na.omit(unique(stations$SiteID))")

  }

  if (is.null(years)) {

    stop("Please insert a valid year (or sequence of years).")

  }

  data <- vector("list", length = length(years))
  units_data <- vector("list", length = length(years))
  id <- 1

  for (myYear in as.list(years)){

    id <- which(as.list(years) == myYear)

    df_tmp <- ukair_get_hourly_data_internal(site_id, myYear)

    # only append to output if data retrieval worked
    if (!is.null(df_tmp$data)) {
      data[[id]] <- df_tmp$data
      units_data[[id]] <- df_tmp$units
    }

  }

  # remove empties and bind data
  torm <- unlist(lapply(data, is.null))
  data <- data[!torm]
  new_data <- dplyr::bind_rows(data)

  if (is.null(new_data)) {

    message(paste0("There are no data available for ",
                   site_id, " in ", paste(years, collapse = "-"),
                   ". Return NULL object."))

  }

  # remove empties and bind units
  torm <- unlist(lapply(units_data, is.null))
  units_data <- units_data[!torm]

  # convert list to dataframe
  new_meta <- dplyr::bind_rows(units_data)

  new_meta$unit[new_meta$unit == ""] <- NA

  # Add units as new attribute
  attr(new_data, "units") <- tibble::as_tibble(new_meta)

  return(tibble::as_tibble(new_data))

}

#' Get hourly data for 1 DEFRA station
#'
#' @importFrom httr http_error
#' @importFrom utils read.csv
#' @importFrom lubridate dmy_hm
#'
#' @noRd
#'

ukair_get_hourly_data_internal <- function(site_id, a_year){

  root_url <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  my_url <- paste0(root_url, site_id, "_", a_year, ".csv")

  df <- try(read.csv(my_url, skip = 4)[-c(1), ])

  if (class(df) == "try-error"){

    new_df <- NULL
    message(paste("No data available for station", site_id))

  }else{

    # Build the attribute table to store units
    col_units <- which(substr(names(df), 1, 4) == "unit")
    col_vars <- col_units - 2
    units_col <- as.character(t(df[1, col_units]))
    units_df <- data.frame("variable" = names(df)[col_vars],
                          "unit" = units_col,
                          "year" = a_year,
                          stringsAsFactors = FALSE)

    # Remove status and units columns
    col2rm <- which(substr(names(df), 1, 6) == "status" |
                      substr(names(df), 1, 4) == "unit")

    df <- df[, -col2rm]

    df$Date <- as.character(df$Date)
    df$time <- as.character(df$time)
    df$time[which(df$time == "24:00")] <- "00:00"

    new_df <- cbind("datetime" = lubridate::dmy_hm(paste(df$Date, df$time,
                                                        tz = "Europe/London")),
                   "SiteID" = site_id,
                   df[, 3:dim(df)[2]])

    # Create a list
    output <- list("data" = new_df, "units" = units_df)

    return(output)

  }

}
