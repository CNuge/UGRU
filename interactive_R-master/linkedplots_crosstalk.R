#install.packages("crosstalk")
#devtools::install_github("jcheng5/d3scatter")

library(crosstalk)
library(leaflet)
library(plotly)
library(htmlwidgets)
library(d3scatter)

setwd("~/guelph/teaching/interactive_R/")

whs.pca <- read.csv("latlon_whs_pca.csv")
head(whs.pca)

shared.whs <- SharedData$new(whs.pca)


map.pca <- bscols(
  leaflet(shared.whs) %>%
    setView(lng=-109.55, lat=40.8, zoom=6) %>%  # Set size of window
    addProviderTiles("Hydda.Base") %>% #Basemap
    addPolygons(data=ucrb, col="pink") %>% #add the basin polygon
    addPolylines(data=Rivers, weight=2, popup="This is a river") %>% #pops up when you click on streamflow lines
    addCircleMarkers(radius=2),
  d3scatter(shared.whs, ~PC1, ~PC2, ~factor(basin), x_lim=c(-1.5, 1.5), width = "100%", height = 400)
)

#you can highlight things in the PCA on the right and the points corresponding on
#the map will be highlighted
map.pca

saveWidget(map.pca, "map_pca.html")

