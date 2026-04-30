# Income Inequality Before and After Taxes

This week we're exploring Income Inequality Before and After Taxes, as processed and visualized by Joe Hasell at Our World in Data: ["Income inequality before and after taxes: how much do countries redistribute income?"](https://ourworldindata.org/income-inequality-before-and-after-taxes)

All data was processed by [Our World in Data]](https://ourworldindata.org), using these sources:
- [Luxembourg Income Study (2025)](https://www.lisdatacenter.org/our-data/lis-database/)
- [OECD (2024)](https://www.oecd.org/en/data/datasets/income-and-wealth-distribution-database.html)
- [HYDE (2023)](https://public.yoda.uu.nl/geo/UU01/AEZZIT.html)
- [Gapminder - Population v7 (2022)](https://www.gapminder.org/data/documentation/gd003/)
- [UN, World Population Prospects (2024)](https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=Most%20used)
- [Gapminder - Systema Globalis (2022)](https://github.com/open-numbers/ddf--gapminder--systema_globalis)

> The Gini coefficient measures inequality on a scale from 0 to 1. Higher values indicate higher inequality. Inequality is measured here in terms of income before and after taxes and benefits.

- Which countries have the highest Gini coefficient before taxes?
- Which countries have the highest Gini coefficient after taxes?
- Which countries have the highest shifts in Gini coefficient?
- Which countries have the lowest shifts in Gini coefficient?
- Which countries have had the highest changes in redistribution in the available data?

Thank you to [Jon Harmon, Data Science Learning Community](https://github.com/jonthegeek) for curating this week's dataset.

## Data Dictionary

### `income_inequality_processed.csv`

|variable    |class     |description                           |
|:-----------|:---------|:-------------------------------------|
|Entity      |character |Country (or other region) name. |
|Code        |character |Three-digit code when available. |
|Year        |integer   |Year to which the data applies. |
|gini_mi_eq  |double    |The Gini coefficient measures inequality on a scale from 0 to 1. Higher values indicate higher inequality. Income is "pre-tax" — measured before taxes have been paid and most government benefits have been received. Income has been equivalized – adjusted to account for the fact that people in the same household can share costs like rent and heating. |
|gini_dhi_eq |double    |The Gini coefficient measures inequality on a scale from 0 to 1. Higher values indicate higher inequality. Income is "post-tax" — measured after taxes have been paid and most government benefits have been received. Income has been equivalized – adjusted to account for the fact that people in the same household can share costs like rent and heating. |

### `income_inequality_raw.csv`

|variable                   |class     |description                           |
|:--------------------------|:---------|:-------------------------------------|
|Entity                     |character |Country (or other region) name. |
|Code                       |character |Three-digit code when available. Some entities do not have codes, and some have special "OWID" codes, such as "OWID_AKD". |
|Year                       |integer   |Year to which the data applies. |
|gini_disposable__age_total |double    |The Gini coefficient measures inequality on a scale from 0 to 1. Higher values indicate higher inequality. Income is 'post-tax' — measured after taxes have been paid and most government benefits have been received. Income has been equivalized – adjusted to account for the fact that people in the same household can share costs like rent and heating. The entire population of each country is considered, and also the income definition is the newest from the OECD since 2012. For more information on the methodology, visit the [OECD Income Distribution Database (IDD)](http://www.oecd.org/social/income-distribution-database.htm). Survey estimates for 2020 are subject to additional uncertainty and are to be treated with extra caution, as in most countries the survey fieldwork was affected by the Coronavirus (COVID-19) pandemic. |
|gini_market__age_total     |double    |The Gini coefficient measures inequality on a scale from 0 to 1. Higher values indicate higher inequality. Income is 'pre-tax' — measured before taxes have been paid and most government benefits have been received. However, data for China, Hungary, Mexico, Turkey as well as part of the data for Greece refer to the income post taxes and before transfers. Income has been equivalized – adjusted to account for the fact that people in the same household can share costs like rent and heating. The entire population of each country is considered, and also the income definition is the newest from the OECD since 2012. For more information on the methodology, visit the [OECD Income Distribution Database (IDD)](http://www.oecd.org/social/income-distribution-database.htm). Survey estimates for 2020 are subject to additional uncertainty and are to be treated with extra caution, as in most countries the survey fieldwork was affected by the Coronavirus (COVID-19) pandemic. |
|population_historical      |double    |Population by country, available from 10,000 BCE to 2023, based on data and estimates from different sources. |
|owid_region                |character |World regions according to [Our World in Data](https://ourworldindata.org/). |
