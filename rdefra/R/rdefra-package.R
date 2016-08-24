#' rdefra: Interact with the UK AIR Pollution Database from DEFRA
#'
#' The R package rdefra allows to retrieve air pollution data from the Air Information Resource (UK-AIR) of the Department for Environment, Food and Rural Affairs in the United Kingdom (see \url{https://uk-air.defra.gov.uk/}). UK-AIR does not provide public APIs for programmatic access to data, therefore this package scrapes the HTML pages to get relevant information.
#'
#' @name rdefra
#' @docType package
#'
#' @importFrom httr GET content http_error
#' @importFrom utils read.csv
#' @importFrom xml2 xml_find_first xml_attr xml_find_all
#' @importFrom lubridate dmy_hm ymd
#' @importFrom tibble as_tibble
#' @importFrom dplyr bind_rows
#' @importFrom sp coordinates proj4string CRS spTransform
#'
NULL
