setwd("~/Desktop")


library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
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
library(aphid)
library(coil)
library(tidyverse)

x = aphid::plot.PHMM(nt_PHMM, from = 653, to = 657)



logo_plt = ~plot(cars, cex=.5, cex.axis=.5, mgp=c(0,.3,0), xlab="", ylab="")

sticker(logo_plt, package="coil", p_size=50, s_x=.8, s_y=.6, s_width=1.4, s_height=1.2,
        h_size = 7, #width of border
        p_color = "turquoise2", #colour of name
        h_fill = "orchid1", # colour of middle of hex
        h_color ="springgreen2", # colour of border
        spotlight = TRUE,
        p_family = "Dancing Script",
        filename = "coil_logo.png")




#rayshader for 2 and 3d plotting


