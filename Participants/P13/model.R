install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('/Users/cse-loaner/Git/rTisane/Participants/income_final.csv')
model<-glm(formula=Income ~ Employment+Age*Race*Sex+Education*Employment+Education, family=gaussian(link='identity'), data=data)
summary(model)
