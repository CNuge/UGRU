##############################
## ggplot & visreg
##
## Jack Robertson
##
## 2018-10-19
##
##############################

# pdf cheatsheet= great for syntax reminders

# Load packages - ggplot is part of tidyverse
library(tidyverse)
library(magrittr) # for back-piping %<>%
library(lubridate)

setwd("C:/Users/Graham/Documents/!F17-W18 Work/R Projects/UGRU")

# Dataset to play with = juvenile red squirrels
juveniles = read_csv("juveniles.csv")

# Redefine a few variables, calculate growth rates
juveniles %<>% mutate(sex = as.factor(sex),
                      grid = as.factor(grid),
                      date.interval = as.numeric(tagDt - date1),
                      growth.rate = (tagWT - weight)/date.interval)

# Basic grammar of ggplot = define your dataframe, your x, and your y
# you can then specify how you want to show your data using different geom_ layers

# Two main types of figures with continuous y: categorical or continuous x-axes
# categorical x-axes geom: _bar, _boxplot, _dotplot, _violin
# continuous x: geom_point, _jitter, _smooth

# categorical: does growth rate vary across study grids? ----
ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_bar(stat = "summary")

# pretty bad. how else could we see these data?
# personal opinion: bar plots are generally inferior to box/scatter plots

ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_boxplot()

# some data issues: growth rate can't be negative, and there's a clear outlier in SU. Let's remove those & try again
juveniles %<>% dplyr::filter(growth.rate > 0, growth.rate < 20)

ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_boxplot()

# better than the bar plot, but still don't have a great sense of the data spread in each group

# my personal favourite: (using geom_jitter() instead of geom_point() - try it)
ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_jitter(colour = "grey50") + # we'll come back to colour in a sec
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar")

# points on top of boxplots is often a good method, but doesn't look great here
ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_boxplot() +
  geom_jitter()

## Aside: if you want to use a bar plot - how to get standard error bars? 
# My laborious way (open to alternatives!) - use summarise() to generate a summary df, and include mean & standard error of each group in the summarize function
summary <- juveniles %>%
  group_by(grid) %>%
  summarise(avg.growth = mean(growth.rate, na.rm = T), 
            n = n(),
            se = sd(growth.rate, na.rm = T)/sqrt(n))
# now use this summary dataframe and plot the bars using stat = "identity"
ggplot(summary, aes(x = grid, y = avg.growth, ymin = avg.growth + se, ymax = avg.growth - se)) +
  geom_bar(stat = "identity") +
  geom_errorbar()

# continuous x axis ----
# Eg. how does growth rate depend on when they were born? 

ggplot(juveniles, aes(x = julian.birth, y = growth.rate)) +
  geom_point() +
  geom_smooth() +
  xlab("Julian date of birth") +
  ylab("Growth rate (g/day)")

# ggplot puts subsequent lines of code on top of the previous layers
# If we reverse the order of geom_point & geom_smooth
ggplot(juveniles, aes(x = julian.birth, y = growth.rate)) +
  geom_smooth() +
  geom_point() +
  xlab("Julian date of birth") +
  ylab("Growth rate (g/day)")
# line is hidden behind the points now, not as effective


# can force the geom_smooth() to be linear
ggplot(juveniles, aes(x = julian.birth, y = growth.rate)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlab("Julian date of birth") +
  ylab("Growth rate (g/day)")

# Making it look better ----
# Once you've decided what type of figure you want, how can you make it look better?
# ggplot allows for lots of customization, has preset themes to change some things easily - and lots more available in ggthemes
# I don't like the grey background, prefer theme_light()
# you can add + theme_light() to each ggplot code chunk
# or, if you want to change the default, add it to the line when you load ggplot
library(tidyverse); theme_set(theme_light()) 

# same figure as before
ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_jitter(colour = "grey50") +
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar")

# Can change colour, size, shape of layers
ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_jitter(colour = "grey50", size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar",
               colour = "red", 
               width = 0.5, 
               size = 2)

# colour = X will work for lines & points, but for bars need to use fill = X, otherwise e.g.:
ggplot(summary, aes(x = grid, y = avg.growth, ymin = avg.growth + se, ymax = avg.growth - se)) +
  geom_bar(stat = "identity", colour = "red") +
  geom_errorbar()

ggplot(summary, aes(x = grid, y = avg.growth, ymin = avg.growth + se, ymax = avg.growth - se)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  geom_errorbar(size = 1.5, width = 0.5, colour = "red")

# If we want to change the axis titles, range:

ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_jitter(colour = "grey50", size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, 
               geom = "crossbar", colour = "red") +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4)) + # defines axis range
  scale_y_continuous(breaks = seq(0, 4, 0.5)) # defines axis intervals

# We're only showing one grouping here (grid), but what if we wanted to show multiple things on this figure? -----

# You can define aesthetics like colour within individual layers (as above), or you can use it to plot a third variable in addition to your x & y in the opening line
# e.g.:

ggplot(juveniles, aes(x = grid, y = growth.rate, colour = grid)) +
  geom_jitter(size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, 
               geom = "crossbar", colour = "red") +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4))

# default colour scheme for ggplot is this pastel rainbow
# not accessible to colourblind folks, and doesn't look great when printed black & white
# can manually tell ggplot what colours to use, either with hexadecimal, or preset names http://sape.inf.usi.ch/quick-reference/ggplot2/colour

ggplot(juveniles, aes(x = grid, y = growth.rate)) +
  geom_jitter(size = 0.7, colour = "grey50") + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar",
               colour = c("slateblue4", "firebrick", "chartreuse3",
                          "dodgerblue3", "chocolate4", "darkorchid4")) +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4))

# To make better colour figures: viridis ----
# alternative palettes that are easier to distinguish for colourblind people
# and also maintain legibility when converted to greyscale
library(viridis) 
# https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html

# default is as a continuous scale
ggplot(juveniles, aes(x = grid, y = growth.rate, colour = yr)) +
  geom_jitter(size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar",
               colour = "red") +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4)) +
  scale_colour_viridis()

# if want to use for groups,  discrete = TRUE
# visreg defaults to use the full scale, so if you only have two groups it doesn't look great. But can define the min and max boundaries along the gradients
ggplot(juveniles, aes(x = sex, y = growth.rate, colour = sex)) +
  geom_jitter(size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar",
               colour = "red") +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4)) +
  scale_colour_viridis(discrete = TRUE)

ggplot(juveniles, aes(x = sex, y = growth.rate, colour = sex)) +
  geom_jitter(size = 0.7) + 
  stat_summary(fun.y = mean, fun.ymin = mean, fun.ymax = mean, geom = "crossbar",
               colour = "red") +
  xlab("Study grid") +
  ylab("Growth rate (g/day)") +
  coord_cartesian(ylim = c(0, 4)) +
  scale_colour_viridis(discrete = TRUE, begin = 0.3, end = 0.7)


# Ok. We can make some figures, and make them look pretty good
# But if you're trying to see a relationship, often want to see the effect of X on Y while controlling for other covariates
# can use predict() from your model to create a new column in your df
# Or, the better way: visreg -----
library(visreg)
summary(lm1 <- lm(growth.rate ~ julian.birth + litter.size*sex + grid + yr, data = juveniles))

visreg(lm1)
# Shows effect of change in x on y while holding other terms constant
# default = median for numeric & most common for factors, but can specify
# not the exact same as partial residuals plot, but similar idea

# if we want to only see one of the predictors:
visreg(lm1, "grid")
# output tells you what values for other factors are, but can define manually
visreg(lm1, "grid", cond = list(julian.birth = 180, litter.size = 8, yr = 2016, sex = "F"))

# or show interactions: default is faceted, but can plot together with overlay = TRUE
visreg(lm1, "litter.size", by = "sex", strip.names = c("Females", "Males"))
visreg(lm1, "litter.size", by = "sex", overlay = TRUE)

# The most useful part: you can format visreg plots like ggplot!
visreg(lm1, "julian.birth")

visreg(lm1, "julian.birth", gg = TRUE) +
  xlab("Birth date") +
  ylab("Adjusted growth rate") +
  coord_cartesian(ylim = c(0, 4))

# with gg = TRUE, it takes on the same default theme_light() as our other plots
visreg(lm1, "litter.size", by = "sex", gg = TRUE) +
  xlab("Litter size") +
  ylab("Adjusted growth rate") +
  annotate(geom = "text", x = 2, y = 6.5, label = c("a", "b"), size = 10)

visreg(lm1, "julian.birth", gg = TRUE) +
  xlab("Birth date") +
  ylab("Adjusted growth rate") +
  geom_smooth(colour = "red")
# Annoying part: these points and lines are not ggplot objects
# you can create ggplot objects that appear on top of the visreg functions
# but you're not editing the visreg plot itself

# to edit the actual points or lines, have to do it in first line with base R plot code
visreg(lm1, "julian.birth", gg = TRUE, point = list(col = "black", size = 1.8),
       line = list(col ="red")) +
  xlab("Birth date") +
  ylab("Adjusted growth rate")

visreg(lm1, "julian.birth", gg = TRUE) +
  xlab("Birth date") +
  ylab("Adjusted growth rate") +
  geom_point(colour = "black") +
  geom_smooth(method = "lm", colour = "red") 

# compare with ggplot of birth date alone:
ggplot(juveniles, aes(x = julian.birth, y = growth.rate)) +
  xlab("Birth date") +
  ylab("Growth rate (g/day)") + 
  geom_point(colour = "black") +
  geom_smooth(method = "lm", colour = "red")

# Particularly useful for "strange" models - eg. Cox proportional hazard models
# don't have a single response variable - no way to create in ggplot
# but can create a visreg figure of a coxph() model, and then format as a ggplot so it looks the same as other figures
# example from my work:

unique <- read_csv("removals.csv")
library(coxme)
summary(model8 <- coxph(Surv(Latency, Intrusion) ~ Playback*Avg.ten + Julian + density, data = unique))
visreg(model8, "density", gg = TRUE, 
       line = list(col = "blue"),
       point = list(col = "black", size = 1, position = "jitter")) +
  xlab("Local density (squirrels/ha)") +
  ylab("Relative hazard of intrusion")
