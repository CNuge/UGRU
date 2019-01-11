## Into the Tidyverse: Data manipulation and plotting with dplyr and ggplot2
## Script by Matt Brachmann
## We are using a free data set from Kaggle to analyze 
## The prices of Avocados in the USA

# install.packages('janitor')

library(tidyverse)  
library(wesanderson) 	## Makes plots coloured as Wes Anderson movie themes
#library(patchwork) 		## Allows you to make really nice plots
library(janitor) 	 	## Makes column names a uniform format


# note below matt uses clean_names from the janitor package
# this lets you standardize the capitalization/spacing in names


data = read_csv('avocado.csv') %>%  ## Read in the data. This data was provided by Kaggle
  select(-X1) %>%   ## Remove this coloumn as it repeats the index
  clean_names('screaming_snake') %>%  ## Makes all of the column names a uniform format
  ## Column names are now caps locked and aggressive 
  separate(col = DATE, into = c('YEAR', 'MONTH', 'DAY'),  ## The date is all together and we don't want that
  ## we want the dates separated into year, month, and day 
           sep = '-', remove = FALSE) %>%  ## the sep argument tells the function what to split the data on
  select(-DATE, -X4046, -X4225, -X4770) %>% ## Get rid of the trash columns
  filter(REGION == 'TotalUS') %>%  ## We only want the Avocado prices for the total USA not state by state
  mutate(MONTHNAME = as.factor(case_when(  ## mutate lets you create a column
    MONTH == '01' ~ 'January',    			## we want to convert the month from a number to an actual word
    MONTH == '02' ~ 'Febuary',				## case_when is the best thing in the world, Joey showed it to me
    MONTH == '03' ~ 'March',
    MONTH == '04' ~ 'April',
    MONTH == '05' ~ 'May',
    MONTH == '06' ~ 'June',
    MONTH == '07' ~ 'July',
    MONTH == '08' ~ 'August',
    MONTH == '09' ~ 'September',
    MONTH == '10' ~ 'October',
    MONTH == '11' ~ 'November',
    MONTH == '12' ~ 'December'))) %>% 
  rename(NUMSMALLBAGS = SMALL_BAGS,  ## Rename these coloumns from trash names to actual names
         NUMLARGEBAGS = LARGE_BAGS,
         NUMEXTRALGBAGS = X_LARGE_BAGS)

colnames(data)
data
max(data$AVERAGE_PRICE)


data[data$AVERAGE_PRICE == max(data$AVERAGE_PRICE) ,]
theme_set(theme_bw())  ## Sets your plotting theme ahead of time. This just saves some time. 


#this lets you switch everything to lowercase
sm_data = clean_names(data, 'snake')
sm_data


## SET YOUR THEME TO WHATEVER YOU WANT!

## BIG PLOTTING SIDE NOTE!
## specify aes() anytime you want to link the plot to your data. 
## in the code below, we use aes() to refer to what the x and y variables are and the point colors
## We do not specify anything for the lines however, we could plot individual lines for each avocado type
## We can do this: geom_smooth(method = 'lm', aes(col = TYPE))


## Plotting a normal scatter plot with a line
p1 = ggplot(data = data, aes(x = TOTAL_VOLUME, y = AVERAGE_PRICE)) +  ## First step in becoming a ggplot2 master, set the data up. 
  geom_point(aes(col = TYPE)) + ## tells ggplot that you're plotting actual points... this makes the dots appear
  geom_smooth(method = 'lm', col = 'black') + ## This makes the lines appear, lets us plot a linear relationship
  labs(x = 'Total Volume', y = 'Average price of avocados') + ## the labs function changes the x and y labels
  scale_color_manual(values = wes_palette('Darjeeling2', n = 5,  ## This lets us scale the colours to whatever we want
                                          type = 'continuous')) + ## and of course we want plots themed as Wes Anderson movies
  theme(panel.grid.major = element_blank(), ## Get the trash gridlines out of here, gets rid of major grid lines
        panel.grid.minor = element_blank(), ## Gets rid of the minor grid lines
        axis.text = element_text(size = 6)) ## Increases the text size
p1


#note the italics in the plot below
mon_data = data.frame(MONTH= data$MONTH, MONTHNAME = data$MONTHNAME)
mon_data = unique(order(mon_data$MONTH))


mon_data$MONTHNAME = factor(mon_data$MONTHNAME, )

## Making fancy violin plots
## These are the best plots ever and should be used constantly (my opinion)
p2 = ggplot(data = data, aes(x = MONTHNAME, y = AVERAGE_PRICE)) + ## Set this up the same way as in the plot above
  geom_violin(aes(col = TYPE, fill = TYPE)) + ## Specifying that we want a violin plot
  ## note that to make the colors work we need to speify both col and fill
  theme(axis.text.x = ## we need to make the x axis text not terrible
          element_text(size  = 6, ## changes size
                       angle = 45, ## rotates it on a 45 degree angle
                       hjust = 1, ## adjusts it horizontally
                       vjust = 1), ## adjusts it vertically
        axis.text.y = element_text(size = 6)) + ## change the size of the y axis text to match the x axis
  labs(x = "Month", y = "Average price ('Murica Dollars)") + ## Axis labels
  ylab(expression(paste("Average price ", italic("'Murica Dollars"))))+
  scale_color_manual(values = wes_palette('Darjeeling1', n = 5,  ## Specifies which Wes Anderson palette to use
                                          type = 'continuous')) +
  scale_fill_manual(values = wes_palette('Darjeeling1', n = 5,  ## Remember to always specify the fill
  	## This fills the plot with color
                                         type = 'continuous')) +
  theme(panel.grid.major = element_blank(),  ## Get rid of major panel grid lines
        panel.grid.minor = element_blank())  ## Get rid of the minor panel grid lines
  
p1
p2  ## This syntax is a part of the patchwork function
## patchwork allows us to link plots and plot them all in the same window
## I personally find this the best way to format plots into a single picture
## Joey showed me this package
