install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('/Users/cse-loaner/Git/rTisane/Participants/income.csv')
glm(formula=Income ~ Occupation, family=gaussian(link='identity'), data=data)

