

# goal:
# uild a webpage where a user can fill out a questionnaire and submit results.
# the results are saved to a dataframe and I can log in and download them as a csv


library(shiny)
library(tidyverse)
library(DT)

one_of = function(){
	#get page to present 1 of these three questions at random
	q_list = c(1,2,3)
	q = sample(q_list, 1)

	if( q == 1 ){
		return(textInput("colour", label = h3(
			"What is your favorite color?"
			), value = ""))		
	}else if (q == 2){
		return(textInput("assyria", label = h3(
			"What is the capital of Assyria?"
			), value = ""))
	}else if (q == 3){
		return(sliderInput("swallow", label = h3(
		  	"What is the air speed velocity of an unladen swallow? (kph)"
		  	), min = 0, 
			max = 100, value = 50))
	}	
}

#note the below function is needed due to not all the questions being filled out
#but its also good practice for dealing with non filled out field on forms

build_row = function(input){
	#take the input from the ui and aggregate it into a dataframe
	new_data = list()
	cols = c('name', 'quest', 'colour', 'assyria', 'swallow')

	for(col in cols){
		if( col %in% names(input)){
			new_data[col] = input[col]
		} else{
			new_data[col] = NA
		}
	}
	return(data.frame(new_data))
}

add_data = function(data, all_data) {
	#take the new row of data and append it to the responses df
	#note the <<- is a global scope variable assign, outside of function
	return( rbind(all_data, data))
}

load_data = function() {
	if (exists("all_data")) {
		return(all_data)
	}
}

#the webpage input fields that the user sees
ui = fluidPage(
	fluidRow(
		column(6,
		h1("Hark! The Bridgekeeper from scene twenty-four.", align = "left", style = "color:blue"),
		h2("Stop! Who approacheth the Bridge of Death must answer me these questions three, ere the other side he see.", align = "left"),
		
		textInput("name", label = h3("What is your name?"), value = ""),
		
		textInput("quest", label = h3("What is your quest?"), value = ""),

		one_of(),

		actionButton("submit", "Submit!")
		)
	)
)


server = function(input, output){
	#load previous responses	
	all_data = load_data()

	#take the user input and build up the row
	#this is a reactive function... i.e. responds to user input
	new_row = reactive({build_row(input)})

	#save the data when the submit button is hit
	#takes the response we've been collecting and adds to the all_data
	#all_data = observeEvent(input$submit, {
	#	add_data(new_row)
	#})


	output$all_data = renderDataTable({input$submit
		add_data(new_row, all_data)})

	output$show_table = DT::renderDataTable({input$submit
		add_data(new_row, all_data)})
}


shinyApp(ui = ui, server = server)


