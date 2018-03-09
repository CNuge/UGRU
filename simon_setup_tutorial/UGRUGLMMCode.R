
## Getting started ----

# set working directory
setwd("~/Documents/R/Chapter One Analysis/Data/Newest Data/")

# Packages
library(tidyverse) # allows to use dplyr and tidyr
library(lme4) # required for running glm's and glmm's
library(blmeco) # for checking for overdispersion

# Importing my new dataset
mice <- read.csv("../Newest Data/FinalGLMMUGRUData.csv")

# Checking the type of data in each column
sapply(mice, class)

# Convert the wrongly classed variables
mice$Moved <- factor(mice$Moved)
mice$First.Line <- factor(mice$First.Line)
mice$Second.Line <- factor(mice$Second.Line)
mice$Year <- factor(mice$Year)
mice$PI <- factor(mice$PI)


#Checking to make sure this code did what I desired
sapply(mice, class)
# It did what I wanted  so moving on now

## Examining the data ----

# Indicating the number of rows in the dataset
dim(mice)
# 534 mice in the dataset, and 18 variables 

head(mice)

### Beginning analysis ----
# plot variables graphically to look at relationships
#plot(mice)
# dataset is way too big to do this today

### Running Models ----
# note: I already standardized my variables using the scale() function, as not doing this foten causes the models to fail to converge
### first model: Whether local relative density changes based on annual regional raw density
# starting with simple intercept model
glm.intercept <- glm(Adj.Diff.z ~ 1, data = mice, na.action = na.omit)
summary(glm.intercept)

# Model of the effect that annual regional density has on relative local density
reg.glm <- glm(Adj.Diff.z ~ Adj.Avg.Abund.z, data = mice, na.action = na.omit)
summary(reg.glm)

## check that the assumptions of a glm are met
# assessing model diagnostics by plotting the model ----
plot(reg.glm)
# seems pretty normal, and as though there are not outliers. But what if this wasn't the case?

# Check if the residuals of the model are normally distributed
#histogram of residuals
hist(resid(reg.glm))
# Relatively uniform here 
# Appear ok, relatively normally distributed, if they weren't could do a transformation (log etc) on the variables
# or maybe use a different type of model (GLIM)

# check for homoscedasticity by plotting residuals against fitted values
plot(resid(reg.glm) ~ fitted(reg.glm))
# definitely some structure in these errors, could fix with a good transformation but not to worry this isn't a real analysis

#summary of model
summary(reg.glm)

# But what about those things called random effects? ----
# how do we decide when to use them? 
# Simplest Model as GLiM
reg.glm <- glm(Adj.Diff.z ~ Adj.Avg.Abund.z, data = mice, family = gaussian, na.action = na.omit)

# Is there structure in the residuals of this model based on some grouping variables that we should consider?
## plot residuals of the model
# against year
plot(resid(reg.glm) ~ mice$Year)

# looks like there is could be  structure within years

# creating a generalized mixed effect model to account for structure in the residuals
# first including Year as a random effect
reg.glmer.year <- glmer(Adj.Diff.z ~ Adj.Avg.Abund.z + (1|Year), data = mice, family = gaussian, na.action = na.omit)

# checking the fit of the model against the original model
anova(reg.glmer.year, reg.glm)
# the more complex model is a significantly better fit to the data

# plot the residuals of this new glmer against line number
plot(resid(reg.glmer.year) ~ mice$First.Line)
# appears to be some structure so add as a random effect

# Creating second GLMER including two random effects
reg.glmer.year.first.line <- glmer(Adj.Diff.z ~ Adj.Avg.Abund.z + (1|Year) + (1|First.Line), data = mice, family = gaussian, na.action = na.omit)


# checking fit of the model against the model only containing year as a random effect
anova(reg.glmer.year.first.line, reg.glmer.year)
# again, a significantly better fit, will include line number as a random effect

# plotting the residuals against Sex
plot(resid(reg.glmer.year.first.line) ~ mice$Sex)
# perhaps some structure, will create model and check if it makes for a better fit

# GLMER containing all three random effects, however PI only has 3 levels so included as a fixed effect
reg.glmer.year.first.line.Sex <- glmer(Moved ~ Adj.Line.Abund.z + Sex + (1|Year) + (1|First.Line), data = mice, family = binomial, na.action = na.omit)

# checking if the fit of the model is improved via the inclusion of PI
anova(reg.glmer.year.first.line.Sex, reg.glmer.year.first.line)
# model is not significantly improved, so will not include PI as predictor in future models

# renaming the glmer for ease of typing
reg.glmer <- reg.glmer.year.first.line

### checking diagnostics of the model ----
# first checking for overdispersion using function from the blmeco package
dispersion_glmer((reg.glmer))
# dispersion parameter is well below one meaning the model is underdispersed, meaning if anything we will be conservative

# summary of the model for one last look
summary(reg.glmer)

### My real analysis to show how to check the devianec explained by the model ----
# simple intercept model (now it becomes clear why we did this initially), but note that I am now using a new response variable and the model is now a binomial model to accomodate this
binomial.glm.intercept <- glm(Moved ~ 1, data = mice, family = binomial, na.action = na.omit)


# Creating second GLMER including two random effects
binomial.local.glmer.year.first.line <- glmer(Moved ~ Adj.Line.Abund.z + (1|Year) + (1|First.Line), data = mice, family = binomial, na.action = na.omit)


# renaming the glmer for ease of typing
binomial.local.glmer <- binomial.local.glmer.year.first.line

# how much of the deviance does the model explain ----
# use summaries to get the deviance of both the simple intercept model and the  model we have come up with
summary(binomial.glm.intercept)
summary(binomial.local.glmer)
#  1-(Deviance of this model/deviance of null model) ie the one with just the intercept
1-(183.3/207.87)
#11.8% of the variation

## the eventual Best model to illustrate how much more of the deviance a better model can explain: interaction model between local abundance and average abundance but incorporating the conditions at the beginning of the breeding season----
Two.int.model <-glmer(Moved ~ Adj.Avg.Abund.z + Adj.Diff + Sex + Adj.Diff:Sex + Adj.Avg.Abund.z:Adj.Diff + log(Closest.Dist*1000) + (1|Year) + (1|First.Line), data = mice, family = binomial, na.action = na.omit)
summary(Two.int.model)
# best model from looking at the AIC scores so assess the random effects

1-(158.9/207.87)
# 23.6 % of the deviance explained
#Interactions and plotting next week

