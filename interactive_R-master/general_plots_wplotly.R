# General plotting library: plotly
# More info: 
# http://www.htmlwidgets.org/showcase_plotly.html
# https://plot.ly/r/

#install.packages("plotly")

library(plotly)
library(htmlwidgets)

#setwd("~/guelph/teaching/interactive_R/")

## Get some data

whs <- read.csv("whs_pc1to5.csv", header=T)
head(whs)
plot_ly(data=whs, type="scatter", mode="markers", x= ~PC1, y= ~PC2)

# Break out by location
plot_ly(data=whs, x= ~PC1, y= ~PC2, type="scatter", mode="markers", color= ~location) 

# Break out by basin
plot_ly(data=whs, x= ~PC1, y= ~PC2, type="scatter", mode="markers", color= ~basin)

# Add individual labels
plot_ly(data=whs, x= ~PC1, y= ~PC2, type="scatter", mode="markers", color= ~basin, text= ~paste(individual,"\n", basin))


#this is really neat, you can save the information to an html file
#then you can look at the plot in your web browser after the fact without
#re-running the r code each time.
pcaplot <- plot_ly(data=whs, x= ~PC1, y= ~PC2, type="scatter", mode="markers", color= ~basin, text= ~paste(individual,"\n", basin))
saveWidget(pcaplot, "pca_whs.html")
