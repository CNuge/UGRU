library(aphid)
library(coil)
library(tidyverse)

library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Source Code Pro")
font_add_google("Anton")
font_add_google("Dancing Script")
## Automatically use showtext to render text for future devices
showtext_auto()

#install.packages("hexSticker")
library(hexSticker)


sticker(~plot(cars, cex=.5, cex.axis=.5, mgp=c(0,.3,0), xlab="", ylab=""),
        package="hexSticker", p_size=20, s_x=1, s_y=1, s_width=1, s_height=1,
        filename="baseplot.png")



#img_example = "spring.png"
gryph = "rsz_guelph2.png"
sticker(gryph, package="UGRU", p_size=23,  s_x=1, s_y=1, s_width=.1, s_height=.1,
        p_color = "yellow",
        h_fill = "red", h_color ="black" ,
        p_family= "Anton",
        filename = "UGRU_logo.png")


##################
#

x = aphid::plot.PHMM(nt_PHMM, from = 653, to = 657)



# coil with vaporwave look

logo_plt = ~ plot(cars, cex=.5, cex.axis=.5, mgp=c(0,.3,0), xlab="a", ylab="") + theme_minimal()


logo_plt


mtcars2 <- within(mtcars, {
        vs <- factor(vs, labels = c("V-shaped", "Straight"))
        am <- factor(am, labels = c("Automatic", "Manual"))
        cyl  <- factor(cyl)
        gear <- factor(gear)
})


p1 <- ggplot(mtcars2) +
        geom_point(aes(x = wt, y = mpg, colour = gear)) +
        labs(title = "Fuel economy declines as weight increases",
             subtitle = "(1973-74)",
             caption = "Data from the 1974 Motor Trend US magazine.",
             tag = "Figure 1",
             x = "Weight (1000 lbs)",
             y = "Fuel economy (mpg)",
             colour = "Gears")

#######
# make a single dot - change colour to that of the middle of the hex
x =  NULL
p1 <- ggplot(x) +
        geom_point(aes(x = 0, y = 0),color='orchid1') +
        labs() + theme_void()
p1

#vaporwave coil with no image
sticker(p1, package="coil", p_size=50, s_x=.8, s_y=.6, s_width=1.4, s_height=1.2,
        h_size = 7, #width of border
        p_color = "turquoise2", #colour of name
        h_fill = "orchid1", # colour of middle of hex
        h_color ="springgreen2", # colour of border
        spotlight = TRUE, # a highlight on the hex to shade colours
        l_x = 1.3, # spotlight, x axis
        l_y = .7, # spotlight, y axis
        l_width = 2, # width of spotlight
        l_height = 2, # height of spotlight
        l_alpha  = .5 , # how strong is the spotlight
        p_family = "Dancing Script",
        filename = "coil_logo_vw.png")





######
# more subdued aesthetic for coil

p2 = "slinky-png-43487.png"

sticker(p2, package="coil", p_size=48, 
        p_x = 1, p_y = .75 , #name location
        s_x=1, s_y= 1.33, s_width = 0.5, s_height=0.5, #subplot info, i.e. where the image goes
        h_size = 4, #width of border
        p_color = "black", #colour of name
        h_fill = "darkslategray1", # colour of middle of hex
        h_color ="darkslategray4", # colour of border
        p_family = "Source Code Pro",
        filename = "coil_logo_std.png")

x =  NULL
p3 <- ggplot(x) +
        geom_point(aes(x = 0, y = 0),color='darkslategray1') +
        labs() + theme_void()

sticker(p3, package="", p_size=48, 
        p_x = 1, p_y = .75 , #name location
        s_x=1, s_y= 1.33, s_width = 0.5, s_height=0.5, #subplot info, i.e. where the image goes
        h_size = 4, #width of border
        p_color = "black", #colour of name
        h_fill = "darkslategray1", # colour of middle of hex
        h_color ="darkslategray4", # colour of border
        p_family = "Source Code Pro",
        filename = "logo_empty.png")


#rayshader for 2 and 3d plotting


