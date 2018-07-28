.onAttach <- function(...) {

  # The server might break the http2 connection,
  # a work around is to disable http2 in the config
  # https://github.com/ropensci/monkeylearn/pull/15
  httr::set_config(httr::config(http_version = 0))

}
