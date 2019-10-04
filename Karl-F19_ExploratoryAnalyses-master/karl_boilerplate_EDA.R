##############################
## Interactive Exploratory Data Analysis
##
## Karl Cottenie
##
## 2019-09-30
##
##############################

library(tidyverse)
library(viridis)
library(janitor)
library(skimr)
library(dataMaid)

# + scale_color/fill_viridis(discrete = T/F)
theme_set(theme_light())

# Startup ends here


df_eda = read_csv('Rainier_Weather.csv')

## Comment codes ------
# Coding explanations (#, often after the code, but not exclusively)
# Code organization (## XXXXX -----)
# Justification for a section of code ## XXX
# Dead end analyses because it did not work, or not pursuing this line of inquiry (but leave it in as a trace of it, to potentially solve this issue, or avoid making the same mistake in the future # (>_<) 
# Solutions/results/interpretations (#==> XXX)
# Reference to manuscript pieces, figures, results, tables, ... # (*_*)
# TODO items #TODO
# names for data frames (dfName), for lists (lsName), for vectors (vcName) (Thanks Jacqueline May)

## Interactive EDA - Use your brain! -----
# based on https://arxiv.org/abs/1904.02101#

# install these packages if you don't have them yet
# install.packages("dataMaid")
# install.packages("janitor")
# install.packages("skimr")
# install.packages("GGally")
# install.packages("MASS")
# library(devtools)
# devtools::install_github("vqv/ggbiplot")

# I did not load them at the start, but called all functions with ::
# if you don't need a step, you then don't prolong startup

# Cleaning up column names
# Often columns names imported from spreadsheets don't convert well in R
df_eda = df_eda %>% as.tibble %>% janitor::clean_names()

# Data Description
df_eda %>% skimr::skim()

# Data validity - missing values at the data set level
df_eda %>% na.exclude() %>% skimr::skim()

df_eda %>% .[!complete.cases(.), ]

# Univariate data validity - 0s, outliers, invalid values
# outliers = Tukey boxplot outliers
df_eda %>% dataMaid::check()

df_eda %>% dataMaid::visualize()

# Bivariate data validity
df_eda %>% GGally::ggpairs()

# Multivariate outliers = minimum covariance determinant, multivariate extension of normal distibution outliers
# https://willhipson.netlify.com/post/outliers/outliers/
# works only with quantitative data!
# df_edaQ = df_eda %>% fastDummies::dummy_cols(remove_first_dummy = T) 

dfMVoutlier <- df_eda %>% select_if(is.numeric) %>% MASS::cov.mcd(., quantile.used = nrow(.)*.75)
dfMVoutlier <- df_eda %>% select_if(is.numeric) %>%  mahalanobis(., dfMVoutlier$center, dfMVoutlier$cov)
vcMVoutlier = which(dfMVoutlier > (qchisq(p = 1 - 0.001, df = ncol(iris[,1:4]))))
# adjust 0.001 up/down to make the detection more/less sensitive

df_eda[-vcMVoutlier, ] # w/o multivariate outliers

df_eda[vcMVoutlier, ] # only multivariate outliers

df_eda %>% select_if(is.numeric) %>% prcomp(center = T, scale. = T) %>% 
  ggbiplot::ggbiplot(circle = T)

