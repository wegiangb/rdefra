#' Get site IDs for DEFRA stations
#'
#' @description Given the UK AIR ID, this function fetches the catalogue of monitoring stations from DEFRA's website.
#'
#' @param IDs An alphanumeric string (or vector of strings) containing the UK AIR ID defined by DEFRA.
#'
#' @return A named vector containing the site IDs.
#'
#' @examples
#' # getSiteID("UKA00399")
#'

getSiteID <- function(IDs){

  IDs <- as.character(IDs)

  enDF <- do.call(rbind, lapply(X = as.list(IDs), FUN = getSiteID_internal))

  return(as.character(enDF))

}

getSiteID_internal <- function(uka_id){

  # library(RCurl)
  # library(XML)
  # uka_id <- "UKA00399"
  # uka_id <- "UKA15910"

  rootURL <- "http://uk-air.defra.gov.uk/networks/site-info?"

  myURL <- paste(rootURL, "uka_id=", uka_id,
                 "&search=View+Site+Information&action=site", sep = "")

  # download html
  html <- getURL(myURL, followlocation = TRUE)

  # parse html
  doc = htmlParse(html, asText=TRUE)
  hrefs <- xpathSApply(doc, '//*[@id="g4"]/td[4]/a[4]', xmlGetAttr, 'href')

  if(is.null(hrefs)){
    siteID <- NA
  }else{
    siteID <- gsub("^.*\\=", "", hrefs)
  }

  return(siteID)

}
