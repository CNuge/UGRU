library(tidyverse)
library(viridis)

serengeti = read_csv("http://datadryad.org/bitstream/handle/10255/dryad.86348/consensus_data.csv")
serengeti.behaviours = serengeti[10:11] # a data frame/tibble is a list of columns/variables!
plot_by_species = split(serengeti[10:11], serengeti$Species) #split by species
to_plot = plot_by_species[1:10] #so I don't forget to subset


##############
#
### Q1: apply the summary function to each of the different species
#
###############

par(mfrow=c(2,5))
lapply(plot_by_species[1:10], plot)

##############
#
### Q2: apply the plot function to the first 10 species
### Pair-intermediate: can you plot the species name as the title of the plot?
#
###############
# and have the names of the species on the given plots


##############
#
#Matt B's answer
#
##############

# the simplest by far... but it doesn't use lapply just good old iteration
# his notes:
##A lot of people suggested the use of function (anonymous and otherwise)
##However, iterating through a very simple for loop does the trick 
##The code is easier to learn/write, there's really no need to get fancy
##This for loop works like a dream!!

par(mfrow=c(2,5))
for(i in 1:10){
  plot(plot_by_species[[i]], main = names(plot_by_species[i]))
}

##############
#
#Jonathan Kennel's answer
#
###############


plot_by_species = split(serengeti, serengeti$Species) #split by species

par(mfrow=c(2,5))

lapply(plot_by_species[1:10], 
		function(x) plot(Standing~Resting, x, main = Species[1]))



##############
#
#Nia's solution
#
###############

# I can follow the solution below better
# we are applying the function to the list of names, where each list of
# names are used to call the particular subset of the serengeti.Species2 list

# the x in function(x) is c('aardvark' 'aardwolf'... etc.) and it is calling the serengeti.Species2
# list member correspnding to the name, and plotting it while applying the label to the plot


#Split dataset on species and extract columns 10 and 11 (behaviours)
serengeti.Species2 = split(serengeti[10:11], serengeti$Species)
 
#Set up multi-paneled plot
par(mfrow=c(2,5))
 
#Plots 1-10 with name
lapply( names(serengeti.Species2[1:10]), 
		function(x) plot(serengeti.Species2[[x]], main = x))


##############
#
# Cam Solution 1
#
###############

# this is the same as Matt B's but utilizes a function to make the plot
# just abstracted the plot away on preference more then anything. Matt's answer K.i.s.s.


#make a function that plots the data and adds a name
behaviour_name_plot = function(data){
  plot(data[[1]], main=names(data) )
} 


#test the function
#passes my unit test and does what I expect
behaviour_name_plot(to_plot[2])

#but when I lapply it... the scope is the level below the names of the list
# which is not expected. It puts the column names as the title!
# so my solution to get the names on the plot is no good with lapply!
par(mfrow=c(2,5))
lapply(to_plot, behaviour_name_plot)


#but if I loop over them it works as I would expect
#so lapply and loops are not as equivalent as I would like

par(mfrow=c(2,5))
for(i in 1:10){
  behaviour_name_plot(to_plot[i])
}


##############
#
# Cam Solution 2
#
###############

# by making the function accept 2 arguments, I can pass
# the names of the plots and the plot data into the function.
# I then use mapply to run the function with the two sets of variables passed in
?mapply


apply_behaviour_name_plot = function(data, name_dat){
  plot(data[[1]], main=name_dat, xlab=names(data)[1], ylab=names(data[2]) )
} 

par(mfrow=c(2,5))

mapply(apply_behaviour_name_plot, to_plot, names(to_plot))


#things I don't like:

# mapply is format: mapply(function, data)
# lapply is format: lapply(data, function)
# why are these opposite?

# mapply is also not as intuitive as a loop, if I wasn't comfortable with
# the vernacular of R I'm not sure I would have been able to google the right 
# questions!

# I can't apply my function 'as is'... I needed to rewrite the function to
# accomidate the names() usage... so although the mapply is efficient, it 
# requires more 'upstream work' then a good old for loop.


# Cam yelling from atop a soapbox:

# 1. The apply family is fun R specific syntactic sugar (which is a tradeoff)
# using the syntactic sugar of R provides the ability to project code along a series 
# or dataframe all in one line. This is concise and appears to carry a speed advantage,
# but comes at the cost of being more cryptic and not as intuitive for the
# readers of the code (opposed to the writers of the code).

# 2. x[i] vs x[[i]]
# here is the official documentation on it:
# https://cran.r-project.org/doc/manuals/R-lang.html#Indexing
# Having x[i] return an object with a label on it causes more problems then it solves
# and makes the data structure clunky. My gripe with this (and other things like tibbles)
# is that I have to do extra work to get plain data... the labels are more 
# 'sticky' than common sense would suggest they should be

# For example the simplest labelled list possible:

# a list of 3 numbers and their corresponding labels
my_list = c(1,2,3)
names(my_list)= c('a', 'b', 'c')

my_list

# what is at position a?

my_list['a'] # in Cam's utopian R this would just return a plain 1
# but a alas the 'a' label is stuck on top
# paradoxically the type tells me it is a number :l 
typeof(my_list['a'])	
# but that seems not true because for practical purposes it behaves like a one member list!
# see below when I do math with the data in the  first position of my list,
# I get a LABELLED NUMBER! ugh.
my_list['a'] + 3

# long story long the [[i]] should be the default, and the labelled the special case.
# in most instance a naked number makes more sense
my_list[['a']] # this should be what my_list['a'] returns


# 3. What I learned from today's homework is that the lapply sees data from my Utopian R,
# and not the behaviour we see when we call things one at a time from the list.

# Consider the data from the homework, here isolated as to_plot
# it is a labelled list of 5 dataframes

typeof(to_plot) #its a list
to_plot[1] #this gives me a labelled dataframe 'aardvark'
to_plot[[1]] #this gives me just a list without the 'aardvark' label

# based off that, calling the single slice, I can get the label
names(to_plot[1]) #this gives me aardvark
names(to_plot[[1]]) # this gives me "Standing" and "Resting"

# but when I use it in an lapply with an anonymous function, the 
# individuals rows (x in the function) don't have the labels
# so names(x[1]) gives me 'standing' and names(x) also gives me 'standing'!
# why can't I access the label in the same way I did with the individual slices
# this disconnect between behaviour in the apply and outside is not intuitive

par(mfrow=c(2,5))
lapply(to_plot, 
	function(x) { plot(x[[1]], main=names(x[1]))})





