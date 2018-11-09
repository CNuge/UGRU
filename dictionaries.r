library('tidyverse')


x = list(a = 1, b = 2)

x[1]

x$c = 1

x$d = 2

x$a = NULL

x$b == 2

z = x$b

z = 9

x


names(x)[1] #keys
x$a			#keys
x[['a']]	#values
x[[1]]		#values


#this is like a list of tuples
z = unlist(x)
z[1]

names(z)[1] #keys
z[[1]]		#values

