
<!-- README.md is generated from README.Rmd. Please edit that file -->

gwasDB
======

Required libraries

``` r
library(tidyverse)
library(dbplyr)
library(RPostgreSQL)
library(config)
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
```
