
##############################
## split-lapply combos
## Tutorial 01
##
## Karl Cottenie
##
## 2017-12-04
##
##############################
getwd()
setwd('/Users/Cam/Desktop/Code/RUsersGroup')


library(tidyverse)
library(viridis)

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
#splits it into 225 
length(serengeti.Site) 

# This is now a list with as each element a subset of the original data set
#double slice to see each lil bit
serengeti.Site[[1]] # this is how you inspect an element of the list

summary(serengeti.Site[[1]])

names(serengeti.Site) # each of the sub dataframes is named by the 
						#site ID from when it was split off

# you can also call the different sites by their ID (the thing they were split by)
# So this can act like a sudo dictonary
serengeti.Site$B07
serengeti.Site[["B09"]]

### Pair: How many rows and columns are there in F08?
nrow(serengeti.Site$F08)
#1396

x = c(1,2,3,4,5,6)

x[2:4]

### Pair: What was the first and last day that the camera trap took pictures?

# difference between [] and [[]] for a list -----
serengeti.Site[1] #This is a list with one element!
summary(serengeti.Site[1])

### Pair: Can you predict what these two lines will do?
serengeti.Site[1:4] #sites one to four

serengeti.Site[1]

### Pair: Why do they behave differently?

# Apply some function of interest to all elements in a list, lapply ----
dim(serengeti)
dim(serengeti.Site) # dim only works for a matrix-like object
length(serengeti.Site) # this is how you check how many elements there are in a list
dim(serengeti.Site[[1]]) # how many pictures from the first site?
dim(serengeti.Site[[2]]) # how many pictures from the second site?

### Pair: before you run the next line, what word should replace the XXX:
dim(serengeti.Site[[length(serengeti.Site)]]) # how many pictures from the last site in the list?

# this is where the magic happens
lapply(serengeti.Site, dim) 

# lapply: apply a function to a list
# the list: serengeti.Site
# the function: dim
dim(serengeti.Site[['V12']])
dim(serengeti.Site[['U10']])

### Pair: how would you check that the lapply line of code above worked correctly?

# apply some function of interest to all elements in a list, for loop -----
for(i in 1:length(serengeti.Site)){ 
    print(dim(serengeti.Site[[i]]))
}

# for: apply something to a sequence
# i in seq_along(serengeti.Site) is the sequence generator
# print(dim(serengeti.Site[[i]])) is the something, in this case asking for the dimensions

### Pair: why is the print() statement necessary?

# Applying some function to all elements in a list, and save the results -----

site.dim.lapply = lapply(serengeti.Site, dim) 

site.dim.for = list()                                 # 1. output of the loop
for (i in seq_along(serengeti.Site)) {                # 2. sequence to loop through
  site.dim.for[[i]] = dim(serengeti.Site[[i]])        # 3. body of the function
  #print(dim(serengeti.Site[[i]]))                      # 4. body of function can be multiple lines
}


for(i in 1:length(site.dim.lapply)){
  print(site.dim.lapply[[i]] == site.dim.for[[i]])
}

site.dim.for[1]
site.dim.lapply[1]

for(i in 1:length(site.dim.lapply)){
  if(site.dim.lapply[[i]] != site.dim.for[[i]]){
      print('FUCK')
  }
}



### Pair: how would you check that lapply and for-loop results are the same, using only the tools we have used so far?

# Homework 01: -----

serengeti.behaviours = serengeti[10:11] # a data frame/tibble is a list of columns/variables!
plot_by_species = split(serengeti[10:11], serengeti$Species)
to_plot = plot_by_species[1:10]



head(plot_by_species)
summary(serengeti.behaviours)

### Pair: apply the summary function to each of the different species

plot(serengeti.behaviours)

par(mfrow=c(2,5))
lapply(plot_by_species[1:10], plot)

### Pair: apply the plot function to the first 10 species
### Pair-intermediate: can you plot the species name as the title of the plot?



behaviour_name_plot = function(data){
  plot(data[[1]], main=names(data) )
} 


#test
behaviour_name_plot(to_plot[2])


par(mfrow=c(2,5))

for(i in 1:10){
  behaviour_name_plot(to_plot[i])
}



apply_behaviour_name_plot = function(data, name_dat){
  plot(data[[1]], main=name_dat, xlab=names(data)[1], ylab=names(data[2]) )
} 

par(mfrow=c(2,5))

mapply(apply_behaviour_name_plot, to_plot, names(to_plot))


#make a change



