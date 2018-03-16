# Load packages - ggplot is contained within tidyverse
library(tidyverse)
library(magrittr) # for back-piping %<>%

# Dataset to play with = juvenile red squirrels
juveniles <- read.csv('juveniles.csv')

# redefine a few variables
juveniles %<>% mutate(sex = as.factor(sex),
                      grid = as.factor(grid),
                      survived_200d = as.numeric(survived_200d),
                      mother_age = as.integer(mother_age))

# What if you want to see the effect of a single predictor in your model? -----
# Eg: modelling survival by several predictors (binomial model)
# remove negative growth rate observations as above
juveniles %<>% subset(growth > 0)

model <- glm(survived_200d ~ bdate + growth*sex + grid + density, data = juveniles, family = binomial)
summary(model)

# Creating interaction in ggplot2 ----
# remove NA's in the rows you are dealing with
juveniles %<>% subset(!is.na(density))
juveniles %<>% subset(!is.na(survived_200d))

### Sex Interaction Plot ----
juveniles$prediction <- predict(model, type="response")

pred.plot <- ggplot(juveniles, aes(x=growth, y=survived_200d, colour=sex))
pred.plot +
  geom_point() +
  geom_jitter(height=0.01)+ 
  theme_classic() +
  xlab("Growth") + 
  ylab ("Survived to 200 Days")+
  theme(axis.line.x = element_line(color="black", size = 1),
        axis.line.y = element_line(color="black", size = 1)) +
  stat_smooth(inherit.aes=F, aes(x= growth, y = prediction, group=sex, color = sex),
              method = "glm", se=F, method.args = list(family = "binomial")) + 
  theme(legend.justification = c(1,2), legend.position = c(1,1)) +
  labs(color = "sex")

### using visreg ----
library(visreg)
visreg(model)
# Shows effect of change in x on y while holding other terms constant
# default = median for numeric & most common for factors, but can specify
# so not the exact same as partial residuals plot, but similar idea

# if we want to only examine one of the predictors:
visreg(model, "grid")
# output tells you what values for other factors are, can define manually
visreg(model, "grid", cond = list(density = 0.5, sex = "F"))

# or show interactions: default is faceted, but can plot together with overlay = TRUE
visreg(model, "growth", by = "sex", strip.names = c("Females", "Males"))
visreg(model, "growth", by = "sex", overlay = TRUE)

# Useful trick: can format visreg plots using ggplot!
visreg(model, "bdate", partial = TRUE, rug = FALSE, scale = c("linear"))
visreg(model, "bdate")

visreg(model, "bdate", gg = TRUE) +
  xlab("Birth date") +
  ylab("Effect of birth date on survival")

# with gg = TRUE, it takes on the same default theme_light() as our other plots

visreg(model, "bdate", gg = TRUE) +
  xlab("Birth date") +
  ylab("Effect of birth date on survival") +
  geom_smooth(method = "lm", colour = "red")

visreg(model, "bdate", gg = TRUE) +
  xlab("Birth date") +
  ylab("Effect of birth date on survival") +
  geom_smooth(colour = "red")

# these points and lines are not ggplot objects
# you can create ggplot objects that appear on top of the visreg functions
# but you're not editing the visreg plot itself

# to edit points or lines, have to do it in first line with base R plot code
visreg(model, "bdate", gg = TRUE, point = list(col = "black", size = 1.8),
       line = list(col ="red")) +
  xlab("Birth date") +
  ylab("Effect of birth date on survival")

visreg(model, "bdate", gg = TRUE) +
  xlab("Birth date") +
  ylab("Effect of birth date on survival") +
  geom_point(colour = "black") +
  geom_smooth(method = "lm", colour = "red") 

# compare with ggplot of birth date alone:
ggplot(juveniles, aes(x = bdate, y = survived_200d)) +
  xlab("Birth date") +
  ylab("Surviving") + 
  geom_point(colour = "black") +
  geom_smooth(method = "lm", colour = "red")

# Particularly useful for "strange" models - eg. Cox proportional hazard models
# don't have a clear response, can't create in ggplot
# but can create a visreg figure of a coxph(), and then format as a ggplot so it looks the same as other figures
# example from my work:

unique <- read_csv("removals.csv")
library(coxme)
summary(model8 <- coxph(Surv(Latency, Intrusion) ~ Playback*Avg.ten + Julian + density, data = unique))
visreg(model8, "density", gg = TRUE, 
       line = list(col = "blue"),
       point = list(col = "black", size = 1)) +
  xlab("Local density (squirrels/ha)") +
  ylab("Relative hazard of intrusion")

