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
    rename_all(tolower) %>%
    select(-starts_with('x'))
  
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
  
  net_load_zip(url, name)
  }




load_hd <- function(year)
{
  # access directory data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/HD', year, '.zip')
  name <- str_c('hd', year, '.csv')
  
  net_load_zip(url, name)
}




load_submissions <- function(year)
{
  # download submission flags data via net
  if (year < 2004)
    {
      url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/HD', year, '.zip')
      name <- str_c('hd', year, '.csv')
      
      net_load_zip(url, name) %>%
        select(unitid,
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
               f1systyp,
               f1sysnam,
               fte,
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
               rev_gr)
  }
  else
  {
    url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/FLAGS', year, '.zip')
    name <- str_c('flags', year, '.csv')
    
    net_load_zip(url, name)
  }
    
}




load_fall_enrollment <- function(year)
{
  # download total fall enrollment data via net
  url <- str_c('https://nces.ed.gov/ipeds/datacenter/data/EF', year, 'A.zip')
  name <- str_c('ef', year, 'a.csv')
  
  recordset <-
    net_load_zip(url, name)
  
  if (year < 2002) {
    recordset <- 
      recordset %>%
      mutate(efalevel = recode(as.integer(line),
                               `1` = 24,
                               `3` = 25,
                               `7` = 31,
                               `11` = 32,
                               `9` = 36,
                               `15` = 44,
                               `17` = 45,
                               `21` = 51,
                               `25` = 52,
                               `23` = 56,
                               .default = 99))
  }
  
  if (year < 2008) {
    recordset <- 
      recordset %>%
      filter(efalevel %in% c(24, 25, 31, 32, 36, 44, 45, 51, 52, 56)) %>%
      mutate(efnralm = as.integer(efrace01),
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
             efnhpim = as.integer(0),
             efnhpiw = as.integer(0),
             efwhitm = as.integer(efrace11),
             efwhitw = as.integer(efrace12),
             ef2morm = as.integer(0),
             ef2morw = as.integer(0))
    
  }
  
  if (year == 2008) {
    recordset <- 
      recordset %>%
      filter(efalevel %in% c(24, 25, 31, 32, 36, 44, 45, 51, 52, 56)) %>%
      mutate(efnralm = as.integer(efnralm),
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
             efnhpim = as.integer(0),
             efnhpiw = as.integer(0),
             efwhitm = as.integer(dvefwhm),
             efwhitw = as.integer(dvefwhw),
             ef2morm = as.integer(0),
             ef2morw = as.integer(0))
  }
  
  if (year == 2009) {
    recordset <- 
      recordset %>%
      filter(efalevel %in% c(24, 31, 32, 39, 40, 44, 51, 52, 59, 60)) %>%
      mutate(efnralm = as.integer(efnralm),
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
             efnhpim = as.integer(0),
             efnhpiw = as.integer(0),
             efwhitm = as.integer(dvefwhm),
             efwhitw = as.integer(dvefwhw),
             ef2morm = as.integer(0),
             ef2morw = as.integer(0))
  }
  
  if (year > 2009) {
    recordset <- 
      recordset %>%
      filter(efalevel %in% c(24, 31, 32, 39, 40, 44, 51, 52, 59, 60)) %>%
      mutate(efnralm = as.integer(efnralm),
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
             ef2morw = as.integer(ef2morw))
  }
  
  recordset %>%
    mutate(time_status = recode(efalevel,
                                `24` = "Full-time",
                                `25` = "Full-time",
                                `31` = "Full-time",
                                `32` = "Full-time",
                                `36` = "Full-time",
                                `39` = "Full-time",
                                `40` = "Full-time",
                                .default = "Part-time"),
           career_level = recode(efalevel,
                                 `32` = "Graduate",
                                 `36` = "Graduate",
                                 `52` = "Graduate",
                                 `56` = "Graduate",
                                 .default = "Undergraduate"),
           degree_seeking = recode(efalevel,
                                   `24` = "Degree-seeking",
                                   `25` = "Degree-seeking",
                                   `31` = "Non-degree-seeking",
                                   `39` = "Degree-seeking",
                                   `40` = "Degree-seeking",
                                   `44` = "Degree-seeking",
                                   `45` = "Degree-seeking",
                                   `51` = "Non-degree-seeking",
                                   `59` = "Degree-seeking",
                                   `60` = "Degree-seeking",
                                   .default = "Unknown"),
           continuation_type = recode(efalevel,
                                      `24` = "First-time",
                                      `39` = "Transfer",
                                      `40` = "Continuing",
                                      `44` = "First-time",
                                      `59` = "Transfer",
                                      `60` = "Continuing",
                                      .default = "Unknown")) %>%
    select(unitid, time_status:continuation_type,
           efnralm, efnralw, efunknm, efunknw, efhispm,
           efhispw, efaianm, efaianw, efasiam, efasiaw,
           efbkaam, efbkaaw, efnhpim, efnhpiw, efwhitm,
           efwhitw, ef2morm, ef2morw)  
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

