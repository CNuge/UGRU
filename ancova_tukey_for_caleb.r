
install.packages('multcomp')

library(multcomp) #have a look at the manual on cran
#https://cran.r-project.org/web/packages/multcomp/multcomp.pdf


#making a fake categorical for demo
mtcars$cyl = as.factor(mtcars$cyl)

#predict hp using cyl and mpg
#mpg is a numeric
#cyl is categorical
ex_ancova = aov(hp ~ cyl + mpg, data = mtcars)

summary(ex_ancova) #sig cyl

#base r
#this gives us a warning
TukeyHSD(ex_ancova, which = 'cyl')

# with this, we can compare the categoricals, even though there
# is a numeric covariate.
# could extend to multiple categricals as well, just change the mcp() accordingly
cars_mc <- glht(ex_ancova, linfct = mcp(cyl = 'Tukey'))
summary(cars_mc)

#^subtle thing I found, glht won't work as shown if you do mtcars$cyl in the initial
#call of the aov function... which is odd