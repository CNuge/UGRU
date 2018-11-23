library(shiny)
library(tidyverse)


titanic = as.data.frame(Titanic)

#this is the options the user sees
ui = fluidPage(
	fluidRow(column = 12, "titanic exploration", align = 'center'), #this adds a title or text
	#fluid row is the easiest way to split the code up, you can also use panels
	fluidRow(
	column(6,
			radioButtons(inputId = 'graph_type',
					label = 'Select graph type',
					choices = c('bar', 'scatterplot')),
        	selectInput("x_value", 
        				"Please select the variable to plot by",
        				c("Class", "Sex", "Age"))
			)
		),
	 column(6,
           plotOutput("plot")
          )
	)

server = function(input, output){

}


shinyApp(ui = ui, server = server)