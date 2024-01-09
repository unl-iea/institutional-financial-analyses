###################################################################
#                                                                 #
# Run this script to pull data into local db for use in analyses. #
#                                                                 #
###################################################################

# create data and output directorys
system.time({
  if (!dir.exists(paste(getwd(), 'data', sep = '/'))) {
    dir.create(paste(getwd(), 'data', sep = '/'))
  }
})


system.time({
  if (!dir.exists(paste(getwd(), 'output', sep = '/'))) {
    dir.create(paste(getwd(), 'output', sep = '/'))
  }
})

# install packages (optional)
# I'd advise doing this by hand, but here is a bit of code to do this in one pass
# should you prefer.
# COMMENT TO DEATIVATE
system.time({
  packages <-
    c('knitr',
      'janitor',
      'lubridate',
      'broom',
      'tidyverse',
      'data.table')
  
  for (pkg in packages) {
    if (pkg %in% rownames(installed.packages()) == FALSE) {
      install.packages(pkg, dependencies = TRUE)
      }
  }
})

# libraries
library(lubridate)
library(janitor)
library(tidyverse)
library(data.table)

# set random seed
set.seed(1965)

# include user functions
source(file = "user_functions.R")

# set constants
recent_year <- ifelse(month(today()) > 10,
                      year(today()) - 1,
                      year(today()) - 2)



# create a file database (db) to store IPEDS data
# db <- dbConnect(RSQLite::SQLite(), paste(getwd(), 'data/db.sqlite', sep = '/'))



# base tibble used for all data pulls
ipeds_years <-
    tibble(collection_year = seq(2004, recent_year))



# get the gdp data from the Federal Reserve Bank of St. Louis
system.time({
  gdp <-
    fread('https://fred.stlouisfed.org/graph/fredgraph.csv?id=GDPDEF',
          colClasses = 'character',
          strip.white = T) |>
    clean_names()
  
  gdp <- gdp[,
      .(year_key = ifelse(month(date) > 6, year(date) + 1, year(date)),
        month = month(date),
        date = as_date(date),
        gdp = as.double(gdpdef) / 100)]

  # write table to db
  # dbWriteTable(db, "gdp", gdp, overwrite = TRUE)
  saveRDS(gdp, 'data/gdp.rds')
  # housekeeping
  rm(gdp)
})


# grab directory information for IPEDS universe
system.time({
  directory <- 
    ipeds_years |>
    mutate(data = map(collection_year, load_hd),
           year_key = collection_year + 1) |>
    select(year_key, data) |>
    unnest(cols = data) |>
    select(unitid,
           year_key,
           instnm,
           city,
           stabbr,
           fips,
           obereg,
           opeid,
           opeflag,
           sector,
           iclevel,
           control,
           hloffer,
           ugoffer,
           groffer,
           hdegofr1,
           deggrant,
           hbcu,
           hospital,
           medical,
           tribal,
           locale,
           openpubl,
           act,
           newid,
           deathyr,
           closedat,
           cyactive,
           postsec,
           pseflag,
           pset4flg,
           rptmth,
           instcat,
           landgrnt,
           instsize,
           f1systyp,
           f1sysnam,
           f1syscod,
           cbsa,
           cbsatype,
           countycd,
           countynm,
           longitud,
           latitude) |>
    pivot_longer(cols = c(fips,
                          obereg,
                          opeflag,
                          sector,
                          iclevel,
                          control,
                          hloffer,
                          ugoffer,
                          groffer,
                          hdegofr1,
                          deggrant,
                          hbcu,
                          hospital,
                          medical,
                          tribal,
                          locale,
                          openpubl,
                          newid,
                          deathyr,
                          cyactive,
                          postsec,
                          pseflag,
                          pset4flg,
                          rptmth,
                          instcat,
                          landgrnt,
                          instsize,
                          f1systyp,
                          cbsa,
                          cbsatype,
                          countycd,
                          longitud,
                          latitude),
                 names_to = 'field',
                 values_to = 'value') |>
    mutate(value = as.numeric(value)) |>
    pivot_wider(names_from = field,
                values_from = value) |>
    mutate(deathyr = ifelse(deathyr > 0, deathyr, NA),
           closedat = ifelse(closedat == '-2',
                             NA,
                             closedat)) |>
    rename(institution_name = instnm,
           state = stabbr,
           bea_region = obereg,
           title4_eligible = opeflag,
           level_institution = iclevel,
           highest_level_offering = hloffer,
           undergraduate_offering = ugoffer,
           graduate_offering = groffer,
           highest_degree_offered = hdegofr1,
           degree_granting = deggrant,
           status = act,
           merged_unitid = newid,
           close_year = deathyr,
           close_date = closedat,
           active_current_year = cyactive,
           primarily_postsec_flag = postsec,
           postsecondary_flag = pseflag,
           postsecondary_title4_indicator = pset4flg,
           reporting_method = rptmth,
           institution_category = instcat,
           landgrant = landgrnt,
           multicampus_type = f1systyp,
           multicampus_name = f1sysnam,
           multicampus_id = f1syscod,
           cbsa_type = cbsatype,
           country_fips = countycd,
           country_name = countynm,
           longitude = longitud) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "directory", directory, overwrite = TRUE)
  saveRDS(directory, 'data/directory.rds')
  # housekeeping
  rm(directory)
})




# grab institutional characteristics for IPEDS universe
system.time({
  characteristics <- 
    ipeds_years |>
    mutate(data = map(collection_year, load_ic),
           year_key = collection_year + 1) |>
    select(year_key, data) |>
    unnest(cols = data) |>
    mutate(distnced = ifelse(distnced == '1', 1, 0),
           ft_ug = ifelse(ft_ug == '1', 1, 0)) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "characteristics", characteristics, overwrite = TRUE)
  saveRDS(characteristics, 'data/characteristics.rds')
  # housekeeping
  rm(characteristics)
})




# grab submission flags 
system.time({
  submissions <-
    ipeds_years |>
    mutate(data = map(collection_year, load_submissions),
           year_key = collection_year + 1) |>
    select(year_key, data) |>
    unnest(cols = data) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "submissions", submissions, overwrite = TRUE)
  saveRDS(submissions, 'data/submissions.rds')
  # housekeeping
  rm(submissions)
})


# grab fall enrollment data
system.time({
  fall_enrollment <-
    ipeds_years |>
    mutate(data = map(collection_year, load_fall_enrollment),
           year_key = collection_year + 1) |>
    unnest(cols = data) |>
    pivot_longer(cols = efnralm:ef2morw,
                 names_to = "variable", 
                 values_to = "headcount") |>
    separate(variable, c("survey", "demographic_key"), sep = 2) |>
    select(-c(survey, collection_year)) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "fall_enrollment", fall_enrollment, overwrite = TRUE)
  saveRDS(fall_enrollment, 'data/fall_enrollment.rds')
  # housekeeping
  rm(fall_enrollment)
})



# grab enrollment by state of residence
system.time({
  enrollment_by_state <-
    ipeds_years |>
    mutate(data = map(collection_year, load_state_enrollment),
           year_key = collection_year + 1) |>
    unnest(cols = data) |>
    filter(!efcstate %in% c('58', '99'),
           line != '999') |>
    mutate(fips = as.integer(line),
           `Other First-time` = as.numeric(efres01) - as.numeric(efres02),
           `Recent HS Graduates` = as.numeric(efres02)) |>
    select(unitid, year_key, fips, `Recent HS Graduates`, `Other First-time`) |>
    pivot_longer(cols = c(`Recent HS Graduates`, `Other First-time`),
                 names_to = 'cohort',
                 values_to = 'headcount',
                 values_drop_na = TRUE) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "enrollment_by_state", enrollment_by_state, overwrite = TRUE)
  saveRDS(enrollment_by_state, 'data/enrollment_by_state.rds')
  # housekeeping
  rm(enrollment_by_state)
})




# grab retention
system.time({
  retention <-
    ipeds_years |>
    mutate(data = map(collection_year, load_retention),
           year_key = collection_year + 1) |>
    unnest(cols = data) |>
    as.data.table()
  
  if(!'grcohort' %in% colnames(retention)) {
    retention$grcohort <- 0
  }
  
  retention[, `:=`(gradrate_cohort = as.integer(grcohort),
                   entering_undergraduates = as.integer(ugentern),
                   percentage_of_class = as.numeric(pgrcohrt),
                   retention_ft = as.numeric(ret_pcf) / 100,
                   retention_pt = as.numeric(ret_pcp) / 100,
                   collection_year = NULL)]
  
  # write table to db
  # dbWriteTable(db, "retention", retention, overwrite = TRUE)
  saveRDS(retention, 'data/retention.rds')
  # housekeeping
  rm(retention)
})




# grab academic year charges data
system.time({
  academic_year_charges <-
    ipeds_years |>
    mutate(data = map(collection_year, load_charges),
           year_key = collection_year + 1) |>
    unnest(cols = data) |>
    select(unitid, year_key, field, value) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "academic_year_charges", academic_year_charges, overwrite = TRUE)
  saveRDS(academic_year_charges, 'data/academic_year_charges.rds')
  # housekeeping
  rm(academic_year_charges)
})





# grab undergraduate financial aid data
system.time({
  student_financial_aid <-
    ipeds_years |>
    mutate(data = map(collection_year, load_sfa)) |>
    rename(year_key = collection_year) |>
    unnest(cols = data) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "student_financial_aid", student_financial_aid, overwrite = TRUE)
  saveRDS(student_financial_aid, 'data/student_financial_aid.rds')
  # housekeeping
  rm(student_financial_aid)
})




# grab finance data
system.time({
  finance <- 
    ipeds_years |>
    mutate(accounting_standard = 'FASB',
           data = map(collection_year, load_fasb)) |>
    rename(year_key = collection_year) |>
    unnest(cols = data)
  
  finance <- 
    ipeds_years |>
    mutate(accounting_standard = 'GASB',
           data = map(collection_year, load_gasb)) |>
    rename(year_key = collection_year) |>
    unnest(cols = data) |>
    bind_rows(finance) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "finance", finance, overwrite = TRUE)
  saveRDS(finance, 'data/finance.rds')
  # housekeeping
  rm(finance)
})




# write updated year table to db
system.time({
  ipeds_years <-
    ipeds_years |>
    rename(year_key = collection_year) |>
    mutate(fiscal_year = paste(year_key - 1,
                               year_key,
                               sep = '-'),
           academic_year = paste(year_key - 1,
                                 year_key,
                                 sep = '-'),
           calendar_year_fall = year_key - 1,
           calendar_year_spring = year_key) |>
    as.data.table()
  
  # write table to db
  # dbWriteTable(db, "ipeds_years", ipeds_years, overwrite = TRUE)
  saveRDS(ipeds_years, 'data/ipeds_years.rds')
  # housekeeping
  rm(ipeds_years)
})

