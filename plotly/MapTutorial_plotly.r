# Plotly Map tutorial in R with BOLD data 
# Matt Orton

# Packages you need
# install.packages("plotly")
library(plotly)
# install.packages("readr")
library(readr)


# Downloading directly from BOLD API

#  Some tips for using the BOLD API since this is what is used to grab 
# the relevant data needed from BOLD:
# To see details on how to use the BOLD API, 
# go to http://www.boldsystems.org/index.php/resources/api?type=webservices
# We can add additional restrictions to the url, for example 
# &instituiton=Biodiversity Institute of Ontario|York University or 
# &marker=COI-5P if you want to specifiy an institution.
# geo=all in the url means global but geo can be geo=Canada, for example.
# We can also use | modifier in the url. For example, &geo=Canada|Alaska 
# would give data for both Canada and Alaska, 
# or taxon=Aves|Reptilia would yield data for both Aves and Reptilia.

# The URL below is what is modified by the user and will determine the taxon, geographic region, 
# etc. Example: taxon=Aves$geo=all, see above in Guidelines and Tips for more
# information on how to use the BOLD API.

# Here I'm using cats cause I like cats
dfTestPublic <- read_tsv("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Felidae&geo=all&format=tsv")
dfTestPublic
# Some basic filtering of data

# Can use grep commonds to filter according to data columns you want
containCOI <- grep( "COI-5P", dfTestPublic$markercode)
containCOI

dfTestPublic <-dfTestPublic[containCOI,]
dfTestPublic

# Removing sequences with no coordinate data since we are mapping 
containLat <- grep( "[0-9]", dfTestPublic$lat)
dfTestPublic <-dfTestPublic[containLat,]

# Get rid of records without BIN since for mapping purposes, Im going to color code 
# according to BIN
noBIN <- which(is.na(dfTestPublic$bin_uri == TRUE))
dfTestPublic <- dfTestPublic[-noBIN,]

# Mapping with Plotly - can go here for more details on scattergeo maps:
# https://plot.ly/r/scatter-plots-on-maps/

# Can modify some of these map elements to customize the map
mapLayout <- list(
  resolution = 50, # Two choices either 100 (low resolution) or 50 (higher resolution)
  showland = TRUE,
  showlakes = TRUE,
  showcountries = TRUE,
  showocean = TRUE,
  countrywidth = 0.5,
  landcolor = toRGB("light grey"),
  lakecolor = toRGB("white"),
  oceancolor = toRGB("white"),
  projection = list(type = 'equirectangular'), # Check the plotly website for the various map options
  lonaxis = list(
    showgrid = TRUE,
    gridcolor = toRGB("gray40"),
    gridwidth = 0.5
  ),
  lataxis = list(
    showgrid = TRUE,
    gridcolor = toRGB("gray40"),
    gridwidth = 0.5
  )
)

# New dataframe column with data for hovering over points on the map.
# Can add more columns to hover if you want more detail on the map for each
# point on the map. 
# For instance here I have it so that when you hover over a point you can see the BIN but can specify other
# columns from the dataframe
dfTestPublic$hover <- 
  paste("BIN",dfTestPublic$bin_uri,
        sep = "<br>")


# This command will ensure the pairing results dataframe can be read by plotly.
attach(dfTestPublic)

# This command will show a scatterplot map organized by coordinate data and color coded by BIN

# Map with just points and Set1 qualitative color palette
# Note: for private datasets its Lat and Lon not lat and lon
p1 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # There are many that can be found on the plotly website: Set1,Set2 for qualitative colors
        # Can also do spectral for 
        text = hover, color = bin_uri, mode = "markers", colors = "Set1", 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) 


# Map with points and gradient color palette
p2 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # Doing spectral color palette for a gradient color palette
        text = hover, color = bin_uri, mode = "markers", colors = "Spectral", 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) 

# Map with points and lines and custom colors (hex codes)

# If using custom colors and plotting according to BIN - first determine how many colors you need
numColors = length(unique(dfTestPublic$bin_uri))

# For cats (Felidae) there are 8 BINs

p3 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # Here I used custom hex color codes so each BIN is a distinct color
        # you can go here for hex codes: https://www.colorcombos.com
        # choose the colors you like and then copy over the hex codes
        text = hover, color = bin_uri, mode = "markers+lines", colors = c("#005B9A","#F964FF","#74C2E1","#FFBD50","#C43939","#30CF40","#F1CF00","#00EAFF"), 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) # can do legend  either horizontal or vertical 'v'

# plot the maps by running p1, p2 and p3
# ***You will need to click on the icon in the viewer (bottom right corner) that
# says "show in new window" (little box with arrow beside the refresh icon). 
# Unfortunately, this does not show the actual map directly in Rstudio.
# The map will appear in a web browser window, though you don't have to be 
# online to do this.***

p1

p2

p3

# Linear regression plot (not with this data)
# Just uncomment the commands below and try with your dataframe of choice
# I specify hex colors here but can be easily changed


# plotLM <- plot_ly(
#  df, x = ~dfColumn1) %>%
#  add_markers(y = ~dfColumn2, color = ~dfColumn3, colors = c("#009e73", "#D55E00", "#0072B2", "#CC79A7","#7F7F7F")) %>% 
#  add_lines(x = ~dfColumn1, y = fitted(lm(dfColumn2 ~ 0 + dfColumn1, data = df)))

# For more customization - can create a plotly account and upload your map data there
# You can customize it more on the plotly website

# For uploading to plotly server for online viewing of map.

# You will first have to create a plotly account to do this:
# https://plot.ly/

# Note there is a limit of one plot for the free version of the Plotly account,
# and the plot is public, meaning other people on plotly can view the plot, 
# though it is not easily found on the website without the direct link.

# To obtain additional plots on the server, you have to pay for a package.

# Run these commands for uploading user details, enter username and API key in 
# the empty quotations to run commands:
# (obtained from making an account and in settings of account details) 

# Sys.setenv("plotly_username"="") 
# Sys.setenv("plotly_api_key"="")

# Run this command for posting of map to plotly server 
# must specify your map variable name and filename (what you want the map to be called)
# p represents the plot variable you want to post

# plotly_POST(p, filename = "")




