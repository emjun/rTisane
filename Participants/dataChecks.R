library(tidyverse)

# Read in data
complete_df <- read_csv("/Users/emjun/Git/tisaner/Participants/income.csv") # local copy of income data at https://drive.google.com/file/d/1VZ7FUfcy8r-GUFtVdijPRwbdkcOL4WLr/view

# Get subset of data
subset <- select(complete_df, "Participant", "Age", "Race", "Highest Edu Completed", "Employment", "Sex", "Annual Income")

# Rename columns 
subset <- rename(subset, "ID"="Participant", "Age"="Age", "Race"="Race", "Education"="Highest Edu Completed", "Employment"="Employment", "Sex"="Sex", "Income"="Annual Income")

# Write out subset
income_subset <- write_csv(subset, "income_subset.csv")

# Print out number of unique values
print(paste("Unique Race:", length(unique(subset$Race))))
print(unique(subset$Race))
print("====")

print(paste("Unique Education:", length(unique(subset$Education))))
print(unique(subset$Education))
print("====")

print(paste("Unique Employment:", length(unique(subset$Employment))))
print(unique(subset$Employment))
print("====")

print(paste("Unique Sex:", length(unique(subset$Sex))))
print(unique(subset$Sex))
print("====")

print(paste("Unique Income:", length(unique(subset$Income))))
print(unique(subset$Income))
print("====")