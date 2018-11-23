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
           plotOutput("plot") #this relied on the name defined in the renderPlot within the server function
          )
	)

server = function(input, output){
  #the render plot here says to build a new plot any time a value is changed in the ui
  output$plot=renderPlot({
   if(input$graph_type == "bar"){
   	# note the aes_string below, this lets it take the input in string format
   	# which is just how the thing is coded here, you can have numbers etc passed from one
   	# to the other
     ggplot(data = titanic, aes_string(x=input$x_value, y="Freq", fill = "Survived"))+
       geom_bar(stat="identity")+
       ggtitle("Investigating the survival rate of Titanic")
   }
   else
     {
     ggplot(data = titanic, aes_string(x=input$x_value, y="Freq", colour = "Survived"))+
       geom_point()+
       ggtitle("Investigating the survival rate of Titanic")
   }
  })

}


shinyApp(ui = ui, server = server)