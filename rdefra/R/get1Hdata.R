#' Get hourly data for DEFRA stations
#'
#' @description This function fetches ourly data from DEFRA's air pollution monitoring stations.
#'
#' @param site_id This is the ID of a specific site.
#' @param years Years for which data should be downloaded.
#'
#' @return A data.frame containing hourly pollution data.
#'
#' @examples
#' # get1Hdata("ABD", "2014")
#'

get1Hdata <- function(site_id, years){

  if (length(as.list(years)) == 0) {
    message("Please insert a valid year (or sequence of years).")
    stop
  }

  if (length(as.list(years)) >= 1){

    dat <- vector('list', length = length(years))
    id <- 1

    for(myYear in as.list(years)){

      df_tmp <- get1Hdata_internal(site_id, myYear)

      # only append to output if data retrieval worked
      if(!is.null(df_tmp)){
        dat[[id]] <- df_tmp
        id <- id + 1
      }

    }

    # remove empties
    torm <- unlist(lapply(dat, is.null))
    dat <- dat[!torm]

    newDAT <- rbind.fill(dat)

  }

  return(newDAT)

}

get1Hdata_internal <- function(site_id, myYears){

  rootURL <- "https://uk-air.defra.gov.uk/data_files/site_data/"
  myURL <- paste(rootURL, site_id, "_", myYears, ".csv", sep = "")

  if (url.exists(myURL)){
    df <- read.csv(myURL, skip = 4)[-c(1),]
    col2rm <- which(substr(names(df),1,6) == "status" |
                      substr(names(df),1,4) == "unit")
    df <- df[, -col2rm]
    df$site_id <- site_id
  }else{
    df <- NULL
  }

  return(df)

}
