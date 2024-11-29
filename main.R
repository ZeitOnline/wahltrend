needs(dplyr, readr, stringr, tidyr, rvest, lubridate, xml2, numform, purrr, jsonlite)

# Our code to collect and clean recent polling data is not shared to the public.
# To make our calculations reproducable, we provide a dump of polls up to February 20th, 2024.
polls <-
  'data/polls.csv' %>% read_csv()

# Load pollster ratings based on earlier performance
ratings <-
  'data/pollster-rating.csv' %>% read_csv()

fit_trend <- function(state = 'BT', start = ymd('2021-09-26'), end = Sys.Date()){
  # parameters are different for federal and state level,
  # to account for the large difference in number of available polls.
  # federal level: time-dependent weight falls to 50% after two weeks.
  # state level: time-dependent weight falls to 50% after three months.
  if (state == 'BT'){
    14 -> a
    5 -> b
  } else {
    90 -> a
    13 -> b
  }
  trend <-
    tibble(
      Date = date(),
      Party = character(),
      Pct = numeric()
    )
  
  fit <-
    polls %>% 
    filter(Parliament_ID == state) %>% 
    pivot_longer(names_to = 'Party', values_to = 'Pct', cols = c(5:ncol(.))) %>% 
    select(Poll_ID, Pollster, Date, Party, Pct)
  
  for (rolldate in c(ymd(start):ymd(end))){
    rolldate <-
      rolldate %>% as_date()
    rollavg <-
      fit %>% 
      mutate(Age = (rolldate - Date) %>% as.numeric()) %>% 
      filter(
        Age >= 0
      ) %>% 
      left_join(ratings, by = 'Pollster') %>% # pollster-dependent wage
      mutate(
        wAge = (1 / (exp((Age-a)/b)+1)) %>% round(6), # time-dependent wage
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
        wPollster = ifelse(is.na(Rating), 0.5, Rating), # if no pollster weight available, set to a low value of 0.5
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
    
    trend <-
      trend %>%
      rbind(rollavg) %>% 
      as_tibble()
  }
  trend %>% return()
}

fit_trend('BT', end = '2024-02-20') -> trend_bund