library(tidyverse)
library(reshape2)
library(RCurl)
library(ggthemes)


cheese_git = getURL('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-01-29/clean_cheese.csv')
df_cheese_wide = read_csv(cheese_git)

names(df_cheese_wide)

keep_cols = c('Year','Cheddar','American Other','Mozzarella','Italian other','Swiss','Brick','Muenster','Cream and Neufchatel','Blue','Other Dairy Cheese','Processed Cheese')



#df_cheese_long = melt(df_cheese_wide[keep_cols], 
#						id.vars=c("Year"),
#						value.name = 'amount',
#						)
# names(df_cheese_long) = c('year', 'cheese_type', 'amount')

# the above is the reshape version of the dplyr below
# the use of the -Year is a little odd at first but it is a one liner.
df_cheese_long = gather(df_cheese_wide[keep_cols],'cheese_type', 'amount', -Year)


plot_cheese = ggplot(df_cheese_long, aes(x = Year, y = amount, color = cheese_type)) + 
  geom_point() + 
  geom_line()+
  labs(x = 'Year',
  		y = 'Amount consumed (lbs)',
  		title = 'US average yearly cheese consumption per person, by cheese type')+ 
  theme_minimal() +
  theme_light() +
  theme(panel.grid.major = element_blank(),
		 panel.grid.minor = element_blank(),
		 )

plot_cheese