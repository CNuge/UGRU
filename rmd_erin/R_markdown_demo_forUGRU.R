#1. Loading necessary packages
library(readr)
library(dplyr)
library(visreg)

#2. Packages needed for R markdown
library(rmarkdown)
library(knitr)

#3. Setting working directory
setwd("/Users/Cam/Desktop/Code/UGRU/jupyter_notebook")

#4. We are going to use the dataset "ToothGrowth", which looks at the effect of VitC on tooth growth in Guinea Pigs. Information can be found here:
?ToothGrowth

#5. Get dimensions of dataframe
dim(ToothGrowth)

#6. Summarize data
summary(ToothGrowth)

#7. It looks like we need to change supplement type to a factor
ToothGrowth$supp <- as.factor(ToothGrowth$supp)

#8. Let's gather some basic descriptive stats. What is the mean and standard error for tooth length?
mean(ToothGrowth$len)
sqrt(var(ToothGrowth$len)/length(ToothGrowth$len))

#9. Lets look at the effect of dosage on tooth length
summary(lm1 <- lm(len ~ dose, data=ToothGrowth))

#10. Check diagnostics
par(mfrow=c(2,2))
plot(lm1)
par(mfrow=c(1,1))
hist(resid(lm1))

#11. Plot this relationship
visreg(lm1, "dose")

#12. Lets try another model to look at the effect of the type of supplement on tooth length
summary(lm2 <- lm(len ~ supp, data=ToothGrowth))

#13. Plot this relationship
visreg(lm2, "supp")

#14. How about an interaction between dose and supplement type?
summary(lm3 <- lm(len ~ dose*supp, data=ToothGrowth))

#15. Plot this relationship
visreg(lm3, "dose", by="supp")

#16. Homework assignment:

#16.1. Turn this R script into an R markdown document of your choice (html, word, pdf) complete with annotations of your code. 

#16.2. Create a header at the top of your R markdown document called "R Markdown demo". Create a subheader for each section of your analysis.

#16.3 Write this at the start of your R markdown document:  "This is a demonstration to show you how R Markdown works. Here is a helpful link to find out more about R Markdown." Can you bold the word "demonstration" and turn the word "link" into a hyperlink that takes you to this page (https://www.rstudio.com/wp-content/uploads/2016/03/rmarkdown-cheatsheet-2.0.pdf)?

#16.4 Notice that in Step 1 when you load the dplyr package you receive a message that says: "Attaching package: 'dplyr'. The following objects are masked from 'package:stats'... etc." Can you adjust your R markdown script so that this message does NOT display? 

#16.5 For each line in your R script, can you get R markdown to return only your results and not the code? What about only the code and not the results? 

#16.6 After plotting lm1 in Step 11 can you write one sentence explaining the results from this model, including your appropriately formatted parameter estimate, t test statistic, and P value? (hint: how do you get the Beta symbol or insert subscripts in R markdown?)

#16.7 Can you plot each figure without including the associated code?

#16.8 Can you make an R markdown document with ONLY the figures?

#16.9 BONUS: Can you create an html/pdf/or word doument directly from this Rscript? (i.e. without opening a new R markdown document?)

#rmarkdown::render("R_markdown_demo_forURGU.R") #will make an html
#rmarkdown::render("R_markdown_demo_forURGU.R", pdf_document())

