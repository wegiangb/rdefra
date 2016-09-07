---
title: 'rdefra: Interact with the UK AIR Pollution Database from DEFRA'
bibliography: paper.bib
date: "3 August 2016"
tags:
- open data
- air pollution
- R
authors:
- affiliation: Brunel University London
  name: Claudia Vitolo
  orcid: 0000-0002-4252-1176
- affiliation: Brunel University London
  name: Andrew Russell
  orcid: 0000-0001-7120-8499
- affiliation: Brunel University London
  name: Allan Tucker
  orcid: 0000-0001-5105-3506
---

# Summary

Rdefra [@rdefra-archive] is an R package [@R-base] to retrieve air pollution data from the Air Information Resource (UK-AIR) of the Department for Environment, Food and Rural Affairs in the United Kingdom. UK-AIR does not provide a public API for programmatic access to data, therefore this package scrapes the HTML pages to get relevant information.

This package follows a logic similar to other packages such as waterData[@waterdata] and rnrfa[@rnrfa]: sites are first identified through a catalogue, data are imported via the station identification number, then data are visualised and/or used in analyses. The metadata related to the monitoring stations are accessible through the function `ukair_catalogue()`, missing stations' coordinates can be obtained using the function `ukair_get_coordinates()`, and time series data related to different pollutants can be obtained using the function `ukair_get_hourly_data()`.

The package is designed to collect data efficiently. It allows to download multiple years of data for a single station with one line of code and, if used with the parallel package [@R-base], allows the acquisition of data from hundreds of sites in only few minutes.

The figure below shows the 6566 stations with valid coordinates within the UK-AIR (blue circles) database, for 225 of them hourly data is available and their location is shown as red circles.

![UK-AIR monitoring stations (August 2016)](MonitoringStations.png)

# References
