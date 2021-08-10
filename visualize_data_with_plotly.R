library(plotly)
library(htmlwidgets)

#source('main.R')

# create plot with custom colors
fig <- plot_ly(data = df_trend, 
               x = ~Date, 
               y = ~Pct, 
               color = ~Party, 
               type = 'scatter', 
               mode = 'lines',
               colors = c("#489FE1", "#000000", "#F7CA18", "#38A228", "#800080", "#ff3300"))

# customize legend with extra text
fig <- fig %>% layout(legend=list(title=list(text='<b> Parteien </b>')))

# add different info on the timeline
fig <- fig %>% add_annotations(
  x=df_trend$Date[[331]],
  y=df_trend$Pct[[331]],
  text = "CDU/CSU Maskenaffäre"
)

fig <- fig %>% add_annotations(
  x=df_trend$Date[[601]],
  y=df_trend$Pct[[601]],
  text = "Kanzlerkandidatur Laschet"
)

fig <- fig %>% add_annotations(
  x=df_trend$Date[[651]],
  y=df_trend$Pct[[651]],
  text = "Kanzlerkandidatur Baerbock"
)

fig <- fig %>% add_annotations(
  x=df_trend$Date[[770]],
  y=df_trend$Pct[[770]],
  text = "Scholz als Kanzlerkandidat bestätigt"
)

fig <- fig %>% add_annotations(
  x=df_trend$Date[[1071]],
  y=df_trend$Pct[[1071]],
  text = "Plagiatsvorwürfe gegen Baerbock"
)

# Add custom text to each axis
f <- list(
  family = "Helvetica",
  size = 18,
  color = "#7f7f7f"
)

x <- list(
  title = "Monat",
  titlefont = f
)

y <- list(
  title = "Prozentpunkte",
  titlefont = f
)

fig <- fig %>% layout(xaxis = x, yaxis = y)

# show all values simultaneously while mouser-over
fig <- fig %>% config(displayModeBar = TRUE) %>%
  layout(hovermode = 'compare')

# save figure as index.html
widget_file_size <- function(p) {
  d <- getwd()
  withr::with_dir(d, htmlwidgets::saveWidget(p, "index.html"))
  f <- file.path(d, "index.html")
  mb <- round(file.info(f)$size / 1e6, 3)
  message("File is: ", mb," MB")
}

widget_file_size(fig)