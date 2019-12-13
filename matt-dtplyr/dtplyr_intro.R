##############################
## dtplyr
##
## Matt Brachmann (PhDMattyB)
##
## 2019-12-12
##
##############################


library(devtools)
library(data.table)
library(tidyverse)
library(dtplyr)
library(stringi)

theme_set(theme_bw())

# Other packages to load
# devtools::install_github('tidyverse/dtplyr')

## tutorial taken and modified from:
## https://towardsdatascience.com/introduction-to-dtplyr-783d89e9ae56


# Generate data -----------------------------------------------------------
n <- 10000000

data_dt <- data.table(id=stri_rand_strings(n, 
                                           3, 
                                           pattern = "[A-Z]"),
                      product=stri_rand_strings(n, 
                                                3, 
                                                pattern = "[A-Z]"),
                      date=sample(seq(as.Date('2010/12/13'), 
                                      as.Date('2019/12/13'), 
                                      by="day"), 
                                  n, 
                                  replace=TRUE),
                      amount=sample(1:10000,
                                    n,
                                    replace=TRUE),
                      price=rnorm(n, 
                                  mean = 100, 
                                  sd = 20))


head(data_dt)
nrow(data_dt)

# Manipulate the data -----------------------------------------------------

result_df = as_tibble(data_dt) %>% 
  filter(date > as.Date('2019/01/01')) %>% 
  arrange(amount) %>% 
  mutate(value = amount * price)

result_dt = data_dt[date > as.Date('2019/01/01')][order(date)][,value := amount * price]

result_dtplyr = lazy_dt(data_dt) %>% 
  filter(date > as.Date('2019/01/01')) %>% 
  arrange(amount) %>% 
  mutate(value = amount * price) %>% 
  as.tibble


# Time it! ----------------------------------------------------------------
system.time(as_tibble(data_dt) %>% 
              filter(date > as.Date('2019/01/01')) %>% 
              arrange(amount) %>% 
              mutate(value = amount * price))

system.time(data_dt[date > as.Date('2019/01/01')][order(date)][,value := amount * price])

system.time(lazy_dt(data_dt) %>% 
              filter(date > as.Date('2019/01/01')) %>% 
              arrange(amount) %>% 
              mutate(value = amount * price) %>% 
              as.tibble)

# can't access the columns etc of the 
ldt_explore = lazy_dt(data_dt)

typeof(ldt_explore)
names(ldt_explore)

ldt_explore$id[[1]]


ldt_explore = as_tibble(ldt_explore)


?arrange
?lazy_dt
?



