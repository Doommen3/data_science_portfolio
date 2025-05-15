library(tidyverse)
library(readr)



data <- read_csv("/Users/devin/NIU_CrimeLogReader/df_output.csv")

data$Disposition <- gsub("^(am |pm )", "", data$Disposition)


process_disposition <- function(disposition) {
  # Define the keywords to look for
  keywords <- c("Closed By", "Open", "Unfounded", "Suspended", "Referred to", "Referred To")
  
  # Check if the disposition ends with any of the keywords
  keyword_match <- stringr::str_extract(disposition, paste0("(", paste(keywords, collapse = "|"), ")$"))
  
  # If a keyword is found at the end, split the disposition
  if (!is.na(keyword_match)) {
    new_disposition <- stringr::str_remove(disposition, paste0("\\s?", keyword_match, "$"))
    return(c(new_disposition, keyword_match))
  }
  
  # If the entire string is one of the keywords, move it to the new column
  if (disposition %in% keywords) {
    return(c(NA, disposition))
  }
  
  # Return original disposition with NA in the new column if no conditions met
  return(c(disposition, NA))
}


new_cols <- t(sapply(data$Disposition, process_disposition))
data$Current_Column <- new_cols[, 1]
data$New_Column <- new_cols[, 2]



write_csv(data, "final_crimelogcsv_1_25.csv")




fill_blanks_based_on_case <- function(data) {
  # Identify rows with blank 'Current_Column'
  blank_indices <- which(data$Current_Column == "")
  
  # Iterate over these indices
  for (i in blank_indices) {
    # Find the case number for the current blank 'Current_Column'
    case_number <- data$Case_Number[i]
    
    # Find a row with the same case number and a non-blank 'Current_Column'
    match_index <- which(data$Case_Number == case_number & data$Current_Column != "")
    
    # If a matching row is found, copy the 'Current_Column' from it
    if (length(match_index) > 0) {
      data$Current_Column[i] <- data$Current_Column[match_index[1]]
    }
  }
  
  return(data)
}


data <- fill_blanks_based_on_case(data)


# Assuming your data frame is named 'df' and the column of interest is 'Offense'
rows_with_tamper <- grep("Tamper", data$Offense, ignore.case = TRUE)

# Now you have the row indices in 'rows_with_tamper'
print(rows_with_tamper)

data$Offense[grepl("Tamper", data$Offense, ignore.case = TRUE)] <- "Tamper w/Sec, Fire, or Life Systems"




data %>%
  group_by(Offense, Current_Column) %>%
  transmute(count = n()) %>%
  arrange(desc(count)) %>%
  distinct() 

data %>%
  group_by(Offense) %>%
  transmute(count = n()) %>%
  arrange(desc(count)) %>%
  distinct() %>%
  print(n=100)



data$`Date Occurred` <- as.Date(data$`Date Occurred`, "%m/%d/%Y")

data %>%
  transmute(count = n()) %>%
  arrange(desc(count)) %>%
  distinct()


location_sort <- location_sort[1:10,]

write_csv(location_sort, "location_1_25.csv")

