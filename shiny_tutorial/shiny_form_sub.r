

# goal:
# build a webpage where a user can fill out a questionaire and submit results

# the results are saved to a dataframe and I can log in and download them


library(shiny)
library(tidyverse)


ui = fluidPage(

	
	q_list = c(1,2,3)
	q = sample(q_list, 1)



  fluidRow(
	column(10,
	h1("The Bridgekeeper from scene twenty-four", align = "left", style = "color:blue"),
	h4("Stop! Who approacheth the Bridge of Death must answer me these questions three, ere the other side he see.", align = "left")
	
	textInput("text", label = h3(
		"What is your name"
		), value = ""),
	  

	textInput("text", label = h3(
		"What is your quest?"
		), value = ""),


	textInput("text", label = h3(
		"What is the capital of Assyria?"
		), value = "")
	
	textInput("text", label = h3(
		"What is your favorite color?"
		), value = "")

	

	# Copy the line below to make a slider bar 
	sliderInput("slider1", label = h3(
	  	"What is the air speed velocity of an unladen swallow? (kph)"
	  	), min = 0, 
		max = 100, value = 50)
	)
	),
  	fluidRow(
	submitButton(text = "Submit!", icon = NULL, width = NULL)
	)
)


server = function(input, output){


  # You can access the value of the widget with input$slider1, e.g.
  output$value <- renderPrint({ input$slider1 })

}


shinyApp(ui = ui, server = server)