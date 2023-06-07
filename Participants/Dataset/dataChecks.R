# install.packages("ipumsr")
library(ipumsr)
library(dplyr, warn.conflicts = FALSE)
# library(tidyverse)

# Download data originally from IPUMS
# Run once
# data_url <- "https://homes.cs.washington.edu/~emjun/usa_00001.dat"
# download.file(data_url, "Dataset/usa_00001.dat")

# Read data
ddi <- read_ipums_ddi("Dataset/usa_00001.xml")
data <- read_ipums_micro(ddi, data_file="Dataset/usa_00001.dat")

# https://cran.r-project.org/web/packages/ipumsr/vignettes/ipums.html
# Use labels from codebook to relabel values for specific variables
data <- data %>%
    mutate(Age = lbl_clean(AGE))
data <- data %>%
    mutate(Race = as_factor(lbl_clean(RACE)))
data <- data %>%
    mutate(Education = as_factor(lbl_clean(EDUC)))
data <- data %>%
    mutate(Employment = as_factor(lbl_clean(CLASSWKR)))
data <- data %>%
    mutate(Sex = as_factor(lbl_clean(SEX)))
data <- data %>%
    mutate(Income = lbl_clean(INCTOT))

# Check data
stopifnot(length(unique(data$YEAR)) == 1)

# Filter data
# # Filter for only adults
# filtered_data <- filter(data, Age >= 18)
# Filter for only finishing high school
acceptable_edu <- c("Grade 12", "1 year of college", "2 years of college", "4 years of college",  "5+ years of college") # "N/A or no schooling",
filtered_data <- data %>%
    filter(Education %in% acceptable_edu)

filtered_data <- select(filtered_data, Age, Race, Education, Employment, Sex, Income)

# Add ID column to identify each row/observation
filtered_data <- tibble::rowid_to_column(filtered_data, "ID")

# Output properties of data
# Age is continuous
# print(paste("Unique Age:", length(unique(filtered_data$Age))))
# print(unique(filtered_data$Age))
# print("====")
print(paste("Unique Race:", length(unique(filtered_data$Race))))
print(unique(filtered_data$Race))
print("====")

print(paste("Unique Education:", length(unique(filtered_data$Education))))
print(unique(filtered_data$Education))
print("====")

print(paste("Unique Employment:", length(unique(filtered_data$Employment))))
print(unique(filtered_data$Employment))
print("====")

print(paste("Unique Sex:", length(unique(filtered_data$Sex))))
print(unique(filtered_data$Sex))
print("====")

# Income is continuous
# Note: Income can be negative
# print(paste("Unique Income:", length(unique(filtered_data$Income))))
# print(unique(filtered_data$Income))
# print("====")

# Dataset overview
print(paste("Number of observations:", nrow(filtered_data)))
# Write out data
readr::write_csv(filtered_data, "Dataset/income_final.csv")

# Read data back in 
output_data <- readr::read_csv("Dataset/income_final.csv")
# Replace AAPI labels
output_data$Race[filtered_data$Race == "Other Asian or Pacific Islander"] <- "Asian or Pacific Islander"
output_data$Race[filtered_data$Race == "Chinese"] <- "Asian or Pacific Islander"
output_data$Race[filtered_data$Race == "Japanese"] <- "Asian or Pacific Islander"


# Rewrite data
readr::write_csv(output_data, "Dataset/income_final.csv")
