library(tidyverse)
library(viridis)

serengeti = read_csv("http://datadryad.org/bitstream/handle/10255/dryad.86348/consensus_data.csv")
serengeti.behaviours = serengeti[10:11] # a data frame/tibble is a list of columns/variables!
plot_by_species = split(serengeti[10:11], serengeti$Species) #split by species
to_plot = plot_by_species[1:10] #so I don't forget to subset


# after thinking about my comments below I was able to pick up the pattern that
# was causing me trouble. I wrote a blog post on it and posted it here:
# https://camnugent.wordpress.com/2018/01/24/tales-from-the-r-users-group-labeled-lists-lapply-and-the-single-and-double-slice/





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

# For example, working with the simplest labelled list possible:

# a list of 3 numbers and their corresponding labels
my_list = list(1,2,3)
names(my_list)= c('a', 'b', 'c')

my_list

# what is at position a?

my_list['a'] # in Cam's utopian R this would just return a plain 1
# but a alas the 'a' label is stuck on top
# paradoxically the type tells me it is a number :/
typeof(my_list['a'])  
# but that seems not true because for practical purposes it behaves like a one member list!
# see below when I do math with the data in the  first position of my list,
# I get a LABELLED NUMBER! ugh.
my_list['a'] + 3


names(my_list['a'] + 3)
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
# this disconnect between behaviour in the apply and outside is not intuitive.
# lapply works at the level below the labels, so we can't directly use the labels
# this bothers me because it goes against the convention I was just forced by R
# to adopt in order to work with the labelled list's data in the first place
# within the lapply, we need to give the function another source to access them from

par(mfrow=c(2,5))
lapply(to_plot, 
  function(x) { plot(x[[1]], main=names(x[1]) )})


# here is the trick pass the higher up list to the lapply names(the_list) , 
# and call the lower list through an external call to its variable.
# in my opinion there shouldn't need to be a trick though! Trick are inherently complex

lapply(names(to_plot), 
  function(x) { plot(to_plot[[x]], main=names(to_plot[x]))})

# 4. I guess the take home message here is that although working with the labelled lists
# in lapply is possible, it was likely not the intended use of the function and therefore
# the syntax required to make it works is a bit unintuitive. I think the best use of lapply
# is to use R's built in functions across a list of dataframes or other things
# i.e. to get a list of means column z in each of the datframes in the list

# Through Jonathan and Nia's discussion answers, I was able to better understand how one can use lapply with
# home made functions, by leveraging the internal anonymous function to apply it to a list
# containg complex data structures (not just numbers) at each position


# 5. I have stumbled upon the real strength of the mapply while doing my homework!
# here I demonstrate this powerful trope with the iris dataset:

# For the point of demonstration, lets say that the petals in the dataset are all triangles
# and I want to find the area of the petals. With the length of the petal being the base, and
# the width of the petals being the height.

# I write a function that calculates that, and mapply it to the whole dataframe at once
head(iris) #recall the columns

# my triangle area function
tri_area = function(base, height){
  (base * height) / 2 
}

# here we make a new column Petal.Area using the mapply to run the tri_area function for all 
# the rows in the dataframe at once. mapply lets you make a column or columns the input,
# and create a column that is the output! Thats neat!

iris$Petal.Area = mapply(tri_area , iris$Petal.Length , iris$Petal.Width )