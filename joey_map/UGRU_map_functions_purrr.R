#####-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#####
#####   Using purrr map functions to run many models    #####
#####   University of Guelph R users group (UGRU)       #####
#####   Last updated: 28 February 2019                  #####
#####-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#####

## This tutorial was based off a presentation by Hadley Wickham. See
## https://www.youtube.com/watch?v=rz3_FDVt9eg

# initial set-up ----------------------------------------------------------

## load required packages
library(tidyverse)
library(ggthemes)
library(skimr)
library(broom)

## set plotting theme
theme_set(theme_few())


# import data -------------------------------------------------------------

## import data on US federal research and development spending through time
fed_rd <- read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-02-12/fed_r_d_spending.csv")

fed_rd

## COMMENT:
## this dataset was access through the Tidy Tuesday github page:
## https://github.com/rfordatascience/tidytuesday


# data exploration --------------------------------------------------------

## summarize data
skim(fed_rd) #well this is pretty neat

## COMMENT:
## this dataset looks at US federal research and development spending in 
## all federal departments between 1976 and 2017.

## summary of variables
## department = US agency/department
## year = fiscal year
## rd_budget = inflation-adjusted R&D budget (US dollars)
## total_outlays = total federal spending (inflation-adjusted, USD)
## discretionary outlays = total federal discretionary spending
## gdp = US gross domestic production (inflation-adjusted, USD)

## plot total government outlays (expenditures) through time
ggplot(data = fed_rd %>% filter(department == "DOD"), 
       mapping = aes(x = year, total_outlays)) + 
  geom_point() + 
  geom_smooth(method = "loess")

## COMMENT: 
## the values in the total_outlays column are replicated for each
## department. to address this, I first filtered to a single department
## (in this case, DOD), before plotting

## plot total outlays against GDP (these two should be tightly correlated)
ggplot(data = fed_rd %>% filter(department == "DOD"), 
       mapping = aes(x = gdp, total_outlays)) + 
  geom_point() + 
  geom_smooth(method = "loess")

## plot departmental RD budgets against GDP
ggplot(data = fed_rd %>% filter(rd_budget > 0), 
       mapping = aes(x = gdp / 1000000000, ## GDP in billions USD
                     y = rd_budget / 1000000, ## budget in millions USD
                     colour = year)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  facet_wrap(~ department, scales = "free") + 
  labs(x = "Gross Domestic Product (billions USD)", 
       y = "R&D Budget (millions USD)")

## COMMENT:
## I like displaying the values in billions and millions of USD, so let's
## add these columns to the dataset. let's also filter out years where
## a given department wasn't funded (because it didn't exist - 
## e.g., DHS pre-2001). Ideally, this dataset would include a column that 
## indicates whether a department is active or not in each year

fed_rd <- fed_rd %>% 
  mutate(gdp_bill = gdp / 1000000000, 
         rd_mill = rd_budget / 1000000) %>% 
  filter(rd_budget > 0) 


# nest data ---------------------------------------------------------------

## group tibble by department
by_dept <- fed_rd %>% 
  group_by(department) %>% 
  nest()

by_dept
by_dept$data[[1]] ## data for Department of Defense

## COMMENT:
## list columns can be really useful because they keep related 
## things together. anything can go in a list and a list can go in a d.f.
## this nesting has transformed the data from 'observation-per-row' to 
## 'department-per-row' format


# fit models --------------------------------------------------------------

## define a function to fit the models
rd_model <- function(df) {
  lm(rd_mill ~ gdp_bill, data = df)
}

## fit a model for each department and add the output to the dataframe
# the map works very well with the nested data.. similar to an lapply
# but both levels are a df so things are more neat and tidy

# the mutate tells it to store the outputs in a new column in the df alongside
# the input... thats very organized and powerful
by_dept <- by_dept %>% 
  mutate(mod = map(data, rd_model))
#this is great because you can then take things a step further and instead of calling
# summary() on a bunch of lms to get the outputs, we can instead just get an ouput df
# with all the info stored in a single place.  


#this is how it would be applied to just a single list member
rd_model(by_dept$data[[1]])

lm_out_test = lm(rd_mill ~ gdp_bill, data = by_dept$data[[1]])

summary(lm_out_test)

coefficients(lm_out_test)['gdp_bill']

## the map() function will transform (or map) a list of dataframes into a 
## list of corresponding models.


# convert model objects to tidy data using broom --------------------------

## COMMENT:
## the broom packages provides a number of tools to convert messy model
## output into tidy data
## glance() = model summaries (one row/value per model; e.g., R^2, AIC)
## tidy() = model estimates 
## (one row per model parameter; e.g., parameters estimates, SEs)
## augment() = observation-level outputs 
## (one row for each row in the original dataset; e.g., residuals, es)


#cam trying to get the coefficients out 
broom::glance(by_dept$mod[[1]])

coefficients(by_dept$mod[[1]])['gdp_bill']

#this function pulls the coeffecient out from the dataframe
#takes a dataframe and the desired coefficient as an input
get_coef = function(df, coef){
  return(coefficients(df)[coef])
}

#this is how it would be singularly applied
get_coef(by_dept$mod[[1]], 'gdp_bill')

#this is how it would be applied to all the nested dfs at once
mapply(get_coef, by_dept$mod , 'gdp_bill')

#this is how it works in map2... same thing but the arguments are in a different order
map2(by_dept$mod , 'gdp_bill', get_coef)

#can we get the coefficients into the df
by_dept <- by_dept %>% 
  mutate(tidy = map(mod, broom::tidy),
         glance = map(mod, broom::glance), 
         augment = map(mod, broom::augment), 
         rsq = glance %>% map_dbl("adj.r.squared"), 
         pval = glance %>% map_dbl("p.value"),
         gdp_coef = as.vector(mapply(get_coef, mod , 'gdp_bill')),
         next_coef = as.vector(unlist(map2(mod ,'gdp_bill', get_coef))))

by_dept
## plot the r-squared values for each country
ggplot(data = by_dept %>% 
         mutate(p_bin = as.factor(if_else(pval > 0.05, "ns", "sig"))), 
       mapping = aes(x = reorder(department, rsq),
                     y = rsq, colour = p_bin)) + 
  geom_point(size = 3) + 
  scale_colour_manual(values = c("red", "blue"), name = NULL, 
                      labels = c("non-significant", "significant")) + 
  labs(x = "US federal department", 
       y = bquote('Model ' * R[adj]^2), 
       title = "Does GDP predict R&D spending?") + 
  theme(legend.position = c(0.2, 0.75), 
        axis.text.x = element_text(angle = 45, hjust = 1), 
        plot.title = element_text(hjust = 0.5))


# unnest the data ---------------------------------------------------------

unnest(by_dept, data) ## back to where we started

## COMMENT:
## since rsq was extracted from the model for each department, and there 
## is only one r-squared per model, it will be constant for each dept.

## view model summaries by department
unnest(by_dept, glance, .drop = TRUE)

## view model estimates by department
unnest(by_dept, tidy, .drop = TRUE)

## unnest the augmented data
## one row per observation per model (fitted values, residuals, etc)
unnest(by_dept, augment)


# explore model outputs ---------------------------------------------------

## plot model residuals
by_dept %>% 
  unnest(augment) %>% 
  ggplot(data = ., 
         mapping = aes(x = gdp_bill, y = .resid)) + 
  geom_line(mapping = aes(colour = department)) + 
  geom_smooth(method = "loess", se = FALSE, colour = "black") + 
  geom_hline(yintercept = 0, colour = "red") + 
  labs(x = "Gross Domestic Product (billions USD)", 
       y = "residuals")

## plot fitted values (for R&D spending) against GDP
by_dept %>% 
  unnest(augment) %>% 
  ggplot(data = ., mapping = aes(x = gdp_bill)) + 
  geom_point(mapping = aes(y = rd_mill, colour = department)) + 
  geom_line(mapping = aes(y = .fitted, colour = department)) + 
  geom_smooth(mapping = aes(y = rd_mill), 
              method = "loess", colour = "black") + 
  geom_hline(yintercept = 0, colour = "red") + 
  labs(x = "Gross Domestic Product (billions USD)", 
       y = "R&D spending (fitted)")


# final thoughts ----------------------------------------------------------

## what can you imagine using purrr::map() functions for?

## map() is just the start! purrr also has several other powerful
## functions, including:
?map()
?map2()
?pmap()
?map_df()

## -- ## -- ## -- ## -- ## END OF SCRIPT ## -- ## -- ## -- ## -- ##