##############################
## Repeat combos
## Part 01
##
## Karl Cottenie
##
## 2018-09-20
##
##############################

#install.packages("tidyverse")
# uncomment the above line if tidyverse is not installed yet
library(tidyverse)

# install.packages("lubridate")
# uncomment the above line if lubridate is not installed yet
library(lubridate)

# Startup ends here

# Import data set and data wrangling -----------------

serengeti = read_csv("http://datadryad.org/bitstream/handle/10255/dryad.86348/consensus_data.csv")
# For meta data on this data set, visit this link:
# http://datadryad.org/bitstream/handle/10255/dryad.86348/README.docx

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


serengeti
serengeti$Year = year(serengeti$DateTime)
serengeti$Count = as.numeric(serengeti$Count)


#first two just equivalent to:
#serengeti$Year = year(serengeti$DateTime)
#serengeti$Count = as.numeric(serengeti$Count)
#then grouping by the year and species,
# summarize the data by counts
# ungroup to remove the group labels
#then spread the data to wide format so that there is a unique column
# for each of the species, not present are auto filled with NA

serengeti_wide[is.na(serengeti_wide)] = 0 
#we then fill the NA with 0 
#note there has been some loss of information here because
#the as.numeric(serengeti$Count) removed the "11-50" entries... 
#probably best way to approach it 


# NA are basically absent species

summary(serengeti_wide) # check if everything is ok
serengeti_wide

# Simple statistical analysis ---------

serengeti_wide$lionMale[1:100]
serengeti_wide$lionFemale[1:100]

# for simplicity, analysis per year
# start with 2010
plot(lionMale ~ lionFemale, 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2010)
# lots of variability, let's try with a square-root transformation

#this is a roundabout way of doing a square root
plot(I(lionMale^0.25) ~ I(lionFemale^0.25), 
     data = serengeti_wide, 
     subset = serengeti_wide$Year == 2010)

#little nicer:
plot(sqrt(lionMale) ~ sqrt(lionFemale), 
     data = serengeti_wide, 
     subset = serengeti

# looks a lot better, continue with this

lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2010)

lionregr
summary(lionregr)

# just an illustration of the power of using the formula framework

# basic statistics
anova(lionregr)

# now we can easily add the regression line to the plot
abline(lionregr)

### pairs: What is the simplest way to repeat this analysis for every year?
### pairs: Is there a similar relationship between male and female lions across years?

# Solution:
#how many years
unique(serengeti_wide$Year)


#easiest
lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2010)

lionregr
summary(lionregr)



lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2011)

lionregr
summary(lionregr)


lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2012)

lionregr
summary(lionregr)


lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == 2013)

lionregr
summary(lionregr)



for (i in unique(serengeti_wide$Year)){
  lionregr = lm(sqrt(lionMale) ~ sqrt(lionFemale),
              data = serengeti_wide, 
              subset = serengeti_wide$Year == i)

  lionregr
  print(summary(lionregr))
}







### Pairs: You think that square root is not the appropriate transformation, but that it should be a root transformation. Adjust your code accordingly.

# Solution














### You peaked!




# Problem with this approach?





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








# lapply magic ----------

# remember pseudocode for "for" loop
for (i in XXXXX){
  do_something_with(i)
}

# lapply does similar loop, but without all the set-up
lapply(XXXXX, do_something)

### Homework: generalize the function male_vs_female to any two species, and plot the relationship per year for elephant and zebra.
### Hint: your function will have at least 3 arguments, instead of just one.
