#### Very Brief, and Basic Introduction to Linear Mixed Effects Models in lme4 ####
####_ Simon Denomme-Brown ####
####__ March 8th, 2019 ####

#### Getting Started ----

#Importing necessary package
#Packages
library(tidyverse) # in order to use read_csv
library(lme4) # most used package in all of ecology and evolution!!!! Whoopeeeeeeee!

#Import the dataframe
Dispersed = read_csv("./MovingMice1.csv")
keep_cols = colnames(Dispersed)
keep_cols = keep_cols[2:length(keep_cols)]
##dataset of mice that dispersed between traplines
Dispersed = Dispersed[keep_cols]
head(Dispersed)

#### When to Use a Basic Linear model ----
#Working in Base R rather than lme4 here
Dispersed

#using mice that dispersed want to see if the continuous variable of Density affects the distance travelled by deer mice
plot(Distance.Travelled~Density, data = Dispersed)

Dens.Dist.Model = lm(Distance.Travelled ~ Density, data = Dispersed)

summary(Dens.Dist.Model)
## Distance travelled by deer mice increased with density


#### When to use a multiple linear regression ----
# Density affects distance travelled, but what about year? 
plot(Distance.Travelled~Year, data = Dispersed)

Dens.Dist.Year.Model = lm(Distance.Travelled ~ Density + Year, data = Dispersed)

summary(Dens.Dist.Year.Model)


#### When to use a Linear Mixed effects Model ----
# Does distance travelled vary with year?

### BUT: do we care about the effect of year really?
## Should we treat it as a Random Effect?

#random effects must be categorical
# Make sure variables are in the right form
Dispersed$Year = factor(Dispersed$Year)

# Model to see if density affects how far an animal disperses
# while accounting for temporal variation in the system

How.Far.ConsideringYear = lmer(Distance.Travelled~Density + (1|Year), data = Dispersed)
summary(How.Far.ConsideringYear)

# NO P VALUES!!!!!!!!!!!! 
# there is a philosophical debate as to whether you can calculate them here

# load in lmerTest
library(lmerTest)
How.Far.ConsideringYear = lmer(Distance.Travelled~Density + (1|Year), data = Dispersed)
summary(How.Far.ConsideringYear)


