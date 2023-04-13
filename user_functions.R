options(tidyverse.quiet = T)
library(dplyr)
library(readr)
library(DBI)
library(janitor)
library(data.table, warn.conflicts = F)

set.seed(1965)



run_model <- function(fml, df) {
  # run a linear model (fml) on data frame (df)
  lm(formula = as.formula(fml), 
     data = df)
}




collapse_year <-
  function(year) {
    # collapse year for fiscal years
    paste0(substr(year - 1, 3 ,4),
           substr(year, 3 ,4))
  }




open_db_connection <- function(survey_year) {
  file_spec <- paste0("data/IPEDS",
                      survey_year,
                      substr(survey_year + 1, 3, 4),
                      ".db")
  dbConnect(RSQLite::SQLite(), dbname = file_spec)
}

# This uses dbplyr to fetch a specified table
fetch_table <- function(connection, table_name) {
  tbl(connection, table_name) |>
    collect() |>
    clean_names() |>
    as.data.table()
}


load_tables <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0("Tables", substr(year, 3, 4)))
  dbDisconnect(connection)
  df
}


load_variables <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0("Vartable", substr(year, 3, 4)))
  dbDisconnect(connection)
  df
}


load_value_sets <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0("valuesets", substr(year, 3, 4)))
  dbDisconnect(connection)
  df
}


load_ic <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('IC', year))
  dbDisconnect(connection)
  df
}




load_hd <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('HD', year))
  dbDisconnect(connection)
  df
}




load_submissions <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('FLAGS', year))
  dbDisconnect(connection)
  df
}




load_fall_enrollment <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('EF', year, 'A'))
  dbDisconnect(connection)
  
  if (year < 2008) {
    df <- df[efalevel %in% c(24, 25, 31, 32, 36, 44, 45, 51, 52, 56)]
    df[,
       `:=`(efnralm = as.integer(efrace01),
            efnralw = as.integer(efrace02),
            efunknm = as.integer(efrace13),
            efunknw = as.integer(efrace14),
            efhispm = as.integer(efrace09),
            efhispw = as.integer(efrace10),
            efaianm = as.integer(efrace05),
            efaianw = as.integer(efrace06),
            efasiam = as.integer(efrace07),
            efasiaw = as.integer(efrace08),
            efbkaam = as.integer(efrace03),
            efbkaaw = as.integer(efrace04),
            efnhpim = 0,
            efnhpiw = 0,
            efwhitm = as.integer(efrace11),
            efwhitw = as.integer(efrace12),
            ef2morm = 0,
            ef2morw = 0)]
  }
  
  if (year == 2008) {
    df <- df[efalevel %in% c(24, 25, 31, 32, 36, 44, 45, 51, 52, 56)]
    df[,
       `:=`(efnralm = as.integer(efnralm),
            efnralw = as.integer(efnralw),
            efunknm = as.integer(efunknm),
            efunknw = as.integer(efunknw),
            efhispm = as.integer(dvefhsm),
            efhispw = as.integer(dvefhsw),
            efaianm = as.integer(dvefaim),
            efaianw = as.integer(dvefaiw),
            efasiam = as.integer(dvefapm),
            efasiaw = as.integer(dvefapw),
            efbkaam = as.integer(dvefbkm),
            efbkaaw = as.integer(dvefbkw),
            efnhpim = 0,
            efnhpiw = 0,
            efwhitm = as.integer(dvefwhm),
            efwhitw = as.integer(dvefwhw),
            ef2morm = as.integer(ef2morm),
            ef2morw = as.integer(ef2morm))]
       }
  
  if (year == 2009) {
    df <- df[efalevel %in% c(24, 31, 32, 39, 40, 44, 51, 52, 59, 60)]
    df[,
       `:=`(efnralm = as.integer(efnralm),
            efnralw = as.integer(efnralw),
            efunknm = as.integer(efunknm),
            efunknw = as.integer(efunknw),
            efhispm = as.integer(dvefhsm),
            efhispw = as.integer(dvefhsw),
            efaianm = as.integer(dvefaim),
            efaianw = as.integer(dvefaiw),
            efasiam = as.integer(dvefapm),
            efasiaw = as.integer(dvefapw),
            efbkaam = as.integer(dvefbkm),
            efbkaaw = as.integer(dvefbkw),
            efnhpim = 0,
            efnhpiw = 0,
            efwhitm = as.integer(dvefwhm),
            efwhitw = as.integer(dvefwhw),
            ef2morm = as.integer(ef2morm),
            ef2morw = as.integer(ef2morm))]
    }
  
  if (year > 2009) {
    df <- df[efalevel %in% c(24, 31, 32, 39, 40, 44, 51, 52, 59, 60)]
    df[,
       `:=`(efnralm = as.integer(efnralm),
            efnralw = as.integer(efnralw),
            efunknm = as.integer(efunknm),
            efunknw = as.integer(efunknw),
            efhispm = as.integer(efhispm),
            efhispw = as.integer(efhispw),
            efaianm = as.integer(efaianm),
            efaianw = as.integer(efaianw),
            efasiam = as.integer(efasiam),
            efasiaw = as.integer(efasiaw),
            efbkaam = as.integer(efbkaam),
            efbkaaw = as.integer(efbkaaw),
            efnhpim = as.integer(efnhpim),
            efnhpiw = as.integer(efnhpiw),
            efwhitm = as.integer(efwhitm),
            efwhitw = as.integer(efwhitw),
            ef2morm = as.integer(ef2morm),
            ef2morw = as.integer(ef2morw))]
    }
  
  df[, `:=`(time_status = 'Part-time',
            career_level = 'Undergraduate',
            degree_seeking = 'Unknown',
            continuation_type = 'Unknown')]
  df[efalevel %in% c(24, 25, 31, 32, 36, 39, 40),
     time_status := 'Full-time']
  df[efalevel %in% c(32, 36, 52, 56),
     career_level := 'Graduate']
  df[efalevel %in% c(24, 25, 39, 40, 44, 45, 59, 60),
     degree_seeking := "Degree-seeking"]
  df[efalevel %in% c(31, 51),
     degree_seeking := "Non-degree-seeking"]
  df[efalevel %in% c(24, 44),
     continuation_type := 'First-time']
  df[efalevel %in% c(39, 59),
     continuation_type := 'Transfer']
  df[efalevel %in% c(40, 60),
     continuation_type := 'Continuing']
  df[,
     .(unitid, time_status, career_level, degree_seeking, continuation_type,
       efnralm, efnralw, efunknm, efunknw, efhispm,
       efhispw, efaianm, efaianw, efasiam, efasiaw,
       efbkaam, efbkaaw, efnhpim, efnhpiw, efwhitm,
       efwhitw, ef2morm, ef2morw)]
}




load_state_enrollment <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('EF', year, 'C'))
  dbDisconnect(connection)
  df
}


load_retention <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('EF', year, 'D'))
  dbDisconnect(connection)
  df
}




load_charges <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection, paste0('IC', year, '_AY'))
  dbDisconnect(connection)
  melt(df,
       id.vars = 'unitid',
       measure.vars = colnames(df)[-1],
       variable.name = 'field',
       na.rm = T)[, value := as.numeric(value)]
}




load_sfa <- function(year)
{
  connection <- open_db_connection(year)
  if (year < 2009) {
    df <- fetch_table(connection,
                      paste0('SFA', substr(year - 1, 3, 4), substr(year, 3, 4)))
  } else {
    p1 <- fetch_table(connection,
                      paste0('SFA', substr(year - 1, 3, 4), substr(year, 3, 4),
                      '_P1'))
    p2 <- fetch_table(connection,
                      paste0('SFA', substr(year - 1, 3, 4), substr(year, 3, 4),
                      '_P2'))
    setkey(p1, unitid)
    setkey(p2, unitid)
    df <- p2[p1]
  }
  
  dbDisconnect(connection)
  melt(df,
       id.vars = 'unitid',
       measure.vars = colnames(df)[-1],
       variable.name = 'field',
       na.rm = T)[, value := as.numeric(value)]
}




load_fasb <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection,
                    paste0('F', substr(year - 1, 3, 4), substr(year, 3, 4),
                           '_F2'))
  dbDisconnect(connection)
  melt(df,
       id.vars = 'unitid',
       measure.vars = colnames(df)[-1],
       variable.name = 'field',
       value.name = 'amount',
       na.rm = T)[, amount := as.double(amount)]
}




load_gasb <- function(year)
{
  connection <- open_db_connection(year)
  df <- fetch_table(connection,
                    paste0('F', substr(year - 1, 3, 4), substr(year, 3, 4),
                           '_F1A'))
  dbDisconnect(connection)
  melt(df,
       id.vars = 'unitid',
       measure.vars = colnames(df)[-1],
       variable.name = 'field',
       value.name = 'amount',
       na.rm = T)[, amount := as.double(amount)]
}
