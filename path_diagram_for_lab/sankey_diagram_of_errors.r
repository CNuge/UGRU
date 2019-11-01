
#install the library

install.packages('networkD3')
library(networkD3)

#original example I found

# Load energy projection data
URL <- "https://cdn.rawgit.com/christophergandrud/networkD3/master/JSONdata/energy.json"
Energy <- jsonlite::fromJSON(URL)

# 2 data frames: a 'links' data frame with 3 columns (from, to, value)
# and a 'nodes' data frame that gives the name of each node.

#code to plot it
sankeyNetwork(Links = Energy$links, Nodes = Energy$nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "name",
              units = "TWh", fontSize = 12, nodeWidth = 30)


#I built these two dataframes from my own data
nodes = read.csv('data/sankey_nodes.csv', stringsAsFactors = FALSE)
links = read.csv('data/sankey_links.csv', stringsAsFactors = FALSE)

#then pass the two dataframes to the program
sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
              Target = "target", Value = "value", NodeID = "names",
              units = "Number of Sequences", fontSize = 12)
#in Rstudio you can output the plot as either interactive html, or a plain pdf
