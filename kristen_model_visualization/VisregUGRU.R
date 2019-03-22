#########################
## Created by Kristen Bill 
# March 11 2019 
##
# GGPLOT & Visreg -> visualizing mixed effect models in R 
# 
#########################

# Load packages - ggplot is part of tidyverse
library(tidyverse)
#library(magrittr) # for back-piping %<>%
library(lme4)
#this import was missing
library(nlme)
#install.packages('visreg')
library(visreg)

Soils = read_csv(file = "SoilsUGRU.csv")
Soils = column_to_rownames(Soils, var ='X1')
head(Soils)

SoilsUGRU = select(Soils, timesincefire, avg.org, cubeorg, Moisture, ecoregion3, cubePima, burn.name, site)
#Download the file

#my model for looking at Peat layer thickness recovery over time: 
MDominance = lme(cubeorg ~ timesincefire * Moisture + ecoregion3  + cubePima , random = ~1|burn.name/site, method = "ML",  data = SoilsUGRU, na.action = na.omit)
summary(MDominance)
anova(MDominance)

##GGPLOT: 
# 
ggplot(Soils, aes(timesincefire, avg.org, colour = Moisture)) + 
  geom_point( size=2) +
  geom_smooth(method= "lm", fill= "grey90", level= 0.95)+ 
  theme_classic() + 
  theme(strip.background = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), text = element_text(size = 14), legend.position = c(0.8,0.2)) + 
  labs( x= "Time-since-fire (yrs)", y= "Peat layer thickness* (cm)")  + 
  scale_colour_brewer(palette= "Dark2", name= "Drainage class")

# with the transformed data 
ggplot(Soils, aes(timesincefire, cubeorg, colour = Moisture)) + 
  geom_point( size=2) +
  geom_smooth(method= "lm", fill= "grey90", level= 0.95)+ 
  theme_classic() + 
  theme(strip.background = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), text = element_text(size = 14), legend.position = c(0.8,0.2)) + 
  labs( x= "Time-since-fire (yrs)", y= "Peat layer thickness* (cm)")  + 
  scale_colour_brewer(palette= "Dark2", name= "Drainage class")


###Lets play with visreg

#this will display all the plots:
visreg(MDominance)

# if we want to only see one of the predictors:
visreg(MDominance, "timesincefire")

# I have an interaction within my model and so i need to account for this:
#but a warning sign appears that is quite important: 
visreg(MDominance, "timesincefire","Moisture")

visreg(MDominance, "timesincefire","Moisture", type = "conditional", gg = TRUE) 

visreg(MDominance, "timesincefire","Moisture", type = "conditional", gg = TRUE, partial = TRUE)
# as you can see that didnt change the slope or difference between factors 

#So what are conditional plots? 
#conditional plots depend on the specification of not only the predictor specified, but also of all the other terms in the model.
#By default, the other terms in the model are set to their median if the term is numeric or the most common category
visreg(MDominance, "timesincefire","Moisture", type = "conditional", gg = TRUE) 
visreg(MDominance, "timesincefire","Moisture", type = "contrast", gg = TRUE) 
##you'll notice that the slope  and differences in levels are the same BUT that the confidence intervals cgange because the uncertainity changes 

##Plots the model:

# If ’conditional’ is selected, the plot returned shows the value of the variable on the x-axis and the change in response on the y-axis, holding allother variables constant (by default, median for numeric variables and most common category for factors)
#overlay= TRUE 

#lets look at overlay: # also note the theme change to classic 
visreg(MDominance, "timesincefire","Moisture", 
        type = "conditional", 
        gg = TRUE, 
        points= list(col= "black", size = 1.5), 
        overlay= FALSE, partial = TRUE, 
        xlab= "Time-since-fire (yrs)", 
        ylab = "Peat Layer thickness (cm)") + theme_classic()

visreg(MDominance, "timesincefire","Moisture", type = "conditional", gg = TRUE, points= list(col= "black", size = 1.5), overlay= TRUE,  partial = TRUE, xlab= "Time-since-fire (yrs)", ylab = "Peat Layer thickness (cm)") + theme_classic()
coef(MDominance)
# those are both conditional plots 


# here are contrast plots:
visreg(MDominance, 
  "timesincefire",
  "Moisture", 
  type = "contrast", 
  gg = TRUE, 
  points= list(col= "black", size = 1.5), 
  overlay= TRUE, 
  partial = TRUE, 
  xlab= "Time-since-fire (yrs)", 
  ylab = "Peat Layer thickness (cm)") + theme_classic()

coef(MDominance)

#okay but we have transformations and we need to account for this?

visreg(MDominance, "ecoregion3", 
  "Moisture", 
  type = "contrast", 
  gg = TRUE, 
  points= list(col= "black", size = 1.5),
  overlay= TRUE,  
  trans= exp, 
  partial = TRUE, 
  xlab= "Ecozones", 
  ylab = "Peat Layer thickness (cm)") + theme_classic()

visreg(MDominance, "ecoregion3", type = "conditional",  gg = TRUE, points= list(col= "black", size = 1.5),overlay= TRUE,  trans= exp, partial = TRUE,xlab= "Ecozones", ylab = "Peat Layer thickness (cm)") + theme_classic()

###tranformations: 
visreg(MDominance, "cubePiba", type = "conditional",trans= exp, partial = TRUE, gg = TRUE, points= list(col= "black", size = 1.5), ylab = "Peatlayer thickness (cm)") + theme_classic()
