##############################
## Repeat combos - Annotated code
## Part 01
##
## Karl Cottenie
##
## 2018-09-20
##
##############################

# install.packages("tidyverse")
# uncomment the above line if tidyverse is not installed yet
library(tidyverse)

# install.packages("lubridate")
# uncomment the above line if lubridate is not installed yet
library(lubridate)

# Startup ends here

# Import data set and data wrangling -----------------

serengeti = read_csv('consensus_data.csv')
# For meta data on this data set, visit this link:
# http://datadryad.org/bitstream/handle/10255/dryad.86348/README.docx
# ^its not there... maybe they had to take it down to remove the forumals from the cells XD


serengeti
summary(serengeti)


# create a community composition data set, we will come back to this later
serengeti_wide = serengeti %>% mutate(Year = year(DateTime)) %>% 
  # create a Year variable
  dplyr::select(Year, SiteID, Species, Count) %>% 
  # select only the variables of interest
  mutate(Count = as.numeric(Count)) %>% 
  # convert count into correct type
  group_by(Year, SiteID, Species) %>% 
  # create groups
  summarise(Total = sum(Count)) %>% 
  # create total counts per species for each Year-SiteID combination
  ungroup() %>% 
  # some housekeeping
  spread(Species, Total) 
# create a sample by species community composition

serengeti_wide[is.na(serengeti_wide)] = 0 
# NA are basically absent species

summary(serengeti_wide) # check if everything is ok

# Simple statistical analysis ---------

# for simplicity, analysis per year
# start with 2010
plot(lionMale ~ lionFemale, 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2010)
# lots of variability, let's try with a square-root transformation

plot(I(lionMale^0.25) ~ I(lionFemale^0.25), 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2010)
# looks a lot better, continue with this

lionregr = lm(I(lionMale^0.25) ~ I(lionFemale^0.25),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2010)
# just an illustration of the power of using the formula framework

# basic statistics
anova(lionregr)

# now we can easily add the regression line to the plot
abline(lionregr)

### pairs: What is the simplest way to repeat this analysis for every year?
### pairs: Is there a similar relationship between male and female lions across years?

# Solution:

plot(I(lionMale^0.25) ~ I(lionFemale^0.25), 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2012)
# looks a lot better, continue with this

lionregr = lm(I(lionMale^0.25) ~ I(lionFemale^0.25),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2012)
# just an illustration of the power of using the formula framework

# basic statistics
anova(lionregr)

# now we can easily add the regression line to the plot
abline(lionregr)


### Pairs: You think that square root is not the appropriate transformation, but that it should be a root transformation. Adjust your code accordingly.

# Solution

plot(I(lionMale^0.5) ~ I(lionFemale^0.5), 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2012)
# looks a lot better, continue with this

lionregr = lm(I(lionMale^0.5) ~ I(lionFemale^0.5),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2012)
# just an illustration of the power of using the formula framework

# basic statistics
anova(lionregr)

# now we can easily add the regression line to the plot
abline(lionregr)


# Problem with this approach?

# Answer
# - lots of code
# - lots of similar looking code
# - easy to make mistakes when copy-pasting and changing values
# - if you made a mistake, you need to make a lot of changes


# Repeating something multiple times for structured data -------

# Almost all data sets have for instance grouping variables, and you want to repeat something for each of the groups
# Welcome to the world of "repeats"

# using pseudo code:
# for every year in the data set
# create a figure of male lion density as a function of female lion density
# and add the regression line

for (i in XXXXX){
  plot(XXXX)
  abline(XXXXX)
}

### Pairs: replace the XXXXX with the correct code

# Solution

2010:2013

par(mfrow = c(2,2)) # I added this line to plot all figures in one plot

for (i in unique(serengeti_wide$Year)){
  plot(I(lionMale^0.5) ~ I(lionFemale^0.5), 
       data = serengeti_wide, 
       subset = serengeti_wide$Year == i)
  lionregr = lm(I(lionMale^0.5) ~ I(lionFemale^0.5),
                data = serengeti_wide, 
                subset = serengeti_wide$Year == i)
  # now we can easily add the regression line to the plot
  abline(lionregr)
}

# Note1: The body of the "for" loop is what you copy-pasted in the simple copy-paste method above
# Note2: the thing that you changed in the copy-paste method becomes the iterator

# Create a function -----------

# Now that we are comfortabe creating a "for" loop, the step to creating a function is easy
# What is the thing that varies inside the "for" loop?

# In a function, the "thing that varies" is an argument
# using pseudo code
# name_of_the_function = function("thing that varies){
# do stuff with "thing that varies"
# }

### Pairs: create function male_vs_female
### Make sure that your function has only one argument!
### Pairs: plot the 4 years with a for loop and a function

# Solution

male_vs_female = function(i){
  plot(I(lionMale^0.5) ~ I(lionFemale^0.5), 
       data = serengeti_wide, 
       subset = serengeti_wide$Year == i)
  lionregr = lm(I(lionMale^0.5) ~ I(lionFemale^0.5),
                data = serengeti_wide, 
                subset = serengeti_wide$Year == i)
  # now we can easily add the regression line to the plot
  abline(lionregr)
}

# Note: The function is identical to the for loop, which is almost identical to the original code that you wrote for one year

male_vs_female(2013)
# just checking if the function works

par(mfrow=c(2,2))
for (i in 2011:2013){
  male_vs_female(i)
}
# repeating the function multiple times, similar to the for loop code

# lapply magic ----------

# remember pseudocode for "for" loop
for (i in XXXXX){
  do_something_with(i)
}

# lapply does similar loop, but without all the set-up
lapply(XXXXX, do_something)

par(mfrow=c(2,2))
lapply(2011:2013, male_vs_female)

# lapply is thus an abstraction of a function in a for-loop, a function is an abstraction of a for-loop, and a for-loop is an abstraction of repeating an copy-paste-change approach, which is something we all know how to do.
# Thus if you want to write a function, think about how you would copy-paste-change that piece of code.
# Thus if you want to write a for loop, think about how you would copy-paste-change that piece of code.
# Thus if you want to use lapply, think about how you would copy-paste-change that piece of code.


### Homework: generalize the function male_vs_female to any two species, and plot the relationship per year for elephant and zebra.
### Hint: your function will have at least 3 arguments, instead of just one.

# And next time, remember this quote: 
# "Of course someone has to write loops. It doesn't have to be you."
# https://speakerdeck.com/jennybc/row-oriented-workflows-in-r-with-the-tidyverse

