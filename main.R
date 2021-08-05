library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(rvest)
library(lubridate)
library(xml2)
library(numform)
library(purrr)

# Scrape Polling data from Wahlrecht.de
# returns a single dataframe: df_polls
source('get_polls.R')

df_trend <-
  tibble(Date = date(), Party = character(), Pct = numeric())

# calculate Wahltrend values for each day of the year 
# Polls are weighted according to three factors:
# wAge - age of Poll in days (from date of publication)
# wSeq - number of polls by same source in the meantime (the newest poll of each source gets max. weight)
# wPollster - past performance of polls by that source
# past performance is measured as mean difference between poll and election result, in pct points
# considered are all polls since 1990 in federal and state elections, with a bigger weight on federal and more recent elections.
for (rolldate in c(ymd('2021-01-01'):Sys.Date())){
  rolldate <-
    rolldate %>% as_date()
  rollavg <-
    df_polls %>% 
    mutate(Age = (rolldate - Date) %>% as.numeric()) %>% 
    filter(
      Age >= 0#,
      #Age < 29
    ) %>% 
    left_join(('data/pollster_rating.csv' %>% read_csv())) %>% 
    mutate(
      wAge = (1 / (exp((Age-14)/3.5)+1)) %>% round(4),
      wPollster = (min(Mean_Error) / Mean_Error) %>% round(4)
    ) %>% 
    group_by(Pollster,Party) %>% 
    arrange(desc(Date)) %>% 
    mutate(
      pollRank = rank(desc(Date)),
      wSeq = (2**(1 - pollRank)) %>% round(3)
    ) %>% 
    ungroup() %>% 
    filter(wSeq > 0) %>% 
    mutate(Weight = wAge * wPollster * wSeq) %>% 
    group_by(Party) %>% 
    mutate(
      Total_Weights = Weight %>% sum(),
      Avg_Pct = (sum(Pct * Weight) / Total_Weights) %>% round(2)
    ) %>% 
    ungroup() %>% 
    select(Party,'Pct' = Avg_Pct) %>% 
    unique() %>% 
    mutate(Date = rolldate) %>% 
    select(Date, everything())
  
  df_trend <-
    df_trend %>%
    rbind(rollavg)
}

rm(rollavg, rolldate)