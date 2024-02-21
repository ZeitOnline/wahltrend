'data/pollster_rating.csv' %>% read_csv() %>% 
  mutate(wPollster = (min(Mean_Error) / Mean_Error) %>% round(4)) ->
  df_ratings

fit_federal_trend <- function(start = fit_start){
  df_btw_trend <-
    tibble(
      Date = date(),
      Party = character(),
      Pct = numeric()
    )
  
  df_btw <-
    df_polls %>% 
    filter(Parliament_Name == 'Bundestag') %>% 
    select(Poll_ID, 'Pollster' = Pollster_Name, Date, n, 'Party' = Party_Name, Pct)
  
  for (rolldate in c(ymd(start):Sys.Date())){
    rolldate <-
      rolldate %>% as_date()
    rollavg <-
      df_btw %>% 
      mutate(Age = (rolldate - Date) %>% as.numeric()) %>% 
      filter(
        Age >= 0#,
        #Age < 29
      ) %>% 
      left_join(df_ratings, by = 'Pollster') %>% 
      mutate(
        wAge = (1 / (exp((Age-14)/3.5)+1)) %>% round(4)
      ) %>% 
      group_by(Pollster,Party) %>% 
      arrange(desc(Date)) %>% 
      mutate(
        rank = rank(desc(Date)),
        wSeq = (2**(1 - rank)) %>% round(3)
      ) %>% 
      ungroup() %>% 
      filter(wSeq > 0) %>% 
      mutate(Weight = wAge * wPollster * wSeq) %>% 
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
    
    df_btw_trend <-
      df_btw_trend %>%
      rbind(rollavg) %>% 
      as_tibble()
  }
  df_btw_trend %>% return()
}