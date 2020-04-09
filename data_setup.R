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

# get the gdp data from the Federal Reserve Bank of St. Louis
system.time({
  gdp <-
    read_csv('https://fred.stlouisfed.org/graph/fredgraph.csv?id=GDPDEF',
             col_types = cols(.default = col_character())) %>%
    rename_all(tolower) %>%
    mutate(date = as_date(date),
           fiscal_year = ifelse(month(date) > 6, year(date) + 1, year(date)),
           gdp = as.double(gdpdef) / 100)
})


# base tibble used for all data pulls
system.time({
  ipeds_years <-
    tibble(collection_year = seq(2003, recent_year)) %>%
    mutate(fall_calendar_year = collection_year,
           fiscal_year_ending = collection_year,
           fiscal_year = str_c(collection_year - 1, collection_year, sep='-'),
           fiscal_year_short = collapse_year(collection_year),
           academic_year = str_c(collection_year, collection_year + 1, sep='-'))
})


# grab directory information for IPEDS universe
system.time({
  directory <- 
    ipeds_years %>%
    mutate(data = map(collection_year, load_hd)) %>%
    select(collection_year, data) %>%
    unnest(cols = data) %>%
    select(-ialias) %>%
    select(-c(unitid,
              stat_fa,
              stat_ic,
              lock_ic,
              stat_c,
              lock_c,
              prch_c,
              idx_c,
              imp_c,
              stat_wi,
              stat_ef,
              lock_ef,
              prch_ef,
              idx_ef,
              imp_ef,
              pta99_ef,
              ptb_ef,
              ptc_ef,
              ptd_ef,
              pteeffy,
              pteefia,
              fyrpyear,
              stat_sa,
              lock_sa,
              prch_sa,
              idx_sa,
              imp_sa,
              stat_s,
              lock_s,
              prch_s,
              idx_s,
              imp_s,
              stat_eap,
              lock_eap,
              prch_eap,
              idx_eap,
              imp_eap,
              ftemp15,
              sa_excl,
              stat_sp,
              form_f,
              stat_f,
              lock_f,
              prch_f,
              idx_f,
              imp_f,
              fybeg,
              fyend,
              gpfs,
              f1gasbcr,
              f1gasbal,
              stat_sfa,
              lock_sfa,
              prch_sfa,
              idx_sfa,
              imp_sfa,
              stat_gr,
              lock_gr,
              prch_gr,
              idx_gr,
              imp_gr,
              cohrtstu,
              pyaid,
              cohrtaid,
              sport1,
              sport2,
              sport3,
              sport4,
              sport5,
              longpgm,
              cohrtmt,
              tpr,
              hpr,
              cufasb,
              cugasb,
              ocrmsi,
              ocrhsi,
              twoyrcat,
              rev_c,
              rev_ef,
              rev_sa,
              rev_s,
              rev_eap,
              r_form_f,
              rev_f,
              rev_sfa,
              rev_gr))
})
  

# grab institutional characteristics for IPEDS universe
system.time({
  characteristics <- 
    ipeds_years %>%
    mutate(data = map(collection_year, load_ic)) %>%
    select(collection_year, data) %>%
    unnest(cols = data)
})
 

# grab subission flags 
system.time({
  submissions <-
    ipeds_years %>%
    mutate(data = map(collection_year, load_submissions)) %>%
    select(collection_year, data) %>%
    unnest(cols = data)
})


# create a file database (db) to store IPEDS data
db <- dbConnect(RSQLite::SQLite(), "db.sqlite")

system.time({
  dbWriteTable(db, "ipeds_years", ipeds_years, overwrite=TRUE)
  dbWriteTable(db, "gdp", gdp, overwrite=TRUE)
  dbWriteTable(db, "directory", directory, overwrite=TRUE)
  dbWriteTable(db, "characteristics", characteristics, overwrite=TRUE)
  dbWriteTable(db, "submissions", submissions, overwrite=TRUE)
  
  })

# housekeeping
rm(ipeds_years, gdp, directory, characteristics)

# load directory to check that values were properly written
tbl(db, 'directory') %>%
  collect() %>%
  str()

# load directory to check that values were properly written
tbl(db, 'characteristics') %>%
  collect() %>%
  str()

# Disconnect database
dbDisconnect(db)
