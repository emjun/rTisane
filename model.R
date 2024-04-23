install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('PATH')
glm(formula=Income ~ Education+Sex+Employment, family=gaussian(link='identity'), data=data)
