##############################
## split-lapply combos
## Tutorial 02 - functions
##
## Karl Cottenie
##
## 2017-12-04
##
##############################

library(tidyverse)
library(viridis)
# + scale_color/fill_viridis(discrete = T/F)
theme_set(theme_light())

# Startup ends here

# Explore data set -----------------
serengeti = read_csv("http://datadryad.org/bitstream/handle/10255/dryad.86348/consensus_data.csv")
# For meta data on this data set, visit this link:
# http://datadryad.org/bitstream/handle/10255/dryad.86348/README.docx

head(serengeti)
summary(serengeti)

# Almost all data sets have grouping variables, and you want to repeat something for each of the groups
# Welcome to the world of split-lapply

# Split the data on the species identity, what is a list? -----
serengeti.Site = split(serengeti, serengeti$SiteID)
serengeti.Site # This is now a list with as each element a subset of the original data set
serengeti.Site[[1]] # this is how you inspect an element of the list
summary(serengeti.Site[[1]])

names(serengeti.Site) # explore the names

# RStudio option -----
# Use the object explorer
# go to the environment pane
# click on the search glass
# click on the down arrow, scroll, and arrow window

serengeti.Site$B07
serengeti.Site[["B09"]]

### Pair: How many rows and columns are there in F08?
### Pair: What was the first and last day that the camera trap took pictures?

# difference between [] and [[]] for a list -----
serengeti.Site[1] #This is a list with one element!
summary(serengeti.Site[1])

### Pair: Can you predict what these two lines will do?
serengeti.Site[1:4]
serengeti.Site[[1:4]]
### Pair: Why do they behave differently?

# Apply some function of interest to all elements in a list, lapply ----
dim(serengeti)
dim(serengeti.Site) # dim only works for a matrix-like object
length(serengeti.Site) # this is how you check how many elements there are in a list
dim(serengeti.Site[[1]]) # how many pictures from the first site?
dim(serengeti.Site[[2]]) # how many pictures from the second site?

### Pair: before you run the next line, what word should replace the XXX:
dim(serengeti.Site[[length(serengeti.Site)]]) # how many pictures from the XXX site?

# this is where the magic happens
lapply(serengeti.Site, dim) 
# lapply: apply a function to a list
# the list: serengeti.Site
# the function: dim

### Pair: how would you check that the lapply line of code above worked correctly?

# apply some function of interest to all elements in a list, for loop -----
for (i in seq_along(serengeti.Site)) print(dim(serengeti.Site[[i]]))
# for: apply something to a sequence
# i in seq_along(serengeti.Site) is the sequence generator
# print(dim(serengeti.Site[[i]])) is the something, in this case asking for the dimensions

### Pair: why is the print() statement necessary?

# Applying some function to all elements in a list, and save the results -----

site.dim.lapply = lapply(serengeti.Site, dim) 

site.dim.for = list()                                 # 1. output of the loop
for (i in seq_along(serengeti.Site)) {                # 2. sequence to loop through
  site.dim.for[[i]] = dim(serengeti.Site[[i]])        # 3. body of the function
  # print(dim(serengeti.Sit[[i]]))                    # 4. body of function can be multiple lines
}

### Pair: how would you check that lapply and for-loop results are the same, using only the tools we have used so far?

# Homework 01: -----
serengeti.behaviours = serengeti[10:11]               
summary(serengeti.behaviours)
### Pair: apply the summary function to each of the different species
serengeti.behaviours.sp = split(serengeti.behaviours, serengeti$Species)

# Answer 1 ----
lapply(serengeti.behaviours.sp, summary )

# Answer 1b
for(i in seq_along(serengeti.behaviours.sp)){  
  print(names(serengeti.behaviours.sp)[i])  
  print(summary(serengeti.behaviours.sp[[i]]))   
}
### Pair: how to make the output of the for loop equivalent to the output of the lapply?

plot(serengeti.behaviours)
### Pair: apply the plot function to the first 10 species

# Answer 1 = lapply
lapply(serengeti.behaviours.sp, plot)

# Answer 2 = for loop, looping over the indices
par(mfrow = c(2,5))
for(i in seq_along(serengeti.behaviours.sp[1:10])){    
  plot(serengeti.behaviours.sp[[i]])
  title(main = names(serengeti.behaviours.sp)[[i]])
}

# Answer 3 = for loop, looping over the list elements
par(mfrow = c(2,5))
for (i in serengeti.behaviours.sp[1:10]){
  plot(i)
  title(main = names(i)) # but a problem!
}

# Answer 4 = for loop, looping over the list elements
par(mfrow = c(2,5))

serengeti.sp = split(serengeti, serengeti$Species)
for (i in serengeti.sp[1:10]){
  plot(i[10:11])
  title(main = i[1,"Species"])
  abline(lm(Resting ~ Standing, data = i), col = "red", lwd = 3) # added some complexity
}

plot.regressionline = function(i){
  plot(i[10:11])
  title(main = i[1,"Species"])
  abline(lm(Resting ~ Standing, data = i), col = "red", lwd = 3) # added some complexity
}

plot.regressionline(serengeti.sp[[3]])
### Pair: plot the relationship between resting and standing for hartebeest

# now we can use our own function in a for loop
for(i in serengeti.sp[1:10]){
  plot.regressionline(i)
}

# simplify this even more
for(i in serengeti.sp[12:21]) plot.regressionline(i)

# link it to lapply!
lapply(serengeti.sp[15:24], plot.regressionline)

### Pair: plot the regression line for Eating as a function of moving, using only the tools we have used
#Moving == 12th col
#Eating == 13th col
#
serengeti.move = serengeti[15:24] 
head(serengeti.move)
serengeti.serengeti.move.sp = split(serengeti.move , serengeti$Species)
to_plot = serengeti.serengeti.move.sp[1:10]

apply_behaviour_name_plot = function(data, name_dat){
  plot(data, main=name_dat, xlab=names(data)[1], ylab=names(data[2]) )
  abline(lm(Eating ~ Moving  , data = data), col = "red", lwd = 3)
} 

par(mfrow=c(2,5))

mapply(apply_behaviour_name_plot, to_plot, names(to_plot))



# lapply with anonymous functions!

# Homework 02 -----
### Pair: with a split-lapply construct, for each site compute the average behaviours for the different species
### and save this to a new object
### Pair: with a split-lapply construct, plot the average resting versus standing for all species for the  
### first 10 sites, and also plot the regression line
### Pair: with a split-lapply construct, create an object that has the slopes of that relationship for 
### all the sites (hint, see ?summary.lm on how to extract information from an lm object)
