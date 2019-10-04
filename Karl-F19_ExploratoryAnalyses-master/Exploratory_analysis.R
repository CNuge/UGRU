##############################
## Exploratory data analysis
##
## Matt Brachmann (PhDMattyB)
##
## 2019-09-20
##
##############################

setwd('~/PhD/R users group/')

library(tidyverse)
library(wesanderson)
library(patchwork)
library(devtools)
library(rsed)
library(data.table)

theme_set(theme_bw())

# Other packages to load


## _ Matt's contributions ------

#install.packages("janitor", dependencies = TRUE)
library(janitor)
clean_names(iris, case = "screaming_snake")

#install.packages("skimr", dependencies = TRUE)
library(skimr)

data("iris")

summary(iris)
summary(iris$Sepal.Length)
summary(iris$Species)

as_tibble(iris)

skim(iris) ## waaaay more information than summary

skim(iris) %>% 
  skimr::kable()  #a bit of nicer format
  # skimr::pander() will get a warning message on windows

iris %>%
  dplyr::group_by(Species) %>% 
  skim()

skim(iris) %>% 
  dplyr::filter(stat == 'mean') ## skimr masks dplyrs filter function

## _ Karl's contribution --------

# link to "A protocol for data exploration to avoind common statistical problems"
# https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/j.2041-210X.2009.00001.x

# link to some ggplot versions of the Zuur approach
# https://archetypalecology.wordpress.com/2018/02/17/explanatory-data-exploration-in-r-after-zuur-et-al-2010/

## _ I think this was part of Joey's contributions? ----------

# libary ggally
# https://ggobi.github.io/ggally/#ggallyggduo
