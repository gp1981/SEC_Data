# Author: gp1981
# Purpose: The main script that orchestrates data retrieval and analysis.
# Disclaimer: This script is intended for educational purposes only and should not be used for investment decisions. Use at your own risk.

# Import required libraries (install if necessary)
library(tidyverse)
library(httr)
library(jsonlite)

# Sourcing required files
source("Functions/data_retrieval.R")
source("Functions/data_analysis.R")
source("Functions/data_visualization.R")
source("Functions/utils.R")

# Define user headers
headers <- c('User-Agent' = 'email@address.com')

# Retrieve company data
company_List <- retrieve_Company_List(headers)

# Retrieve company information
cik <- company_List$cik[1]

company_Data <- retrieve_Company_Data(headers, cik)



