# Special Analysis, Feb 2023:
# Obtain a long time series of federal polling for a look at FDP performance

'data/poll_collect_dump_20230215.csv' %>% 
  read_csv() %>% 
  select(Poll_ID, 'Pollster' = Pollster_Name, Date, n, 'Party' = Party_Name, Pct) %>% 
  rbind(df_polls) %>% 
  unique() %>% 
  group_by(Date, Pollster, n, Party) %>% 
  filter(rank(Poll_ID) == 1) %>% 
  ungroup() ->
  all_polls

df_trend <-
  tibble(Date = date(), Party = character(), Pct = numeric())

# calculate Wahltrend values for each day of the year 
# Polls are weighted according to three factors:
# wAge - age of Poll in days (from date of publication)
# wSeq - number of polls by same source in the meantime (the newest poll of each source gets max. weight)
# wPollster - past performance of polls by that source
# past performance is measured as mean difference between poll and election result, in pct points
# considered are all polls since 1990 in federal and state elections, with a bigger weight on federal and more recent elections.
for (rolldate in c(ymd('2000-08-01'):Sys.Date())){
  rolldate <-
    rolldate %>% as_date()
  rollavg <-
    all_polls %>% 
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

df_trend %>% 
  filter(Party == 'FDP') %>% select(Date,Pct) %>% 
  arrange(Date) %>% 
  mutate(Smooth = Pct %>% RcppRoll:::roll_mean(n=28, align = 'right', fill =NA) %>% round(2)) %>% 
  clipr::write_clip()
  mutate(Pollster = 'Wahltrend') %>% 
  rbind(all_polls %>% filter(Party == 'FDP') %>% select(Date, Party, Pct, Pollster)) %>% 
  select(-Party) %>% 
  clipr::write_clip()