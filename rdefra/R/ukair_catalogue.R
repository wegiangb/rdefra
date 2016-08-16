#' Get DEFRA UK-AIR stations metadata
#'
#' @importFrom httr GET content
#' @importFrom utils read.csv
#' @importFrom xml2 xml_find_first xml_attr
#' @importFrom lubridate dmy_hm ymd
#' @importFrom tibble as_tibble
#'
#' @description This function fetches the catalogue of monitoring stations from DEFRA's website.
#'
#' @param site_name This is the name of a specific site (by default this is left blank to get info on all the available sites.
#' @param pollutant This is a number from 1 to 10. Default is 9999, which means all the pollutants.
#' @param group_id This is the identification number of a group of stations. Default is 9999 which means all available networks.
#' @param closed This is "true" to include closed stations, "false" otherwise.
#' @param country_id This is the identification number of the country, it can be a number from 1 to 6. Default is 9999, which means all the countries.
#' @param region_id This is the identification number of the region. 1 = Aberdeen City, etc. (for the full list see \url{https://uk-air.defra.gov.uk/}). Default is 9999, which means all the local authorities.
#' @param location_type This is the identification number of the location. Default is 9999, which means all the location types.
#'
#' @details
#' \code{Pollutant} is defined based on the following convention: 1 = Ozone (O3), 2 = Nitrogen oxides (NOx), 3 = Carbon monoxide (CO), 4 = Sulphur dioxide (SO2), 5 = Particulate Matter (PM10), 6 = Particulate Matter (PM2.5), 7 = PAHs, 8 = Metals in PM10, 9 = Benzene, 10 = Black Carbon.
#' \code{group_id} is defined based on the following convention: 1 = UKEAP: Precip-Net, 2 = Air Quality Strategy Pollutants, 3 = Ammonia and Nitric Acid, 4 = Automatic Urban and Rural Monitoring Network (AURN), 5 = Dioxins and Furans, 6 = Black Smoke & SO2, 7 = Automatic Hydrocarbon Network, 8 = Heavy Metals, 9 = Nitrogen Dioxide Diffusion Tube, 10 = PAH Andersen, 11 = Particle Size Composition, 12 = PCBs, 13 = TOMPs, 14 = Non-Automatic Hydrocarbon Network, 15 = 1,3-Butadiene Diffusion Tube, 16 = Black Carbon, 17 = Automatic Urban and Rural Monitoring Network (AURN), 18 = Defra NO2 Diffusion Tube, 19 = PAH Digitel (solid phase), 20 = PAH Digitel (solid+vapour), 21 = PAH Deposition, 22 = Particle size and number, 23 = Rural Automatic Mercury network, 24 = Urban Sulphate, 25 = UKEAP: Rural NO2, 26 = Automatic Urban and Rural Monitoring Network (AURN), 27 = UKEAP: National Ammonia Monitoring Network, 28 = UKEAP: Acid Gases & Aerosol Network, 29 = Particle Speciation (MARGA), 30 = UKEAP: Historic Aerosol measurements.
#' \code{country_id} is defined based on the following convention: 1 = England, 2 = Wales, 3 = Scotland, 4 = Northern Ireland, 5 = Republic of Ireland, 6 = Channel Islands.
#'
#' @return A named vector containing Easting and Northing coordinates.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#'  ukair_catalogue()
#'  }
#'

ukair_catalogue <- function(site_name = "", pollutant = 9999, group_id = 9999,
                      closed = "true", country_id = 9999, region_id = 9999,
                      location_type = 9999){

  # Any NULL elements of the list supplied to the query paramater are
  # automatically dropped
  catalogue_fetch <- httr::GET(url = "http://uk-air.defra.gov.uk",
                               path = "networks/find-sites",
                               query = list(site_name = site_name,
                                            pollutant = pollutant,
                                            group_id = group_id,
                                            closed = closed,
                                            country_id = country_id,
                                            region_id = region_id,
                                            location_type = location_type,
                                            search = "Search+Network",
                                            view = "advanced",
                                            action = "results"))

  # download content
  catalogue_content <- httr::content(catalogue_fetch)

  # Extract csv link
  catalogue_csv_link <- xml2::xml_find_first(catalogue_content,
                                             "//*[contains(@class,'bCSV')]")
  catalogue_csv_link <- xml2::xml_attr(catalogue_csv_link, "href")

  if (!is.na(catalogue_csv_link)) {

    df <- utils::read.csv(catalogue_csv_link)
    # Convert data.frame columns from factors to characters
    df[] <- lapply(df, as.character)

    df$Start.Date <- lubridate::ymd(df$Start.Date)
    df$End.Date <- lubridate::ymd(df$End.Date)

  }else{

    stop("No metadata available for the specified query")

  }

  return(tibble::as_tibble(df))

}
