###################################################################
#                                                                 #
# Run this script to pull data into local db for use in analyses. #
#                                                                 #
###################################################################

# libraries
library(DBI)
library(odbc)
library(dbplyr)
library(RSQLite)
library(lubridate)
library(tidyverse)

# set random seed
set.seed(1965)

# include user functions
source(file="user_functions.R")

# set constants
recent_year <- 2018



# create a file database (db) to store IPEDS data
db <- dbConnect(RSQLite::SQLite(), "db.sqlite")



# base tibble used for all data pulls
ipeds_years <-
    tibble(collection_year = seq(2002, recent_year))



# grab finance data
system.time({
  finance <- 
    ipeds_years %>%
    mutate(accounting_standard = 'FASB',
           data = map(collection_year, load_fasb)) %>%
    rename(year_key = collection_year) %>%
    unnest(cols = data)
  
  finance <- 
    ipeds_years %>%
    mutate(accounting_standard = 'GASB',
           data = map(collection_year, load_gasb)) %>%
    rename(year_key = collection_year) %>%
    unnest(cols = data) %>%
    bind_rows(finance)
  
  
  # write table to db
  dbWriteTable(db, "finance", finance, overwrite=TRUE)
  
  # housekeeping
  rm(finance)
})



# Disconnect database
dbDisconnect(db)
