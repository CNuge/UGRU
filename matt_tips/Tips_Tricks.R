##############################
## tips and tricks r session
##
## Matt Brachmann (PhDMattyB)
##
## 2019-01-23
##
##############################

## Need to set your working directory
## Simon showed me you can tab complete your working directory
## This is the best thing ever
setwd()

library(tidyverse)
library(wesanderson)
library(janitor)

theme_set(theme_bw())
library(cowplot)

## Other packages we need

## the package devtools is a good package to get and install packages
## That are not on CRAN

## install.package('devtools', dependencies = T)
## library(devtools)
## install.github("thomasp85/patchwork")
## install.github() installs packages from github repositories
## This should work to get the patchwork package installed
 
## If you cannot get patchwork installed:
## Cam Nugent showed me the package cowplot, which is a good alternative
## to patchwork. It's on CRAN. 

#install.packages('cowplot')


## install.package('janitor', dependencies = T)
library(janitor) ## load the package

## Check out the data we're using. 
## mtcars is a free and publically available dataset
head(mtcars)
str(mtcars)

# Two functions that help out so much as rename and arrange
cars = mtcars %>% ## pipe the data to the functions saves time later on, don't have to specify the data for every function
  as_tibble() %>%  ## I've grown to love tibbles, so we'll make the dataset one
  arrange(hp) %>% ## Sort the dataset by number of amount of horse power 
  rename(`STALLION POWER` = hp) %>% ## change the name hp (horse power) to something better
  mutate(cyl = as.factor(cyl)) %>% # changes column to a factor
  clean_names('screaming_snake') ## makes all of the name styles uniform
  
str(cars) ## Double check everything is how we want it

cars %>% ## pipe data to group_by to group data by cylinder
  group_by(CYL) %>% 
  do(model = lm(MPG ~ STALLION_POWER, data = cars)) %>% 
  ## The do() function is a neat way to link base functions to 
  ## dplyr functions. For example, running a linear model
  broom::tidy(model) ## the tidy functions within the broom package
  ## This is a great way to visualize the results of the linear model


## graph these relationships

## graph the relationship between miles per gallon and horse power
g1 = ggplot(data = cars, aes(x = STALLION_POWER, y = MPG))+
  geom_point(aes(col = CYL))+
  geom_smooth(method = 'lm', aes(col = CYL))+
  scale_color_manual(values = wes_palette('Darjeeling1',
                                          type = 'continuous',
                                          n = 6))+
  labs(x = 'Horse power', y = 'Miles per gallon')+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = 'none')

## violin plot of the horse power for cylinder
g2 = ggplot(data = cars, aes(x = CYL, y = STALLION_POWER))+
  geom_violin(aes(col = CYL, fill = CYL))+
  scale_color_manual(values = wes_palette('Darjeeling1',
                                          type = 'continuous',
                                          n = 6))+
  scale_fill_manual(values = wes_palette('Darjeeling1',
                                         type = 'continuous',
                                         n = 6))+
  labs(x = 'Cylinder', y = 'Horse power')+
  theme(panel.grid.major = element_blank(),
  panel.grid.minor = element_blank())


plot_grid(g1,g2,ncol=2)

plot_grid(g1,g2,nrow=2)



#organization idea.
#preface all dataframe variables with df
#all lists with ls and all vectors with v
#that way when you call
ls()
# you can then see all the dataframes right next to one another.






