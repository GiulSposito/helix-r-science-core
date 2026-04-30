# House and Mortgage data

Data this week comes from the Freddie Mac House Price Index at both the State and National level. The original source can be found [here](http://www.freddiemac.com/research/indices/house-price-index.html).

The House Price Index (HPI) is a broad measure of the movement of single-family house prices. The HPI is a weighted, repeat-sales index, meaning that it measures average price changes in repeat sales or refinancings on the same properties. This information is obtained by reviewing repeat mortgage transactions on single-family properties whose mortgages have been purchased or securitized by Fannie Mae or Freddie Mac since January 1975. - Quote from [Federal Housing Finance Agency](https://www.fhfa.gov/DataTools/Downloads/Pages/House-Price-Index.aspx)

If the term House Price Index is unfamiliar to you - check out the [technical documents](FM_HPI_Technical_Description.docx) or this [Wikipedia article](https://en.wikipedia.org/wiki/House_price_index).

Hint: A useful summary statistic could be the 12-month (yearly) percent change in the Price Index (eg is the price index rising or falling?).

We also have mortgage rates for fixed 30, fixed 15, and adjustable 5-1 Hybrids across time. Some of the data was only introduced in the 1990s and late 2000s, and as such some information can only be pulled from more recent data.

Lastly, we have included some recession dates in the US - the Great Recession (2007) had some major effects across many industries and markets. You can read more about some of the recent changes [here](http://bit.ly/2019-week6) from Fortune.


# Data Dictionary

### state_hpi.csv

|variable    |class     |description |
|:---|:---|:-----------|
|year        |date - integer   |      Year      |
|month       |date - integer   |    Month        |
|state       |character |   US State         |
|price_index |double    |   Calculated House Price Index - average price changes in repeat sales or refinancings at state level         |
|us_avg      |double    |   Calculated House Price Index - averaged at national level         |

### mortgage.csv

* Please notice that 30 year fixed rate data goes back to 1971, while the 15 year data begins in 1991 and the adjustable 5-1 Hybrid begins in 2005.

|variable                              |class  |description |
|:-----------|:---|:-----------|
|date                                  |date |     Date       |
|fixed_rate_30_yr                      |double |     Fixed rate 30 year mortgage (percent)       |
|fees_and_pts_30_yr                    |double |      Fees and percentage points of the loan amount      |
|fixed_rate_15_yr                      |double |     Fixed rate 15 year mortgage (percent)       |
|fees_and_pts_15_yr                    |double |      Fees and percentage points of the loan amount      |
|adjustable_rate_5_1_hybrid            |double |      5-1 Hybrid Adjustable rate mortgage (5 year fixed, then annual adjustable rate)     |
|fees_and_pts_5_1_hybrid               |double |     Fees and percentage points of the loan amount       |
|adjustable_margin_5_1_hybrid          |double |      A fixed amount added to the underlying index to establish the fully indexed rate for an ARM.|
|spread_30_yr_fixed_and_5_1_adjustable |double |      Difference in rate between 30 year fixed and 5-1 adjustable      |


### Recessions

* You should probably just go to the [Wikipedia article](https://en.wikipedia.org/wiki/List_of_recessions_in_the_United_States) - but this is a small list of recessions in the USA.

|variable                             |class     |description |
|:-----------|:---|:-----------|
|name                                 |character |    Recession Name        |
|period_range                         |character |        Time period range of the recession    |
|duration_months                      |character |      How long the recession lasted      |
|time_since_previous_recession_months |character |    Time since previous recession in months        |
|peak_unemploy_ment                   |character |  Peak unemployment (percent)          |
|gdp_decline_peak_to_trough           |character |     GDP decline from peak to trough       |
|characteristics                      |character |  Paragraph description of the recession          |

## Some useful state-level built-in R datasets

[source](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/state.html)

R currently contains the following "state" data sets. Note that all data are arranged according to alphabetical order of the state names.

state.abb:

    character vector of 2-letter abbreviations for the state names.
state.area:

    numeric vector of state areas (in square miles).
state.center:

    list with components named x and y giving the approximate geographic center of each state in negative longitude and latitude. Alaska and Hawaii are placed just off the West Coast.
state.division:

    factor giving state divisions (New England, Middle Atlantic, South Atlantic, East South Central, West South Central, East North Central, West North Central, Mountain, and Pacific).
state.name:

    character vector giving the full state names.
state.region:

    factor giving the region (Northeast, South, North Central, West) that each state belongs to.


