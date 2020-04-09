run_model <- function(fml, df) {
  # run a linear model (fml) on data frame (df)
  lm(formula = as.formula(fml), 
     data = df)
}




net_load_zip <- function(file_url, file_name)
{
  # access zipped data via net
  temp <- tempfile()
  
  download.file(file_url,
                temp)
  
  files <- unzip(temp, list = TRUE)
  
  spec <- files$Name[str_detect(files$Name, "_rv")]
  
  file_name <- ifelse(length(spec) == 0, file_name, spec)
  
  data <- 
    read_csv(unz(temp, file_name),
             locale = locale(encoding = "latin1"),
             col_types = cols(.default = col_character())) %>%
    rename_all(tolower)
  
  unlink(temp)
  rm(temp)
  
  return(data)
}




collapse_year <-
  function(year) {
    # collapse year for fiscal years
    str_c(str_sub(year - 1, 3 ,4),
          str_sub(year, 3 ,4))
  }




load_ic <- function(year)
{
  # access institutional characteristics data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/IC', year - 1, '.zip')
  name <- str_c('ic', year - 1, '.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower)
  
  if ('distnced' %in% colnames(df))
  {
    df <-
      df %>%
      mutate(distance_ed = ifelse(distnced == '1', 1, 0))
  }
  else
  {
    df$distance_ed <- 0
  }
  
  df %>%
    select(unitid, distance_ed, ft_ug)
}




load_hd <- function(year)
{
  # access directory data via net
  ic <- load_ic(year)
  
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/HD', year - 1, '.zip')
  name <- str_c('hd', year - 1, '.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    filter(iclevel == '1') %>%
    inner_join(ic, by = 'unitid') %>%
    mutate(Control = recode(control,
                            '1' = 'Public',
                            '2' = 'Private',
                            '3' = 'Proprietary',
                            .default = 'Unknown'),
           deathyr = as.integer(deathyr),
           Closed = ifelse(deathyr < 0, 0, 1),
           `Close Year` = ifelse(Closed == 1,
                                 deathyr,
                                 NA),
           obereg = as.integer(obereg),
           FIPS = as.integer(fips))
  
  if ('longitud' %in% colnames(df))
  {
    df <-
      df %>%
      mutate(Longitude = as.double(longitud),
             Latitude = as.double(latitude))
  }
  else
  {
    df <-
      df %>%
      mutate(Longitude = NA,
             Latitude = NA)
  }
  
  df %>%
    select(unitid,
           distance_ed,
           obereg,
           opeflag,
           ft_ug,
           deggrant,
           `Institution Name` = instnm,
           City = city,
           State = stabbr,
           FIPS,
           Control,
           Closed,
           `Close Year`,
           Longitude,
           Latitude)
}




load_submissions <- function(year)
{
  # download submission flags data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/FLAGS', year, '.zip')
  name <- str_c('flags', year, '.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    filter(cohrtstu == '1') %>%
    mutate(parent_id = ifelse(prch_f %in% c('1', '2', '3'), idx_f, unitid)) %>%
    select(unitid,
           parent_id)
}




load_total_enrollment <- function(year)
{
  # download total fall enrollment data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/EF', year - 1, 'A.zip')
  name <- str_c('ef', year - 1, 'a.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    filter(line == '1') 
  
  if ('eftotlt' %in% colnames(df))
  {
    df <-
      df %>%
      mutate(`UG First-time First Year Enrollment` = as.numeric(eftotlt))
  }
  else
  {
    df <-
      df %>%
      mutate(`UG First-time First Year Enrollment` = as.numeric(efrace15) + as.numeric(efrace16))
  }
  
  df %>%
    select(unitid, `UG First-time First Year Enrollment`)
}




load_state_enrollment <- function(year)
{
  # download state fall enrollment data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/EF', year - 1, 'C.zip')
  name <- str_c('ef', year - 1, 'c.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    filter(!line %in% c('58', '99')) %>%
    mutate(efres01 = as.numeric(efres01)) %>%
    select(unitid, line, efres01)
}




load_retention <- function(year)
{
  # download retention data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/EF', year - 1, 'D.zip')
  name <- str_c('ef', year - 1, 'd.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    # mutate(`UG First-time First Year Enrollment` = as.numeric(grcohrt)) %>%
    select(unitid, ret_pcf)
}




load_charges <- function(year)
{
  # download academic year charges data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/IC', year - 1, '_AY.zip')
  name <- str_c('ic', year - 1, '_ay.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    select(unitid, tuition2, tuition3)
}




load_sfa <- function(year)
{
  # download student financial aid data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/SFA',
               collapse_year(year),
               '.zip')
  name <- str_c('sfa',
                collapse_year(year),
                '.csv')
  
  df <-
    net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    replace_na(replace = list(igrnt_t = 0)) %>%
    select(unitid, igrnt_t)
}




load_fasb <- function(year)
{
  # access FASB (F2) data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/F',
               collapse_year(year),
               '_F2.zip')
  name <- str_c('f',
                collapse_year(year),
                '_f2.csv')
  
  net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    select(unitid, 
           `State Appropriations` = f2d03,
           `Total Expenses` = f2e131, 
           `Hospital Expenses` = f2e091, 
           `Endowment EOY` = f2h02)
}




load_gasb <- function(year)
{
  # access GASB (F1A) data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/F',
               collapse_year(year),
               '_F1A.zip')
  name <- str_c('f',
                collapse_year(year),
                '_f1a.csv')
  
  net_load_zip(url, name) %>%
    rename_all(tolower) %>%
    select(unitid,
           `State Appropriations` = f1b11,
           `Total Expenses` = f1c191, 
           `Hospital Expenses` = f1c121, 
           `Endowment EOY` = f1h02)
}

