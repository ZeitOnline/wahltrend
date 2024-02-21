needs(dplyr, readr, stringr, tidyr, rvest, lubridate, xml2, numform, purrr, jsonlite)

# Our code to collect and clean recent polling data is not shared to the public.
# To make our calculations reproducable, we provide a dump of polls up to February 20th, 2024.
'data/polls.csv' %>% read_csv() -> df_polls

# Load pollster ratings based on earlier performance
'data/pollster_rating.csv' %>% read_csv() %>% 
  mutate(wPollster = (min(Mean_Error) / Mean_Error) %>% round(4)) ->
  df_ratings

'data/output/pollster_rating.csv' %>% read_csv() %>% 
  mutate(wPollster = (min(Mean_Error) / Mean_Error) %>% round(4)) ->
  df_ratings

fit_trend <- function(state = 'BT', start = ymd('2021-09-26')){
  # parameters are different for federal and state level,
  # to account for the large difference in number of available polls.
  # federal level: time-dependent weight falls to 50% after two weeks.
  # state level: time-dependent weight falls to 50% after three months.
  if (state == 'BT'){
    14 -> a
    3.5 -> b
  } else {
    90 -> a
    13 -> b
  }
  df_trend <-
    tibble(
      Date = date(),
      Party = character(),
      Pct = numeric()
    )
  
  df_fit <-
    df_polls %>% 
    filter(Parliament_ID == state) %>% 
    pivot_longer(names_to = 'Party', values_to = 'Pct', cols = c(5:ncol(.))) %>% 
    select(Poll_ID, Pollster, Date, Party, Pct)
  
  for (rolldate in c(ymd(start):Sys.Date())){
    rolldate <-
      rolldate %>% as_date()
    rollavg <-
      df_fit %>% 
      mutate(Age = (rolldate - Date) %>% as.numeric()) %>% 
      filter(
        Age >= 0
      ) %>% 
      left_join(df_ratings, by = 'Pollster') %>% # pollster-dependent wage
      mutate(
        wAge = (1 / (exp((Age-a)/b)+1)) %>% round(6) # time-dependent wage
      ) %>% 
      group_by(Pollster,Party) %>% 
      arrange(desc(Date)) %>% 
      mutate(
        rank = rank(desc(Date)),
        wSeq = (2**(1 - rank)) %>% round(3) # if several polls by the same pollster exist, only the most recent one gets full weight
      ) %>% 
      ungroup() %>% 
      filter(wSeq > 0) %>% 
      mutate(
        wPollster = ifelse(is.na(wPollster), 0.5, wPollster), # if no pollster weight available, set to a low value of 0.5
        Weight = wAge * wPollster * wSeq) %>% 
      select(Poll_ID, Pollster, Date, Party, Pct, Weight) %>% 
      group_by(Party) %>% 
      mutate(
        Total_Weights = Weight %>% sum(),
        Avg_Pct = (sum(Pct * Weight) / Total_Weights) %>% round(2)
      ) %>% 
      ungroup() %>% 
      select(Party,'Pct' = Avg_Pct) %>% 
      unique() %>% 
      mutate(Date = rolldate)
    
    df_trend <-
      df_trend %>%
      rbind(rollavg) %>% 
      as_tibble()
  }
  df_trend %>% return()
}

fit_trend('BT') -> trend_bund
fit_trend('SN') -> trend_sax