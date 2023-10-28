# Author: gp1981
# Purpose: Contains the script to retrieve company data from SEC filings.
# Disclaimer: This script is intended for educational purposes only and should not be used for investment decisions. Use at your own risk.

# Import required libraries
library(httr)
library(jsonlite)

# Function to retrieve company data
retrieveCompanyData <- function() {
  # Retrieve company tickers list
  headers <- add_headers(User_Agent = 'email@address.com')
  company_Tickers <- GET("https://www.sec.gov/files/company_tickers.json", add_headers(headers))
  company_Tickers_List <- fromJSON(content(company_Tickers, "text"))

  # Convert the JSON list to a data frame
  company_Data <- as.data.frame(t(sapply(company_Tickers_List, unlist)), stringsAsFactors = FALSE)
  colnames(company_Data) <- c("cik_str", "ticker", "title") # Define names of variables

  # Add zeros to CIK
  company_Data$cik_str <- sprintf("%010s", company_Data$cik_str)

  return(company_Data)
}
