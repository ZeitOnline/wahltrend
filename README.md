# ZEIT-ONLINE-Wahltrend

**Polling average for German elections**

This project calculates weighted averages of political opinion polls from Germany, which measure voting intentions for the eletions of federal and state parliaments.

Polling data is obtained from [Wahlrecht.de](https://www.wahlrecht.de/umfragen/index.htm).

Our 'Wahltrend' is calculated as a rolling, weighted average of all available polls about the respective election.

We calculate Wahltrend values for each day of the year on the federal level. If a Wahltrend can be calculated for a given state depends on the number of recent polls available.

 Polls are weighted according to three factors:

### Age of poll
The age is calculated in days, from date of publication to current date.
A poll which was published on the current day gets max. weight. The weight decreases exponentially over time, to 50% after two weeks on the federal level and to 50% after three months on the state level (there less polls are conducted) .

### Past performance
For each source, we calculate a rating based on past performance of its polls. Performance is measured as mean difference between poll and election result, in pct points. Considered are all polls since 1990 in federal and state elections which apperead within 30 days before election day. Polls for federal elections get a bigger weight for the rating, as do polls in more recent years.

### Number of polls
The newest poll of each source gets maximum weight, the second-newest half weight, etc. This is done to prevent very active pollster from dominating our average.

An overview of all pollsters included in our average and their weight:
|**Pollster**|**Historical Mean Error**|**Weight**|
|---|---|---|
|Allensbach|1.03|1.00|
|GMS|1.34|0.77|
|Forschungsgruppe Wahlen|1.49|0.69|
|Infratest dimap|1.67|0.62|
|Emnid|1.88|0.55|
|Forsa|1.92|0.54|
|YouGov|1.99|0.52|
|INSA|2.03|0.51|

[See our current Wahltrend visualised on ZEIT ONLINE](https://www.zeit.de/politik/deutschland/wahlumfragen-landtagswahlen-bundestagswahl-spd-cdu-gruene-fdp-afd)

[Read more on our Pollster ratings (in German)](https://www.zeit.de/politik/deutschland/2021-06/wahlumfragen-sachsen-anhalt-landtagswahl-wahlverhalten-waehler)

Questions? Comments? [christian [punkt] endt [at] zeit.de](mailto:christian.endt@zeit.de) | [@c_endt](https://twitter.com/c_endt)

(c) 2021-2024 ZEIT ONLINE GmbH. All rights reserved. [See license](LICENSE.md)