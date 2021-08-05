df.wahlrecht <-
  tibble(
    'ID' = integer(),
    'Institut' = character(),
    'Befragte'= character(),
    'Datum' = character(),
    'Partei' = character(),
    'Pct' = character()
  )

pollsterPages <- 
("http://www.wahlrecht.de/umfragen/index.htm" %>% 
  read_html() %>% 
  html_node('table.wilko') %>% 
  html_node("thead") %>% 
  html_nodes("a") %>% 
  map(xml_attrs) %>% 
  map_df(~as.list(.))
  )$href

for (i in c(1:length(pollsterPages))){
  institute <- pollsterPages[i]
  url <- paste0("http://wahlrecht.de/umfragen/",institute)
  
  table <-
    tibble(
      'ID' = integer(),
      'Datum' = character(),
      'Befragte' = character(),
      'Zeitraum' = character(),
      'Partei' = character(),
      'Pct' = character()
    )
  
  url %>% 
    read_html() %>% 
    html_node("table.wilko") %>% 
    html_table(fill = T) %>% 
    as_tibble(.name_repair = "unique") ->
    t
  
  t[[1,1]] <- "Datum"
  t[,2] <- as.character(t[,2])
  t[[1,2]] <- "X1"
  names(t) <- as.character(as.vector(t[1,]))
  for (k in c(1:length(names(t)))){if(is.na(names(t)[k])){names(t)[k] <- paste0("NULL",k)}}
  for (k in c(1:length(names(t)))){if(names(t)[k] == "NA"){names(t)[k] <- paste0("NULL",k)}}
  for (k in c(1:length(names(t)))){if(names(t)[k] == ""){names(t)[k] <- paste0("NULL",k)}}
  if(!("Befragte" %in% names(t))){t %>% mutate(Befragte = NA) -> t}
  if(!("Zeitraum" %in% names(t))){t %>% mutate(Zeitraum = NA) -> t}
  table <-
    t %>% 
    select(-X1) %>% 
    unique() %>% 
    mutate(ID = nrow(.) + 1 - row_number()) %>% 
    select(ID, Datum, Befragte, Zeitraum,everything()) %>% 
    gather(key = "Partei", value = "Pct", 5:ncol(.)) %>% 
    mutate(
      Institut = institute,
      Land = "Bundestag"
    ) %>% 
    select(ID, Institut,Datum,Befragte,Partei,Pct)
  
  df.wahlrecht <-
    df.wahlrecht %>% 
    rbind(table)
}

rm(t,table,i,pollsterPages,institute,k,url)

################
### regex to clean data
################
df_wahlrecht <-
  df.wahlrecht %>%
  unique() %>% 
  separate(Partei, into = c("Partei"), sep = "[.]", extra = "drop") %>% 
  mutate(
    Institut = str_remove(Institut,".htm"),
    Datum = dmy(Datum),
    Pct = Pct %>% str_remove(" %") %>% str_replace(",","."),
    Partei = ifelse(Partei %in% c("CDU","CSU","CDU/CSU"),"CDUCSU",Partei),
    Pct = Pct %>% str_remove_all("[*]") %>%
      str_remove("%") %>% str_remove(" ")
  ) %>%
  filter(
    !is.na(Datum),
    !str_detect(Befragte, "wahl"),
    Partei %in% c("CDUCSU","SPD","GRÜNE","FDP","LINKE","AfD","PDS"),
    !str_detect(Pct,"[?]"),
    !str_detect(Pct,"[a-z]"),
    Pct != "–"
  ) %>%
  mutate(Pct = as.numeric(Pct)) %>% 
  mutate(
    Befragte = Befragte %>% 
      str_remove("[A-Z]+") %>% 
      str_remove(" • ") %>% 
      str_remove('[.]') %>% 
      as.integer()
  ) %>%
  select(ID, Institut, Datum, Befragte,Partei,Pct)

df_wr_polls <-
  df_wahlrecht %>% 
  select(ID, Institut,Datum) %>% 
  left_join("data/match_institute.csv" %>% read_csv()) %>% 
  unique() %>% 
  mutate(
    Poll_ID =
      paste0(
        'BT',
        f_pad_zero(Institute_ID, 2),
        Datum %>% year() %>% as.character() %>% str_sub(-2,-1),
        Datum %>% month() %>% as.character() %>% f_pad_zero(2),
        Datum %>% day() %>% as.character() %>% f_pad_zero(2),
        (ID %% 26) %>% LETTERS[.]
      )
  )

df_wahlrecht <-
  df_wahlrecht %>% 
  left_join(df_wr_polls) %>% 
  left_join('data/match_party.csv' %>% read_csv()) %>%
  select(Poll_ID, 'Pollster' = Institute_Name,'Date' = Datum, 'n' = Befragte, 'Party' = Party_Name,Pct)

################
### end regex
################

df_polls <- 
  df_wahlrecht %>% 
  filter(year(Date) >= 2020) %>% 
  select(Poll_ID, Pollster, Date, n, Party, Pct)

rm(df_wahlrecht, df.wahlrecht, df_wr_polls)