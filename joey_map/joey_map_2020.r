#####-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#####
#####   Working with map functions and their outputs    #####
#####   University of Guelph R users group (UGRU)       #####
#####   Last updated: 27 February 2020                  #####
#####-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#####

# initial set-up ----------------------------------------------------------

## set working directory
getwd()

## load required packages
library(tidyverse)
library(lubridate)
library(ggthemes)

library(skimr)
library(broom)

## set plotting theme
theme_set(theme_few())


# import data -------------------------------------------------------------

## COMMENT:
## we will be using the same dataset as Karl's tutorial, which is 
## comes from a camera trap study on the Serengeti
## see metadata at:
## https://datadryad.org/stash/dataset/doi:10.5061/dryad.5pt92

serengeti <- read_csv("../karl_repeating_combos/consensus_data.csv")

serengeti
skimr::skim(serengeti)

## OBSERVATIONS:
## there are 48 species documented in the dataset, recorded at 225 sites
## dataset includes 4 years, spanning 2010-2013


# data manipulations ------------------------------------------------------

## COMMENT:
## the dataset is currently in long format, with each row representing
## a single capture event. let's create a dataset that tells us the 
## number of individuals of each species that were observed at a 
## given location in a given year
## (this is the similar to Karl's procedure, but we won't spread the data)

## Zorilla = "striped polecat", "African skunk" =/= "gorilla"

serengeti_2 <- serengeti %>% 
  mutate(Year = year(DateTime)) %>% ## extract year from DateTime
  select(Year, SiteID, Species, Count) %>% 
  mutate(Count = as.numeric(Count)) %>% 
  group_by(Year, SiteID, Species) %>% 
  summarise(Total = sum(Count)) %>% 
  ungroup()

## convert NAs to zeroes
serengeti_2[is.na(serengeti_2)] <- 0

## we can further summarize this by finding the number of individuals
## counted at all sites in a given year (this will likely result in 
## double-counting of individuals, but doesn't really matter for our
## purposes)

serengeti_3 <- serengeti_2 %>% 
  group_by(Species, Year) %>% 
  summarise(Abundance = sum(Total)) %>% 
  ungroup()


# data exploration --------------------------------------------------------

## plot the number of individuals of each species through time
ggplot(data = serengeti_3,
       mapping = aes(x = Year, y = Abundance)) + 
  geom_point() + 
  geom_line() + 
  facet_wrap(~ Species, scales = "free_y")


# nest data ---------------------------------------------------------------

## group tibble by department
by_species <- serengeti_3 %>% 
  group_by(Species) %>% 
  nest()

by_species
by_species$data[[1]]

## COMMENT:
## the nest function produces a new 'data column' that contains the 
## subset of data that pertains to each species
## this is a powerful, if unconvential way, of working with larger 
## datasets that are comprised of observations on many different groups
## 
## list columns can be really useful because they keep related 
## things together. anything can go in a list and a list can go in a d.f.
## this nesting has transformed the data from 'observation-per-row' to 
## 'species-per-row' format


# model species abundance through time ------------------------------------

## define a function to fit a simple linear model
abund_mod <- function(df) {
  lm(Abundance ~ Year + I(Year^2), data = df)
}

## fit the model for each species separately, adding the output to our 
## nested dataframe [this is where the map function comes in handy!!]
by_species <- by_species %>% 
  mutate(mod = map(data, abund_mod))

by_species
by_species$mod[[1]]
summary(by_species$mod[[1]])


# convert model objects to tidy data using broom --------------------------

## COMMENT:
## the broom packages provides a number of tools to convert messy model
## output into tidy data
## glance() = model summaries (one row/value per model; e.g., R^2, AIC)
## tidy() = model estimates 
## (one row per model parameter; e.g., parameters estimates, SEs)
## augment() = observation-level outputs 
## (one row for each row in the original dataset; e.g., residuals, es)

by_species <- by_species %>% 
  mutate(int_slope = map(mod, broom::tidy),
         summ_stats = map(mod, broom::glance), 
         fits = map(mod, broom::augment), 
         rsq = summ_stats %>% map_dbl("adj.r.squared"), 
         pval = summ_stats %>% map_dbl("p.value"))

by_species$int_slope[[1]]
by_species$summ_stats[[1]]
by_species$fits[[1]]

## extracting the fitted values can also be done with map2()
head(map2(by_species$mod, by_species$data, predict))[1]


# unnest the data ---------------------------------------------------------

unnest(by_species, data) ## back to where we started

## COMMENT:
## since rsq was extracted from the model for each species, and there 
## is only one r-squared per model, it will be repeated for each species

## view model summaries by species
unnest(by_species, summ_stats, .drop = TRUE)

## view model predictions by species
(serengeti_3_fits <- unnest(by_species, fits, .drop = TRUE))


# explore model outputs ---------------------------------------------------

## plot model the fitted lines with the raw data
ggplot(data = serengeti_3_fits) + 
  geom_line(mapping = aes(x = Year, y = .fitted)) + 
  geom_point(mapping = aes(x = Year, y = Abundance)) + 
  facet_wrap(~ Species, scales = "free_y")


# mapping over multiple inputs --------------------------------------------

# ## COMMENT:
# ## A number of the species abundances appear to show a similar pattern, 
# ## wherein abundance follows a quadratic relationship, increasing in 2011
# ## and 2012, before dropping again in 2013
# ## this is likely a result of shared environmental conditions (e.g., maybe
# ## 2010 and 2013 were drought years), but could also result from pairwise
# ## species interactions or community-level effects
# 
# ## define a model to look how the abundance of one species affects 
# ## the abundance of another species through time
# abund_mod2 <- function(df, prey, lions) {
#   lm(Species1 ~ Year + I(Year^2) + Species2, data = df)
# }

## define a list of prey species
prey <- serengeti_3 %>% 
  filter(Species %in% c("zebra", "wildebeest", "impala", 
              "gazelleGrants", "gazelleThomsons", "dikDik")) %>% 
  group_by(Year) %>% 
  nest()

## define a list of predator species
predators <- serengeti_3 %>% 
  filter(Species %in% c("lionMale", "lionFemale", "jackal", 
               "leopard", "hyenaStriped", "cheetah")) %>% 
  group_by(Year) %>% 
  nest()

## join the predator and prey datasets together  
pred_prey <- left_join(predators, prey, by = "Year") %>% 
  rename(Predators = data.x, 
         Prey = data.y)

## calculate the relative abundances of matched predators and prey
## in each year (this doesn't really do what I want, but you get the point)
t1 <- pred_prey %>% 
  mutate(Prey = map2(Predators, 
                     Prey, 
                     ~mutate(.y, 
                             predator = .x$Species, 
                             relative_abundance = 
                               .x$Abundance/.y$Abundance)))
t1$Prey[[1]]

## calculate the correlation between predator and prey abundances in each
## year of the study
t2 <- pred_prey %>% 
  mutate(Prey = map2(Predators, 
                     Prey, 
                     ~mutate(.y, 
                             corr = cor(.x$Abundance, .y$Abundance))))
t2$Prey[[1]]

# test out pmap() ---------------------------------------------------------

pmap(list(by_species$data), nrow) # %>% unlist()

## COMMENT:
## honestly, I don't know how to use pmap(). All of the examples I could
## think of could be done a variety of other (more transparent?) ways, 
## which might rely on combining group_by() and summarise()

serengeti_3 %>% 
  group_by(Species) %>% 
  summarise(min_abundance = min(Abundance), 
            min_year = Year[which.min(Abundance)])

## DO YOU HAVE ANY EXAMPLES OF USING pmap() IN YOUR OWN WORK??

# pmap lets you lapply a function that takes the colnmaes as args
# note the ... below lets us throw away the columns we don't need, 
# and we can avoid having to use these in the function's argument
# list

new_name = function(Species, Petal.Width, Petal.Length, ...){
  return(paste(Species, Petal.Width, Petal.Length, sep=";"))
}

# here pmap takes all the columns of iris, and use them as the arguments
# to be passed to the new_name func. Note the ... in the new_name args list
# tosses the two sepal length columns and then just uses the relevant columns
# without the ... we get an error saying that 
iris$outname = pmap(iris,  new_name)


iris$outname = lapply(1:nrow(iris), function(i){
  new_name(iris$Species[[i]], iris$Petal.Width[[i]], iris$Petal.Length[[i]])
  })


# we can also use various data sources, by making a labelled list, where the labels are
# the function args, the data can be passed to the function through pmap. shorter
# data structures are recycled (use 10 over and over below)


numerators = c(1,2,3,4,5,6,7,8)
denoms = c(2,4,6,8,10,12,14,16)
mul = c(10)

div = function(n, d, m){
  return ((n / d)*m)
}

pmap(list(n = numerators, d = denoms, m = mul), div)




## -- ## -- ## -- ## -- ## END OF SCRIPT ## -- ## -- ## -- ## -- ##