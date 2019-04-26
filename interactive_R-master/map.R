# Install the leaflet package
# Info on leaflet here: 
# http://www.htmlwidgets.org/showcase_leaflet.html
# http://rstudio.github.io/leaflet/

#the above list a lot of different packages avaliable for interactive plotting in r
#lets you use the javascript web based interactive plots without having to 
#know how to code javascript... which is neat

#install.packages("leaflet")

# Load package and set working directory
library(leaflet)
#setwd("~/guelph/teaching/interactive_R/")

## Read in data
samp <- read.csv("locations_all.csv", header=T)
head(samp)

## Set up plot, one line at a time
leaflet(data=samp[,2:3]) %>%  # Specify which data you want to plot
  setView(lng=-109.55, lat=41.16, zoom=6) %>%  # Set size of window
  addProviderTiles("Hydda.Base") %>%  # Choose basemap
  addMarkers(lng=samp[,2], lat=samp[,3], popup= samp[,1])%>%  # Plot points
  addMarkers(lng=samp[,2], lat=samp[,3], popup=paste("Hello there! This is site",samp[,1]))
  
## Well, this is fairly useless - I (mostly) study rivers, and the rivers on the
## base map suck. Luckily, we can add our own from a shape file.
  
## Read in River and Basin data - from National Hydrography Database, I think. 
#install.packages(c("maptools", "rgdal"))
library(maptools)
library(rgdal)
  
# Load Rivers shapefile, check it out, subset   
Rivers.all <- readOGR(dsn="rs14fe02.shp") #NB, other associated files (.shx, .dbf, .prj) should be in the same directory
names(Rivers.all)
Rivers <- Rivers.all[Rivers.all$HUC2==14,] # We only want to plot the Upper Colorado River basin, and the original shapefile is much bigger. 
class(Rivers) # Double check data type - needs to be "SpatialLinesDataFrame" - from the package "sp"

## Load basin polygons
basins <-  readOGR("WBDHU4.shp")
names(basins)

## Subset again to reduce the size of what we'll plot
ucrb <- basins[as.numeric(as.character(basins$HUC4)) > 1400 & as.numeric(as.character(basins$HUC4))<1500,]

leaflet(data=samp[,2:3]) %>%
  setView(lng=-109.55, lat=41.16, zoom=7) %>%  # Set size of window
  addProviderTiles("Hydda.Base") %>% #Basemap
  addPolygons(data=ucrb, col="pink") %>% #add the basin polygon
  addPolylines(data=Rivers, weight=2, popup="This is a river") %>% #pops up when you click on streamflow lines
  addCircleMarkers(lng=samp[,2], lat=samp[,3], radius=5, popup=paste("Hi! This is site",samp[,1], "<br>", "coordinates:", round(samp[,2], 2), ", ", round(samp[,3], 2)) )

ucrbmap <- leaflet(data=samp[,2:3]) %>%
  setView(lng=-109.55, lat=41.16, zoom=7) %>%  # Set size of window
  addProviderTiles("Hydda.Base") %>% #Basemap
  addPolygons(data=ucrb, col="pink") %>% #add the basin polygon
  addPolylines(data=Rivers, weight=2, popup="This is a river") %>% #pops up when you click on streamflow lines
  addCircleMarkers(lng=samp[,2], lat=samp[,3], radius=5, popup=paste("Hi! This is site",samp[,1], "<br>", "coordinates:", round(samp[,2], 2), ", ", round(samp[,3], 2)) )

saveWidget(ucrbmap, "ucrbmap.html")
                   