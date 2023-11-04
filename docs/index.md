SEC Data analysis
================

## Purpose of this project {#Purpose of this project}

### SEC Data analysis with R

The primary purpose of this project is to retrieve company data from SEC
filings and analyze it for educational and research purposes. Please
note that the scripts provided here are not intended for making
investment decisions, and their use is at your own risk.

## DISCLAIMER

*This financial data retrieval code is provided for informational
purposes only, and we make no warranties regarding the accuracy,
completeness, or timeliness of the data. It should not be considered
financial advice, and users should consult with qualified professionals
for personalized guidance. Data is obtained from various sources,
including the SEC, and we do not guarantee its accuracy or availability.
Users are responsible for assessing and managing risks associated with
the financial data. We are not liable for any damages arising from the
use of this data or code. Redistribution, resale, or republication of
the data without authorization is prohibited. This disclaimer is subject
to change, and users are responsible for staying updated. It is not
legal advice, and compliance with applicable laws and regulations is the
user’s responsibility.*

## Setup libraries

Import required libraries (install if necessary):

``` r
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.3     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.4     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(httr)
library(jsonlite)
```

    ## 
    ## Attaching package: 'jsonlite'
    ## 
    ## The following object is masked from 'package:purrr':
    ## 
    ##     flatten

Sourcing required files in your main_script.R (here commented)

``` r
source("../code/Functions/data_retrieval.R")
source("../code/Functions/data_analysis.R")
source("../code/Functions/data_visualization.R")
source("../code/Functions/utils.R")
```

## Retrieve data from SEC

We start by defining the user agent for accessing the SEC API. Next, we
retrieve the full list of companies, and then select the first company
in the list `$cik[1]` to retrieve its data. The cik for this example is
Apple Inc. “AAPL”

``` r
# Define user headers
headers <- c('User-Agent' = 'email@address.com')

# Retrieve company list
company_List <- retrieve_Company_List(headers)
```

    ## No encoding supplied: defaulting to UTF-8.

``` r
# Retrieve company information
company_List[1,] %>% print()
```

    ##      cik_str ticker      title
    ## 0 0000320193   AAPL Apple Inc.

``` r
cik <- company_List$cik_str[1]
company_Data <- retrieve_Company_Data(headers, cik)
```

    ## No encoding supplied: defaulting to UTF-8.
    ## No encoding supplied: defaulting to UTF-8.
    ## No encoding supplied: defaulting to UTF-8.

## Explore data retrieved from SEC

We split the data in `company_Data` into separate Lists:
`company_Metadata`, `company_Facts`, `company_Concept`

``` r
company_Metadata <- company_Data$company_Metadata
company_Facts <- company_Data$company_Facts
company_Concept <- company_Data$company_Concept
```

Let’s create now a first dataframe:

``` r
# Create a DataFrame with relevant data
company_df <- data.frame(
  CIK = cik,
  Name = company_Metadata$name,
  FiscalYearEnd = company_Metadata$fiscalYearEnd,
  AssetsLabel = company_Facts$facts$`us-gaap`$Assets$label,
  AssetsDescription = company_Facts$facts$`us-gaap`$Assets$description
  # Add more relevant fields here
)
print(company_df)
```

    ##          CIK       Name FiscalYearEnd AssetsLabel
    ## 1 0000320193 Apple Inc.          0930      Assets
    ##                                                                                                                                                                                                          AssetsDescription
    ## 1 Sum of the carrying amounts as of the balance sheet date of all assets that are recognized. Assets are probable future economic benefits obtained or controlled by an entity as a result of past transactions or events.

### Structure of the SEC data: XBRL

The structure the data retrieved from SEC Api is a structured financial
data in compliance with SEC reporting standards. It’s organized this way
to ensure consistency and comparability of financial data across
different companies and filings.

In practice, if you want to analyze specific financial metrics like
“Assets,” you would navigate through the structure to access the
corresponding “fact” under the relevant “concept.” This allows you to
extract and work with financial data for analysis or reporting.In the
structure you provided:

- **`cik`**: This is the Central Index Key (CIK) of the company. It’s a
  unique identifier assigned to each company that files reports with the
  U.S. Securities and Exchange Commission (SEC).

- **`entityName`**: This is the name of the company, in this case,
  “Apple Inc.”

- **`facts`**: This is the main container for financial data. Within
  “facts,” you have two main sections:

  - **`dei`**: This section contains financial data related to Document
    and Entity Information (DEI). DEI data includes basic company
    information, such as the entity’s common stock shares outstanding
    and the entity’s public float.

  - **`us-gaap`**: This section contains financial data that follows the
    U.S. Generally Accepted Accounting Principles (GAAP). It includes a
    wide range of financial concepts, which are organized as a list of
    financial items.

Within these sections, you’ll find the actual financial data represented
as a list of items. Each item has specific attributes that describe the
financial information:

- **Concept**: A “concept” represents a specific financial measure or
  item. For example, “Assets” or “AccountsPayable” are concepts. Each
  concept has an associated label and a data type.

- **Facts**: Under each concept, you have “facts.” These are the actual
  numerical values or data associated with the concept. For example,
  “Assets” will have a fact that represents the total assets value for
  the company. Facts typically have attributes like “value,” “unitRef,”
  and “contextRef.”

- **Attributes**: Facts may have additional attributes that provide
  context for the data, such as the reporting period, currency unit, or
  the precision of the data.

To analyze and work with this data effectively, you would typically need
to select specific concepts and facts that are relevant to your
analysis, and you may also need to transform or pivot the data into a
more tabular format for further processing and visualization.

### Company Metadata

General information about the company is included in the Metadata. This
includes its name and fiscal year end date and other information.

``` r
company_Metadata <- company_Data$company_Metadata
company_Metadata$name        # Company name
```

    ## [1] "Apple Inc."

``` r
company_Metadata$fiscalYearEnd  # Fiscal year end date
```

    ## [1] "0930"

``` r
names(company_Metadata) %>% print() # Full list of Metadata
```

    ##  [1] "cik"                               "entityType"                       
    ##  [3] "sic"                               "sicDescription"                   
    ##  [5] "insiderTransactionForOwnerExists"  "insiderTransactionForIssuerExists"
    ##  [7] "name"                              "tickers"                          
    ##  [9] "exchanges"                         "ein"                              
    ## [11] "description"                       "website"                          
    ## [13] "investorWebsite"                   "category"                         
    ## [15] "fiscalYearEnd"                     "stateOfIncorporation"             
    ## [17] "stateOfIncorporationDescription"   "addresses"                        
    ## [19] "phone"                             "flags"                            
    ## [21] "formerNames"                       "filings"

### Company Facts

Financial facts reported by the company are included in Facts. Access to
them is based on their label, e.g. “Assets”.

``` r
company_Facts <- company_Data$company_Facts

assets_fact <- company_Facts$facts$`us-gaap`$Assets # Example of data from us-gaap section

str(assets_fact) # it shows the structure of the List "asset_fact"
```

    ## List of 3
    ##  $ label      : chr "Assets"
    ##  $ description: chr "Sum of the carrying amounts as of the balance sheet date of all assets that are recognized. Assets are probable"| __truncated__
    ##  $ units      :List of 1
    ##   ..$ USD:'data.frame':  124 obs. of  8 variables:
    ##   .. ..$ end  : chr [1:124] "2008-09-27" "2008-09-27" "2008-09-27" "2008-09-27" ...
    ##   .. ..$ val  : num [1:124] 3.96e+10 3.96e+10 3.62e+10 3.62e+10 4.81e+10 ...
    ##   .. ..$ accn : chr [1:124] "0001193125-09-153165" "0001193125-09-214859" "0001193125-10-012091" "0001193125-10-238044" ...
    ##   .. ..$ fy   : int [1:124] 2009 2009 2009 2010 2009 2009 2010 2009 2010 2010 ...
    ##   .. ..$ fp   : chr [1:124] "Q3" "FY" "FY" "FY" ...
    ##   .. ..$ form : chr [1:124] "10-Q" "10-K" "10-K/A" "10-K" ...
    ##   .. ..$ filed: chr [1:124] "2009-07-22" "2009-10-27" "2010-01-25" "2010-10-27" ...
    ##   .. ..$ frame: chr [1:124] NA NA NA "CY2008Q3I" ...

This list contains information related to “Assets” and appears to be
organized as follows:

1.  **label**: The description of the item, which in this case is
    “Assets.” This label provides a brief identifier for the financial
    concept.

2.  **description**: A more detailed description of the item, explaining
    what “Assets” represent. In this case, it mentions that it is the
    sum of carrying amounts as of the balance sheet date of all
    recognized assets. It also describes assets as probable future
    economic benefits obtained or controlled by an entity due to past
    transactions or events.

3.  **units**: This section contains information about the units in
    which the data is presented. In this case, it appears to be in USD
    (U.S. Dollars).

4.  **USD**: Within the “units” section, there is a nested data frame
    with several columns. Each row in this data frame corresponds to a
    specific piece of information, potentially for different fiscal
    quarters.

    - **end**: The date corresponding to the end of the fiscal quarter
      for which the data is reported. For example, “2008-09-27”
      represents the end of the quarter.

    - **val**: The value of “Assets” for that specific fiscal quarter.
      It’s given in numeric format, e.g., “3.96e+10,” which is a
      scientific notation for a large number.

    - **accn**: A unique identifier associated with this financial data,
      often in the format of “Accession Number.” This number is used to
      reference specific financial reports.

    - **fy**: The fiscal year associated with the data. For instance,
      “2009” is the fiscal year for some of the reported values.

    - **fp**: Indicates the fiscal period (e.g., “Q3” for the third
      quarter and “FY” for the full fiscal year).

    - **form**: The form type associated with the financial data report
      (e.g., “10-Q” for a quarterly report and “10-K” for an annual
      report).

    - **filed**: The date when the financial report was filed, often in
      the format “YYYY-MM-DD.”

    - **frame**: An additional identifier, potentially associated with
      the fiscal quarter or financial reporting period. For example,
      “CY2008Q3I” could be related to the calendar year 2008, the third
      quarter, and might have an “I” indicating it’s the initial or
      amended report.

This structure contains detailed information about “Assets” reported by
a company over multiple fiscal quarters, including dates, values, report
identifiers, and more. You can use this data to analyze the company’s
financial performance over time or create visualizations to understand
how its assets have evolved.

``` r
assets_label <- assets_fact$label          # Label of the fact ("Assets")
assets_description <- assets_fact$description  # Description of the fact
assets_unit <- assets_fact$units

print("Label:")
```

    ## [1] "Label:"

``` r
print(assets_fact$label)
```

    ## [1] "Assets"

``` r
print("Description:")
```

    ## [1] "Description:"

``` r
print(assets_fact$description)
```

    ## [1] "Sum of the carrying amounts as of the balance sheet date of all assets that are recognized. Assets are probable future economic benefits obtained or controlled by an entity as a result of past transactions or events."

``` r
print("Units (USD):")
```

    ## [1] "Units (USD):"

``` r
print(assets_fact$units$USD)
```

    ##            end         val                 accn   fy fp   form      filed
    ## 1   2008-09-27 3.95720e+10 0001193125-09-153165 2009 Q3   10-Q 2009-07-22
    ## 2   2008-09-27 3.95720e+10 0001193125-09-214859 2009 FY   10-K 2009-10-27
    ## 3   2008-09-27 3.61710e+10 0001193125-10-012091 2009 FY 10-K/A 2010-01-25
    ## 4   2008-09-27 3.61710e+10 0001193125-10-238044 2010 FY   10-K 2010-10-27
    ## 5   2009-06-27 4.81400e+10 0001193125-09-153165 2009 Q3   10-Q 2009-07-22
    ## 6   2009-09-26 5.38510e+10 0001193125-09-214859 2009 FY   10-K 2009-10-27
    ## 7   2009-09-26 4.75010e+10 0001193125-10-012085 2010 Q1   10-Q 2010-01-25
    ## 8   2009-09-26 4.75010e+10 0001193125-10-012091 2009 FY 10-K/A 2010-01-25
    ## 9   2009-09-26 4.75010e+10 0001193125-10-088957 2010 Q2   10-Q 2010-04-21
    ## 10  2009-09-26 4.75010e+10 0001193125-10-162840 2010 Q3   10-Q 2010-07-21
    ## 11  2009-09-26 4.75010e+10 0001193125-10-238044 2010 FY   10-K 2010-10-27
    ## 12  2009-09-26 4.75010e+10 0001193125-11-282113 2011 FY   10-K 2011-10-26
    ## 13  2009-12-26 5.39260e+10 0001193125-10-012085 2010 Q1   10-Q 2010-01-25
    ## 14  2010-03-27 5.70570e+10 0001193125-10-088957 2010 Q2   10-Q 2010-04-21
    ## 15  2010-06-26 6.47250e+10 0001193125-10-162840 2010 Q3   10-Q 2010-07-21
    ## 16  2010-09-25 7.51830e+10 0001193125-10-238044 2010 FY   10-K 2010-10-27
    ## 17  2010-09-25 7.51830e+10 0001193125-11-010144 2011 Q1   10-Q 2011-01-19
    ## 18  2010-09-25 7.51830e+10 0001193125-11-104388 2011 Q2   10-Q 2011-04-21
    ## 19  2010-09-25 7.51830e+10 0001193125-11-192493 2011 Q3   10-Q 2011-07-20
    ## 20  2010-09-25 7.51830e+10 0001193125-11-282113 2011 FY   10-K 2011-10-26
    ## 21  2010-12-25 8.67420e+10 0001193125-11-010144 2011 Q1   10-Q 2011-01-19
    ## 22  2011-03-26 9.49040e+10 0001193125-11-104388 2011 Q2   10-Q 2011-04-21
    ## 23  2011-06-25 1.06758e+11 0001193125-11-192493 2011 Q3   10-Q 2011-07-20
    ## 24  2011-09-24 1.16371e+11 0001193125-11-282113 2011 FY   10-K 2011-10-26
    ## 25  2011-09-24 1.16371e+11 0001193125-12-023398 2012 Q1   10-Q 2012-01-25
    ## 26  2011-09-24 1.16371e+11 0001193125-12-182321 2012 Q2   10-Q 2012-04-25
    ## 27  2011-09-24 1.16371e+11 0001193125-12-314552 2012 Q3   10-Q 2012-07-25
    ## 28  2011-09-24 1.16371e+11 0001193125-12-444068 2012 FY   10-K 2012-10-31
    ## 29  2011-09-24 1.16371e+11 0001193125-13-170623 2012 FY    8-K 2013-04-24
    ## 30  2011-12-31 1.38681e+11 0001193125-12-023398 2012 Q1   10-Q 2012-01-25
    ## 31  2012-03-31 1.50934e+11 0001193125-12-182321 2012 Q2   10-Q 2012-04-25
    ## 32  2012-06-30 1.62896e+11 0001193125-12-314552 2012 Q3   10-Q 2012-07-25
    ## 33  2012-09-29 1.76064e+11 0001193125-12-444068 2012 FY   10-K 2012-10-31
    ## 34  2012-09-29 1.76064e+11 0001193125-13-022339 2013 Q1   10-Q 2013-01-24
    ## 35  2012-09-29 1.76064e+11 0001193125-13-168288 2013 Q2   10-Q 2013-04-24
    ## 36  2012-09-29 1.76064e+11 0001193125-13-170623 2012 FY    8-K 2013-04-24
    ## 37  2012-09-29 1.76064e+11 0001193125-13-300670 2013 Q3   10-Q 2013-07-24
    ## 38  2012-09-29 1.76064e+11 0001193125-13-416534 2013 FY   10-K 2013-10-30
    ## 39  2012-12-29 1.96088e+11 0001193125-13-022339 2013 Q1   10-Q 2013-01-24
    ## 40  2013-03-30 1.94743e+11 0001193125-13-168288 2013 Q2   10-Q 2013-04-24
    ## 41  2013-06-29 1.99856e+11 0001193125-13-300670 2013 Q3   10-Q 2013-07-24
    ## 42  2013-09-28 2.07000e+11 0001193125-13-416534 2013 FY   10-K 2013-10-30
    ## 43  2013-09-28 2.07000e+11 0001193125-14-024487 2014 Q1   10-Q 2014-01-28
    ## 44  2013-09-28 2.07000e+11 0001193125-14-157311 2014 Q2   10-Q 2014-04-24
    ## 45  2013-09-28 2.07000e+11 0001193125-14-277160 2014 Q3   10-Q 2014-07-23
    ## 46  2013-09-28 2.07000e+11 0001193125-14-383437 2014 FY   10-K 2014-10-27
    ## 47  2013-09-28 2.07000e+11 0001193125-15-023732 2014 FY    8-K 2015-01-28
    ## 48  2013-12-28 2.25184e+11 0001193125-14-024487 2014 Q1   10-Q 2014-01-28
    ## 49  2014-03-29 2.05989e+11 0001193125-14-157311 2014 Q2   10-Q 2014-04-24
    ## 50  2014-06-28 2.22520e+11 0001193125-14-277160 2014 Q3   10-Q 2014-07-23
    ## 51  2014-09-27 2.31839e+11 0001193125-14-383437 2014 FY   10-K 2014-10-27
    ## 52  2014-09-27 2.31839e+11 0001193125-15-023697 2015 Q1   10-Q 2015-01-28
    ## 53  2014-09-27 2.31839e+11 0001193125-15-023732 2014 FY    8-K 2015-01-28
    ## 54  2014-09-27 2.31839e+11 0001193125-15-153166 2015 Q2   10-Q 2015-04-28
    ## 55  2014-09-27 2.31839e+11 0001193125-15-259935 2015 Q3   10-Q 2015-07-22
    ## 56  2014-09-27 2.31839e+11 0001193125-15-356351 2015 FY   10-K 2015-10-28
    ## 57  2014-12-27 2.61894e+11 0001193125-15-023697 2015 Q1   10-Q 2015-01-28
    ## 58  2015-03-28 2.61194e+11 0001193125-15-153166 2015 Q2   10-Q 2015-04-28
    ## 59  2015-06-27 2.73151e+11 0001193125-15-259935 2015 Q3   10-Q 2015-07-22
    ## 60  2015-09-26 2.90479e+11 0001193125-15-356351 2015 FY   10-K 2015-10-28
    ## 61  2015-09-26 2.90479e+11 0001193125-16-439878 2016 Q1   10-Q 2016-01-27
    ## 62  2015-09-26 2.90479e+11 0001193125-16-559625 2016 Q2   10-Q 2016-04-27
    ## 63  2015-09-26 2.90479e+11 0001628280-16-017809 2016 Q3   10-Q 2016-07-27
    ## 64  2015-09-26 2.90345e+11 0001628280-16-020309 2016 FY   10-K 2016-10-26
    ## 65  2015-12-26 2.93284e+11 0001193125-16-439878 2016 Q1   10-Q 2016-01-27
    ## 66  2016-03-26 3.05277e+11 0001193125-16-559625 2016 Q2   10-Q 2016-04-27
    ## 67  2016-06-25 3.05602e+11 0001628280-16-017809 2016 Q3   10-Q 2016-07-27
    ## 68  2016-09-24 3.21686e+11 0001628280-16-020309 2016 FY   10-K 2016-10-26
    ## 69  2016-09-24 3.21686e+11 0001628280-17-000717 2017 Q1   10-Q 2017-02-01
    ## 70  2016-09-24 3.21686e+11 0001628280-17-004790 2017 Q2   10-Q 2017-05-03
    ## 71  2016-09-24 3.21686e+11 0000320193-17-000009 2017 Q3   10-Q 2017-08-02
    ## 72  2016-09-24 3.21686e+11 0000320193-17-000070 2017 FY   10-K 2017-11-03
    ## 73  2016-12-31 3.31141e+11 0001628280-17-000717 2017 Q1   10-Q 2017-02-01
    ## 74  2017-04-01 3.34532e+11 0001628280-17-004790 2017 Q2   10-Q 2017-05-03
    ## 75  2017-07-01 3.45173e+11 0000320193-17-000009 2017 Q3   10-Q 2017-08-02
    ## 76  2017-09-30 3.75319e+11 0000320193-17-000070 2017 FY   10-K 2017-11-03
    ## 77  2017-09-30 3.75319e+11 0000320193-18-000007 2018 Q1   10-Q 2018-02-02
    ## 78  2017-09-30 3.75319e+11 0000320193-18-000070 2018 Q2   10-Q 2018-05-02
    ## 79  2017-09-30 3.75319e+11 0000320193-18-000100 2018 Q3   10-Q 2018-08-01
    ## 80  2017-09-30 3.75319e+11 0000320193-18-000145 2018 FY   10-K 2018-11-05
    ## 81  2017-12-30 4.06794e+11 0000320193-18-000007 2018 Q1   10-Q 2018-02-02
    ## 82  2018-03-31 3.67502e+11 0000320193-18-000070 2018 Q2   10-Q 2018-05-02
    ## 83  2018-06-30 3.49197e+11 0000320193-18-000100 2018 Q3   10-Q 2018-08-01
    ## 84  2018-09-29 3.65725e+11 0000320193-18-000145 2018 FY   10-K 2018-11-05
    ## 85  2018-09-29 3.65725e+11 0000320193-19-000010 2019 Q1   10-Q 2019-01-30
    ## 86  2018-09-29 3.65725e+11 0000320193-19-000066 2019 Q2   10-Q 2019-05-01
    ## 87  2018-09-29 3.65725e+11 0000320193-19-000076 2019 Q3   10-Q 2019-07-31
    ## 88  2018-09-29 3.65725e+11 0000320193-19-000119 2019 FY   10-K 2019-10-31
    ## 89  2018-12-29 3.73719e+11 0000320193-19-000010 2019 Q1   10-Q 2019-01-30
    ## 90  2019-03-30 3.41998e+11 0000320193-19-000066 2019 Q2   10-Q 2019-05-01
    ## 91  2019-06-29 3.22239e+11 0000320193-19-000076 2019 Q3   10-Q 2019-07-31
    ## 92  2019-09-28 3.38516e+11 0000320193-19-000119 2019 FY   10-K 2019-10-31
    ## 93  2019-09-28 3.38516e+11 0000320193-20-000010 2020 Q1   10-Q 2020-01-29
    ## 94  2019-09-28 3.38516e+11 0000320193-20-000052 2020 Q2   10-Q 2020-05-01
    ## 95  2019-09-28 3.38516e+11 0000320193-20-000062 2020 Q3   10-Q 2020-07-31
    ## 96  2019-09-28 3.38516e+11 0000320193-20-000096 2020 FY   10-K 2020-10-30
    ## 97  2019-12-28 3.40618e+11 0000320193-20-000010 2020 Q1   10-Q 2020-01-29
    ## 98  2020-03-28 3.20400e+11 0000320193-20-000052 2020 Q2   10-Q 2020-05-01
    ## 99  2020-06-27 3.17344e+11 0000320193-20-000062 2020 Q3   10-Q 2020-07-31
    ## 100 2020-09-26 3.23888e+11 0000320193-20-000096 2020 FY   10-K 2020-10-30
    ## 101 2020-09-26 3.23888e+11 0000320193-21-000010 2021 Q1   10-Q 2021-01-28
    ## 102 2020-09-26 3.23888e+11 0000320193-21-000056 2021 Q2   10-Q 2021-04-29
    ## 103 2020-09-26 3.23888e+11 0000320193-21-000065 2021 Q3   10-Q 2021-07-28
    ## 104 2020-09-26 3.23888e+11 0000320193-21-000105 2021 FY   10-K 2021-10-29
    ## 105 2020-12-26 3.54054e+11 0000320193-21-000010 2021 Q1   10-Q 2021-01-28
    ## 106 2021-03-27 3.37158e+11 0000320193-21-000056 2021 Q2   10-Q 2021-04-29
    ## 107 2021-06-26 3.29840e+11 0000320193-21-000065 2021 Q3   10-Q 2021-07-28
    ## 108 2021-09-25 3.51002e+11 0000320193-21-000105 2021 FY   10-K 2021-10-29
    ## 109 2021-09-25 3.51002e+11 0000320193-22-000007 2022 Q1   10-Q 2022-01-28
    ## 110 2021-09-25 3.51002e+11 0000320193-22-000059 2022 Q2   10-Q 2022-04-29
    ## 111 2021-09-25 3.51002e+11 0000320193-22-000070 2022 Q3   10-Q 2022-07-29
    ## 112 2021-09-25 3.51002e+11 0000320193-22-000108 2022 FY   10-K 2022-10-28
    ## 113 2021-12-25 3.81191e+11 0000320193-22-000007 2022 Q1   10-Q 2022-01-28
    ## 114 2022-03-26 3.50662e+11 0000320193-22-000059 2022 Q2   10-Q 2022-04-29
    ## 115 2022-06-25 3.36309e+11 0000320193-22-000070 2022 Q3   10-Q 2022-07-29
    ## 116 2022-09-24 3.52755e+11 0000320193-22-000108 2022 FY   10-K 2022-10-28
    ## 117 2022-09-24 3.52755e+11 0000320193-23-000006 2023 Q1   10-Q 2023-02-03
    ## 118 2022-09-24 3.52755e+11 0000320193-23-000064 2023 Q2   10-Q 2023-05-05
    ## 119 2022-09-24 3.52755e+11 0000320193-23-000077 2023 Q3   10-Q 2023-08-04
    ## 120 2022-09-24 3.52755e+11 0000320193-23-000106 2023 FY   10-K 2023-11-03
    ## 121 2022-12-31 3.46747e+11 0000320193-23-000006 2023 Q1   10-Q 2023-02-03
    ## 122 2023-04-01 3.32160e+11 0000320193-23-000064 2023 Q2   10-Q 2023-05-05
    ## 123 2023-07-01 3.35038e+11 0000320193-23-000077 2023 Q3   10-Q 2023-08-04
    ## 124 2023-09-30 3.52583e+11 0000320193-23-000106 2023 FY   10-K 2023-11-03
    ##         frame
    ## 1        <NA>
    ## 2        <NA>
    ## 3        <NA>
    ## 4   CY2008Q3I
    ## 5   CY2009Q2I
    ## 6        <NA>
    ## 7        <NA>
    ## 8        <NA>
    ## 9        <NA>
    ## 10       <NA>
    ## 11       <NA>
    ## 12  CY2009Q3I
    ## 13  CY2009Q4I
    ## 14  CY2010Q1I
    ## 15  CY2010Q2I
    ## 16       <NA>
    ## 17       <NA>
    ## 18       <NA>
    ## 19       <NA>
    ## 20  CY2010Q3I
    ## 21  CY2010Q4I
    ## 22  CY2011Q1I
    ## 23  CY2011Q2I
    ## 24       <NA>
    ## 25       <NA>
    ## 26       <NA>
    ## 27       <NA>
    ## 28       <NA>
    ## 29  CY2011Q3I
    ## 30  CY2011Q4I
    ## 31  CY2012Q1I
    ## 32  CY2012Q2I
    ## 33       <NA>
    ## 34       <NA>
    ## 35       <NA>
    ## 36       <NA>
    ## 37       <NA>
    ## 38  CY2012Q3I
    ## 39  CY2012Q4I
    ## 40  CY2013Q1I
    ## 41  CY2013Q2I
    ## 42       <NA>
    ## 43       <NA>
    ## 44       <NA>
    ## 45       <NA>
    ## 46       <NA>
    ## 47  CY2013Q3I
    ## 48  CY2013Q4I
    ## 49  CY2014Q1I
    ## 50  CY2014Q2I
    ## 51       <NA>
    ## 52       <NA>
    ## 53       <NA>
    ## 54       <NA>
    ## 55       <NA>
    ## 56  CY2014Q3I
    ## 57  CY2014Q4I
    ## 58  CY2015Q1I
    ## 59  CY2015Q2I
    ## 60       <NA>
    ## 61       <NA>
    ## 62       <NA>
    ## 63       <NA>
    ## 64  CY2015Q3I
    ## 65  CY2015Q4I
    ## 66  CY2016Q1I
    ## 67  CY2016Q2I
    ## 68       <NA>
    ## 69       <NA>
    ## 70       <NA>
    ## 71       <NA>
    ## 72  CY2016Q3I
    ## 73  CY2016Q4I
    ## 74  CY2017Q1I
    ## 75  CY2017Q2I
    ## 76       <NA>
    ## 77       <NA>
    ## 78       <NA>
    ## 79       <NA>
    ## 80  CY2017Q3I
    ## 81  CY2017Q4I
    ## 82  CY2018Q1I
    ## 83  CY2018Q2I
    ## 84       <NA>
    ## 85       <NA>
    ## 86       <NA>
    ## 87       <NA>
    ## 88  CY2018Q3I
    ## 89  CY2018Q4I
    ## 90  CY2019Q1I
    ## 91  CY2019Q2I
    ## 92       <NA>
    ## 93       <NA>
    ## 94       <NA>
    ## 95       <NA>
    ## 96  CY2019Q3I
    ## 97  CY2019Q4I
    ## 98  CY2020Q1I
    ## 99  CY2020Q2I
    ## 100      <NA>
    ## 101      <NA>
    ## 102      <NA>
    ## 103      <NA>
    ## 104 CY2020Q3I
    ## 105 CY2020Q4I
    ## 106 CY2021Q1I
    ## 107 CY2021Q2I
    ## 108      <NA>
    ## 109      <NA>
    ## 110      <NA>
    ## 111      <NA>
    ## 112 CY2021Q3I
    ## 113 CY2021Q4I
    ## 114 CY2022Q1I
    ## 115 CY2022Q2I
    ## 116      <NA>
    ## 117      <NA>
    ## 118      <NA>
    ## 119      <NA>
    ## 120 CY2022Q3I
    ## 121 CY2022Q4I
    ## 122 CY2023Q1I
    ## 123 CY2023Q2I
    ## 124 CY2023Q3I

The following are the list of the Facts in the us-gaap section:

``` r
# Get the names of elements within us-gaap and indicate if the list is truncated
names_us_gaap <- names(company_Facts$facts$`us-gaap`)
truncated <- length(names_us_gaap) > 20
if (truncated) {
  names_us_gaap <- head(names_us_gaap, 20)
  cat("The list is truncated.\n")
}
```

    ## The list is truncated.

``` r
# Print the names and the number of elements
print(names_us_gaap)
```

    ##  [1] "AccountsPayable"                                                                                      
    ##  [2] "AccountsPayableCurrent"                                                                               
    ##  [3] "AccountsReceivableNetCurrent"                                                                         
    ##  [4] "AccruedIncomeTaxesCurrent"                                                                            
    ##  [5] "AccruedIncomeTaxesNoncurrent"                                                                         
    ##  [6] "AccruedLiabilities"                                                                                   
    ##  [7] "AccruedLiabilitiesCurrent"                                                                            
    ##  [8] "AccruedMarketingCostsCurrent"                                                                         
    ##  [9] "AccumulatedDepreciationDepletionAndAmortizationPropertyPlantAndEquipment"                             
    ## [10] "AccumulatedOtherComprehensiveIncomeLossAvailableForSaleSecuritiesAdjustmentNetOfTax"                  
    ## [11] "AccumulatedOtherComprehensiveIncomeLossCumulativeChangesInNetGainLossFromCashFlowHedgesEffectNetOfTax"
    ## [12] "AccumulatedOtherComprehensiveIncomeLossForeignCurrencyTranslationAdjustmentNetOfTax"                  
    ## [13] "AccumulatedOtherComprehensiveIncomeLossNetOfTax"                                                      
    ## [14] "AdjustmentsToAdditionalPaidInCapitalSharebasedCompensationRequisiteServicePeriodRecognitionValue"     
    ## [15] "AdjustmentsToAdditionalPaidInCapitalTaxEffectFromShareBasedCompensation"                              
    ## [16] "AdvertisingExpense"                                                                                   
    ## [17] "AllocatedShareBasedCompensationExpense"                                                               
    ## [18] "AllowanceForDoubtfulAccountsReceivableCurrent"                                                        
    ## [19] "AmortizationOfIntangibleAssets"                                                                       
    ## [20] "AntidilutiveSecuritiesExcludedFromComputationOfEarningsPerShareAmount"

``` r
cat("The number of Facts in us-gaap section is:", length(company_Facts$facts$`us-gaap`))
```

    ## The number of Facts in us-gaap section is: 498

The following are the list of the Facts in the deo section:

``` r
# Get the names of elements within dei
names_dei <- names(company_Facts$facts$dei)

# Print the names and the number of elements
print(names_dei)
```

    ## [1] "EntityCommonStockSharesOutstanding" "EntityPublicFloat"

``` r
cat("The number of Facts in dei section is:", length(names_dei))
```

    ## The number of Facts in dei section is: 2

``` r
# Print an example element
cat("Entity Common Stock Shares Outstanding is:")
```

    ## Entity Common Stock Shares Outstanding is:

``` r
print(company_Facts$facts$dei$EntityCommonStockSharesOutstanding$units$shares)
```

    ##           end         val                 accn   fy fp   form      filed
    ## 1  2009-06-27   895816758 0001193125-09-153165 2009 Q3   10-Q 2009-07-22
    ## 2  2009-10-16   900678473 0001193125-09-214859 2009 FY   10-K 2009-10-27
    ## 3  2009-10-16   900678473 0001193125-10-012091 2009 FY 10-K/A 2010-01-25
    ## 4  2010-01-15   906794589 0001193125-10-012085 2010 Q1   10-Q 2010-01-25
    ## 5  2010-04-09   909938383 0001193125-10-088957 2010 Q2   10-Q 2010-04-21
    ## 6  2010-07-09   913562880 0001193125-10-162840 2010 Q3   10-Q 2010-07-21
    ## 7  2010-10-15   917307099 0001193125-10-238044 2010 FY   10-K 2010-10-27
    ## 8  2011-01-07   921278012 0001193125-11-010144 2011 Q1   10-Q 2011-01-19
    ## 9  2011-04-08   924754561 0001193125-11-104388 2011 Q2   10-Q 2011-04-21
    ## 10 2011-07-08   927090886 0001193125-11-192493 2011 Q3   10-Q 2011-07-20
    ## 11 2011-10-14   929409000 0001193125-11-282113 2011 FY   10-K 2011-10-26
    ## 12 2012-01-13   932370000 0001193125-12-023398 2012 Q1   10-Q 2012-01-25
    ## 13 2012-04-13   935062000 0001193125-12-182321 2012 Q2   10-Q 2012-04-25
    ## 14 2012-07-13   937406000 0001193125-12-314552 2012 Q3   10-Q 2012-07-25
    ## 15 2012-10-19   940692000 0001193125-12-444068 2012 FY   10-K 2012-10-31
    ## 16 2013-01-11   939058000 0001193125-13-022339 2013 Q1   10-Q 2013-01-24
    ## 17 2013-04-12   938649000 0001193125-13-168288 2013 Q2   10-Q 2013-04-24
    ## 18 2013-07-12   908497000 0001193125-13-300670 2013 Q3   10-Q 2013-07-24
    ## 19 2013-10-18   899738000 0001193125-13-416534 2013 FY   10-K 2013-10-30
    ## 20 2014-01-10   891989000 0001193125-14-024487 2014 Q1   10-Q 2014-01-28
    ## 21 2014-04-11   861381000 0001193125-14-157311 2014 Q2   10-Q 2014-04-24
    ## 22 2014-07-11  5987867000 0001193125-14-277160 2014 Q3   10-Q 2014-07-23
    ## 23 2014-10-10  5864840000 0001193125-14-383437 2014 FY   10-K 2014-10-27
    ## 24 2015-01-09  5824748000 0001193125-15-023697 2015 Q1   10-Q 2015-01-28
    ## 25 2015-04-10  5761030000 0001193125-15-153166 2015 Q2   10-Q 2015-04-28
    ## 26 2015-07-10  5702722000 0001193125-15-259935 2015 Q3   10-Q 2015-07-22
    ## 27 2015-10-09  5575331000 0001193125-15-356351 2015 FY   10-K 2015-10-28
    ## 28 2016-01-08  5544583000 0001193125-16-439878 2016 Q1   10-Q 2016-01-27
    ## 29 2016-04-08  5477425000 0001193125-16-559625 2016 Q2   10-Q 2016-04-27
    ## 30 2016-07-15  5388443000 0001628280-16-017809 2016 Q3   10-Q 2016-07-27
    ## 31 2016-10-14  5332313000 0001628280-16-020309 2016 FY   10-K 2016-10-26
    ## 32 2017-01-20  5246540000 0001628280-17-000717 2017 Q1   10-Q 2017-02-01
    ## 33 2017-04-21  5213840000 0001628280-17-004790 2017 Q2   10-Q 2017-05-03
    ## 34 2017-07-21  5165228000 0000320193-17-000009 2017 Q3   10-Q 2017-08-02
    ## 35 2017-10-20  5134312000 0000320193-17-000070 2017 FY   10-K 2017-11-03
    ## 36 2018-01-19  5074013000 0000320193-18-000007 2018 Q1   10-Q 2018-02-02
    ## 37 2018-04-20  4915138000 0000320193-18-000070 2018 Q2   10-Q 2018-05-02
    ## 38 2018-07-20  4829926000 0000320193-18-000100 2018 Q3   10-Q 2018-08-01
    ## 39 2018-10-26  4745398000 0000320193-18-000145 2018 FY   10-K 2018-11-05
    ## 40 2019-01-18  4715280000 0000320193-19-000010 2019 Q1   10-Q 2019-01-30
    ## 41 2019-04-22  4601075000 0000320193-19-000066 2019 Q2   10-Q 2019-05-01
    ## 42 2019-07-19  4519180000 0000320193-19-000076 2019 Q3   10-Q 2019-07-31
    ## 43 2019-10-18  4443265000 0000320193-19-000119 2019 FY   10-K 2019-10-31
    ## 44 2020-01-17  4375480000 0000320193-20-000010 2020 Q1   10-Q 2020-01-29
    ## 45 2020-04-17  4334335000 0000320193-20-000052 2020 Q2   10-Q 2020-05-01
    ## 46 2020-07-17  4275634000 0000320193-20-000062 2020 Q3   10-Q 2020-07-31
    ## 47 2020-10-16 17001802000 0000320193-20-000096 2020 FY   10-K 2020-10-30
    ## 48 2021-01-15 16788096000 0000320193-21-000010 2021 Q1   10-Q 2021-01-28
    ## 49 2021-04-16 16687631000 0000320193-21-000056 2021 Q2   10-Q 2021-04-29
    ## 50 2021-07-16 16530166000 0000320193-21-000065 2021 Q3   10-Q 2021-07-28
    ## 51 2021-10-15 16406397000 0000320193-21-000105 2021 FY   10-K 2021-10-29
    ## 52 2022-01-14 16319441000 0000320193-22-000007 2022 Q1   10-Q 2022-01-28
    ## 53 2022-04-15 16185181000 0000320193-22-000059 2022 Q2   10-Q 2022-04-29
    ## 54 2022-07-15 16070752000 0000320193-22-000070 2022 Q3   10-Q 2022-07-29
    ## 55 2022-10-14 15908118000 0000320193-22-000108 2022 FY   10-K 2022-10-28
    ## 56 2023-01-20 15821946000 0000320193-23-000006 2023 Q1   10-Q 2023-02-03
    ## 57 2023-04-21 15728702000 0000320193-23-000064 2023 Q2   10-Q 2023-05-05
    ## 58 2023-07-21 15634232000 0000320193-23-000077 2023 Q3   10-Q 2023-08-04
    ## 59 2023-10-20 15552752000 0000320193-23-000106 2023 FY   10-K 2023-11-03
    ##        frame
    ## 1  CY2009Q2I
    ## 2       <NA>
    ## 3  CY2009Q3I
    ## 4  CY2009Q4I
    ## 5  CY2010Q1I
    ## 6  CY2010Q2I
    ## 7  CY2010Q3I
    ## 8  CY2010Q4I
    ## 9  CY2011Q1I
    ## 10 CY2011Q2I
    ## 11 CY2011Q3I
    ## 12 CY2011Q4I
    ## 13 CY2012Q1I
    ## 14 CY2012Q2I
    ## 15 CY2012Q3I
    ## 16 CY2012Q4I
    ## 17 CY2013Q1I
    ## 18 CY2013Q2I
    ## 19 CY2013Q3I
    ## 20 CY2013Q4I
    ## 21 CY2014Q1I
    ## 22 CY2014Q2I
    ## 23 CY2014Q3I
    ## 24 CY2014Q4I
    ## 25 CY2015Q1I
    ## 26 CY2015Q2I
    ## 27 CY2015Q3I
    ## 28 CY2015Q4I
    ## 29 CY2016Q1I
    ## 30 CY2016Q2I
    ## 31 CY2016Q3I
    ## 32 CY2016Q4I
    ## 33 CY2017Q1I
    ## 34 CY2017Q2I
    ## 35 CY2017Q3I
    ## 36 CY2017Q4I
    ## 37 CY2018Q1I
    ## 38 CY2018Q2I
    ## 39 CY2018Q3I
    ## 40 CY2018Q4I
    ## 41 CY2019Q1I
    ## 42 CY2019Q2I
    ## 43 CY2019Q3I
    ## 44 CY2019Q4I
    ## 45 CY2020Q1I
    ## 46 CY2020Q2I
    ## 47 CY2020Q3I
    ## 48 CY2020Q4I
    ## 49 CY2021Q1I
    ## 50 CY2021Q2I
    ## 51 CY2021Q3I
    ## 52 CY2021Q4I
    ## 53 CY2022Q1I
    ## 54 CY2022Q2I
    ## 55 CY2022Q3I
    ## 56 CY2022Q4I
    ## 57 CY2023Q1I
    ## 58 CY2023Q2I
    ## 59 CY2023Q3I

``` r
# Print an example element
cat("Entity Public Float (USD) is:")
```

    ## Entity Public Float (USD) is:

``` r
print(company_Facts$facts$dei$EntityPublicFloat$units$USD)
```

    ##           end          val                 accn   fy fp   form      filed
    ## 1  2009-03-28 9.459300e+10 0001193125-09-153165 2009 Q3   10-Q 2009-07-22
    ## 2  2009-03-28 9.459300e+10 0001193125-09-214859 2009 FY   10-K 2009-10-27
    ## 3  2009-03-28 9.459300e+10 0001193125-10-012091 2009 FY 10-K/A 2010-01-25
    ## 4  2010-03-27 2.085650e+11 0001193125-10-238044 2010 FY   10-K 2010-10-27
    ## 5  2011-03-25 3.229210e+11 0001193125-11-282113 2011 FY   10-K 2011-10-26
    ## 6  2012-03-30 5.603560e+11 0001193125-12-444068 2012 FY   10-K 2012-10-31
    ## 7  2013-03-29 4.160050e+11 0001193125-13-416534 2013 FY   10-K 2013-10-30
    ## 8  2014-03-28 4.625220e+11 0001193125-14-383437 2014 FY   10-K 2014-10-27
    ## 9  2015-03-27 7.099230e+11 0001193125-15-356351 2015 FY   10-K 2015-10-28
    ## 10 2016-03-25 5.788070e+11 0001628280-16-020309 2016 FY   10-K 2016-10-26
    ## 11 2017-03-31 7.475090e+11 0000320193-17-000070 2017 FY   10-K 2017-11-03
    ## 12 2018-03-30 8.288800e+11 0000320193-18-000145 2018 FY   10-K 2018-11-05
    ## 13 2019-03-29 8.746980e+11 0000320193-19-000119 2019 FY   10-K 2019-10-31
    ## 14 2020-03-27 1.070633e+12 0000320193-20-000096 2020 FY   10-K 2020-10-30
    ## 15 2021-03-26 2.021360e+12 0000320193-21-000105 2021 FY   10-K 2021-10-29
    ## 16 2022-03-25 2.830067e+12 0000320193-22-000108 2022 FY   10-K 2022-10-28
    ## 17 2023-03-31 2.591165e+12 0000320193-23-000106 2023 FY   10-K 2023-11-03
    ##        frame
    ## 1       <NA>
    ## 2       <NA>
    ## 3  CY2009Q1I
    ## 4  CY2010Q1I
    ## 5  CY2011Q1I
    ## 6  CY2012Q1I
    ## 7  CY2013Q1I
    ## 8  CY2014Q1I
    ## 9  CY2015Q1I
    ## 10 CY2016Q1I
    ## 11 CY2017Q1I
    ## 12 CY2018Q1I
    ## 13 CY2019Q1I
    ## 14 CY2020Q1I
    ## 15 CY2021Q1I
    ## 16 CY2022Q1I
    ## 17 CY2023Q1I
