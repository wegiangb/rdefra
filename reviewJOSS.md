---
title: "Response to reviewers"
author: "Claudia Vitolo"
date: "25 August 2016"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## rdefra - response to reviewers (step 1)

Many thanks for reviewing my paper/package. Below are my responses to reviewers' comments.

## @pjotrp

* I agree web scraping is a fragile method but without pubblic APIs there are not many alternatives. This is however a temporary solution, when APIs will become available I'll update the package to work with those.

* I wrote this software to carry out my own research and I believe there are many other researchers that could benefit from my work, without the need to re-invent the wheel. In my opinion, this is a valuable contribution to research but it could also be useful for practitioners. I am preparing another journal paper for which I carried out some modelling excercises and used this software to get pollution data. I'll add a link to this second paper as soon as it is published.

## @pragyansmita 

* Regarding the license, I confirm that the license information is included in the DESCRIPTION file where you can read __License: GPL-3__. This should be sufficient, according to the [Writing R Extensions manual](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Licensing) which says that 'It is very important that you include license information [...] If a package license restricts a base license [...] the additional terms should be placed in file LICENSE'. Therefore, if I understand this well, I only need a file called LICENSE is I want to restrict the LICENSE specified in the DESCRIPTION file. Am I correct?

* I confirm that the latest version is 0.3.0 (see Github repository).

* As requested by ROPENSCI reviewers, all the names of the functions in rdefra  are now in lower case and have a prefix (ukair):

    - `catalogue()` is now called `ukair_catalogue()`
    - `EastingNorthing()` is now called `ukair_get_coordinates()`
    - `get1Hdata()` is now called `ukair_get_hourly_data()`
    - `getSiteID()` is now called `ukair_get_site_id()`
README and vignette have been updated accordingly.

* A number of tests have been provided using the testthat framework.
