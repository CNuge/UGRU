##############################
## Effortless report generation: example code
##
## Karl Cottenie
##
## 2019-03-25
##
##############################

library(tidyverse)
library(broom)
library(viridis)
# + scale_color/fill_viridis(discrete = T/F)
theme_set(theme_light())

# Startup ends here

## _ Comment codes ------
# Coding explanations (#, often after the code, but not exclusively)
# Code organization (## XXXXX -----)
# Justification for a section of code ## XXX
# Dead end analyses because it did not work, or not pursuing this line of inquiry (but leave it in as a trace of it, to potentially solve this issue, or avoid making the same mistake in the future # (>_<) 
# Solutions/results/interpretations (#==> XXX)
# Reference to manuscript pieces, figures, results, tables, ... # (*_*)
# TODO items #TODO
# names for data frames (dfName), for lists (lsName), for vectors (vcName) (Thanks Jacqueline May)

## _ Example code for figures -----

# inspect the data set
mpg

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + # first plot w/ inline comments
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

## _ Example code for analysis ------

glmfit <- glm(am ~ wt, mtcars, family="binomial")
tidy(glmfit)

augment(glmfit)

glance(glmfit)

## _ Example code for comments -----

# Done: example code
# Done: three rendering examples
#TODO convert rendering code into snippet for easy execution
