install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)
# Replace 'PATH' with a path to your data
data <- read.csv('PATH')
glm(formula=Income ~ Education+Age+Education*Sex+Employment+Race+Sex, family=gaussian(link='identity'), data=data)
