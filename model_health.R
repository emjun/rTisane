install.packages('tidyverse')
install.packages('lme4')

library(tidyverse)
library(lme4)

data <- read.csv('health_data.csv')
glm(formula=Spending ~ Educ+Income+Sex, family=Gaussian(link='identity'), data=data)
