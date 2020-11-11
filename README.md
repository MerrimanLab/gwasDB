
<!-- README.md is generated from README.Rmd. Please edit that file -->

gwasDB
======

Required libraries

``` r
library(tidyverse)
#> ── Attaching packages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse 1.3.0.9000 ──
#> ✓ ggplot2 3.3.2     ✓ purrr   0.3.4
#> ✓ tibble  3.0.3     ✓ dplyr   1.0.2
#> ✓ tidyr   1.1.1     ✓ stringr 1.4.0
#> ✓ readr   1.3.1     ✓ forcats 0.5.0
#> ── Conflicts ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(dbplyr)
#> 
#> Attaching package: 'dbplyr'
#> The following objects are masked from 'package:dplyr':
#> 
#>     ident, sql
library(RPostgreSQL)
#> Loading required package: DBI
library(config)
#> 
#> Attaching package: 'config'
#> The following objects are masked from 'package:base':
#> 
#>     get, merge
```

Config file creation
--------------------

In a file called \`config.yml’

    gwasdb_ro:
      driver: 'PostgreSQL Unicode' # this might differ on your computer - use odbc::odbcListDrivers() to see the available names for you.
      database: 'gwasdb'
      server: 'biocmerriserver2.otago.ac.nz'
      port: 5432
      username: '' # get details from Murray
      password: '' # get details from Murray

Accessing
---------

``` r
Sys.setenv(R_CONFIG_ACTIVE = "gwasdb_ro")
conf <- config::get(file = here::here("config.yml"))
con <- dbConnect(odbc::odbc(),driver = conf$driver, database = conf$database, servername = conf$server, port = conf$port, UID = conf$user, PWD = conf$password , timeout = 100)
#> Warning in conf$user: partial match of 'user' to 'username'
```
