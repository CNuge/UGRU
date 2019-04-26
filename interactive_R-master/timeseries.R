# Now we'll do a timeseries
# We're using the dygraphs package
# Info on dygraphs here: http://www.htmlwidgets.org/showcase_dygraphs.html

#Install and load the package
install.packages("dygraphs")
library(dygraphs)

# Set working directory
setwd("~/guelph/teaching/interactive_R/")

# I didn't have any time series data when I made this tutorial, so we'll make some up:
years <- seq(1916,2016,1)
attacks <- round(rnorm(101, mean=c(1:50,51:1)))
nzombies <- (attacks*2)

# Make dataframe
danger <- data.frame(years, attacks, nzombies)

# Simple timeseries
dygraph(danger, main = "Zombie attacks and zombie population by year")

# Plot timeseries
dygraph(danger, main = "Zombie attacks and zombie population by year") %>%
  dyRangeSelector(dateWindow = c("1916", "2016")) %>%
  dyOptions(colors=c("orange", "black")) %>%
  dyHighlight(highlightCircleSize = 5, 
              hideOnMouseOut = F) %>%
  dyEvent("1965", "Invention of zombicide", labelLoc="bottom")

# To save repeatably
z <- dygraph(danger, main = "Zombie attacks and zombie population by year") %>%
  dyRangeSelector(dateWindow = c("1916", "2016")) %>%
  dyOptions(colors=c("orange", "black")) %>%
  dyHighlight(highlightCircleSize = 5, 
              hideOnMouseOut = F) %>%
  dyEvent("1965", "Invention of zombicide", labelLoc="bottom")

library(htmlwidgets)

