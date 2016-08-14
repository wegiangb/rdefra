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

  enDF <- do.call(rbind, lapply(X = as.list(IDs), FUN = ukair_get_site_id_internal))

  return(as.character(enDF))

}

#' Internal function to get site IDs for 1 DEFRA station
#'
#' @importFrom httr GET
#' @importFrom XML htmlParse xpathSApply xmlGetAttr
#'
#' @noRd
#'

ukair_get_site_id_internal <- function(uka_id){

  rootURL <- "http://uk-air.defra.gov.uk/networks/site-info?"

  myURL <- paste(rootURL, "uka_id=", uka_id,
                 "&search=View+Site+Information&action=site", sep = "")

  # download html
  html <- httr::GET(myURL)

  # parse html
  doc = XML::htmlParse(html, asText=TRUE)
  hrefs <- XML::xpathSApply(doc, '//*[@id="g4"]/td[4]/a[4]', XML::xmlGetAttr, 'href')

  if(is.null(hrefs)){
    siteID <- NA
  }else{
    siteID <- gsub("^.*\\=", "", hrefs)
  }

  return(siteID)

}
