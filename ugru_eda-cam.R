#######
#
library(tidyverse)

#######
# basic EDA

#iris = read.csv(filename, stringsAsFactors = FALSE)
iris
head(iris)

#basic check functions and slicing
unique(iris$Species)
length(iris$Species)

iris$Species[[1]]
iris$Species = as.character(iris$Species)
#how to drop levels
iris$Species[[1]]

#iris = read_csv(filename)
#if your tibble has a weird leading column
iris$X1 = NULL #drop it by making it NULL


#Cleaning data/EDA == k.i.s.s.

# look at it as a tiblle
iris = as_tibble(iris)
iris

unique(iris$Species)


#functions to get these numbers, so you don't have to hard code them
dim(iris) #rows, columns
dim(iris)[[1]]
ncol(iris)
nrow(iris)
unique(iris$Species)
length(iris$Species)

#i.e. this is rpbust to changes to the dataframe size
for(i in 1:nrow(iris)){
	print(iris$Species[[i]])
}

#mix basic functions to check column for duplicates
length(unique(iris$Species)) == length(iris$Species)

#subset one columns using another
iris$Petal.Length[ iris$Species == "setosa"  ]


#look at the avaliable colnames and subset
names(iris)

keep = c("Species")

keep_df = iris[keep]
#inverse
not_keep_df = iris[!names(iris) %in% keep]




#build a df from vectors on the fly:
x = c(1,2,3)
y = c(3,4,5)

x
y

z = data.frame(colname1 = x, colname2 = y)


#some string maniplulation examples building on jackies stuff

yy = 'ATGCATCCCA\tATGCATGCATGCATGC'

strsplit(yy, split =  '\t')

front = "my name is"
back = "firstname"
back2 = "lastname"

fullname = c(back, back2)

#look at how behaviour of the following vary

paste(front, back, sep = "\t")

paste(front, back, back2, sep = "\t")

paste(front, fullname, sep = "\t") #bad!

paste(front, fullname)

paste(front, fullname, collapse = "\t")
