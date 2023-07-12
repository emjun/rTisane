install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('/Users/cse-loaner/Git/rTisane/Participants/income_final.csv')
glm(formula=Education ~ Age, family=gaussian(link='identity'), data=data)
glm(formula=Education ~ Age + Sex, family=gaussian(link='identity'), data=data)

