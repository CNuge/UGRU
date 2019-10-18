print("look it did stuff without opening a file! wow.")


#TODO - throw this in the myfunc lib

#' A simple inverse of the in function.
`%!in%` = function(x, y){ !'%in%'(x, y) }

x = 5
y = c(2,4,5,6)
5 %!in% y
7 %!in% y

#misc - in rmd use *** to delimit slides, i.e a page break in the pdf




