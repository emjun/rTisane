install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('/Users/emjun/Git/rTisane/Participants/Dataset/income_final-prev.csv')
m <- glm(formula=Income ~ Employment, family=gaussian(link='identity'), data=data)
print(summary(m))

