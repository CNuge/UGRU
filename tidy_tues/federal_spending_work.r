library(tidyverse)
library(reshape2)
library(RCurl)
library(ggthemes)


federal_git = getURL('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-02-12/energy_spending.csv')
fed_df = read_csv(federal_git)

names(fed_df)

fed_df$department[237] == "High-Energy Physics*"
fed_df$year
fed_df$energy_spending


spend_plot = ggplot(fed_df , aes(x= year, y = energy_spending, colour = department))+
			geom_point()


spend_plot