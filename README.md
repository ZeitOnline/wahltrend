# ZEIT-ONLINE-Wahltrend

**Polling average for Bundestagswahl 2021**

This project calculates a weighted average of current opinion polls for the German federal election 2021 (Bundestagswahl).

Polling data is optained from [Wahlrecht.de](https://www.wahlrecht.de/umfragen/index.htm).

Our 'Wahltrend' is calculated as a rolling, weighted average of all available polls.

calculate Wahltrend values for each day of the year 

 Polls are weighted according to three factors:

### Age of poll
The age is calculated in days, from date of publication to current date.
A poll which was published on the current day gets max. weight. The weight decreases exponentially over time, to 50% after two weeks and close to zero after 4 weeks.

### Number of polls
The newest poll of each source gets maximum weight, the second-newest half weight, etc. This is done to prevent very active pollster from dominating our average.

### Past performance
For each source, we calculate a rating based on past performance of its polls. Performance is measured as mean difference between poll and election result, in pct points. Considered are all polls since 1990 in federal and state elections, with a bigger weight on federal and more recent elections.

An overview of all pollsters included in our average and their weight:
|**Pollster**|**Historical Mean Error**|**Weight**|
|---|---|---|
|Forschungsgruppe Wahlen|1.54|1|
|Infratest dimap|1.61|0.96|
|Allensbach|1.67|0.92|
|Emnid|1.73|0.89|
|GMS|1.76|0.87|
|Forsa|1.94|0.79|
|INSA|1.99|0.77|
|YouGov|2.21|0.7|

[See our current Wahltrend visualised on ZEIT ONLINE](https://zeit.de/2021-08/sonntagsfrage-bundestagswahl-2021-bundeskanzler-koalition-umfragen)

[Read more on our Pollster ratings (in German)](https://www.zeit.de/politik/deutschland/2021-06/wahlumfragen-sachsen-anhalt-landtagswahl-wahlverhalten-waehler)

Questions? Comments? [christian [punkt] endt [at] zeit.de](mailto:christian.endt@zeit.de) | [@c_endt](https://twitter.com/c_endt)