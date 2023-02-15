# Special Analysis, Feb 2023:
# Obtain a long time series of FDP performance at state elections
# Source: https://docs.google.com/spreadsheets/u/1/d/19tNX3uvMCwGZM2WpHHWsx9QuxDQqC5BVhz5V-zsVNIg

'data/de_landtagswahlen.csv' %>% 
  read_csv() -> df_ltw

df_ltw %>% 
  filter(!(Land %in% c('Europa','Bund'))) %>% 
  select(Land,Wahltag,'Ergebnis' = FDP) %>% 
  mutate(Wahltag = Wahltag %>% dmy()) %>% 
  group_by(Land) %>% 
  arrange(Wahltag) %>% 
  mutate(
    Jahr = year(Wahltag),
    Label = paste0(Land,' ',year(Wahltag)),
    Vorergebnis = lag(Ergebnis),
    Diff = Ergebnis - Vorergebnis,
    Loose = Diff < 0
    ) %>% 
  filter(year(Wahltag) > 2017) %>% 
  clipr::write_clip()