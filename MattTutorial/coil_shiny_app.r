library(coil)
library(shiny)


# to improve this

# 1. make it accept a file in tsv format with cols 'name', 'sequence'

# 2. batch process the sequences 

# 3. 

# make it have an output download option

# host it on your website

#################
# server side
#################
server <- function(input, output) {

	#note all the code to render the table has to go within the render table function.	
	output$view <- renderTable({
		coil_obj = coi5p_pipe(input$inseq)

		coil_out = flatten_coi5p(list(coil_obj))
		coil_out
	})
}


#################
# user interface
#################
ui <- fluidPage(
		sidebarLayout(
			sidebarPanel(
			# Important to note that these min, max and value variables can themselves be reactive variables but more on that later
			textInput(inputId = "inseq",
						label = "Input DNA sequence:",
						value = "ctctacttgatttttggtgcatgagcaggaatagttggaatagctttaagtttactaattcgcgctgaactaggtcaacccggatctcttttaggggatgatcagatttataatgtgatcgtaaccgcccatgcctttgtaataatcttttttatggttatacctgtaataattggtggctttggcaattgacttgttcctttaataattggtgcaccagatatagcattccctcgaataaataatataagtttctggcttcttcctccttcgttcttacttctcctggcctccgcaggagtagaagctggagcaggaaccggatgaactgtatatcctcctttagcaggtaatttagcacatgctggcccctctgttgatttagccatcttttcccttcatttggccggtatctcatcaattttagcctctattaattttattacaactattattaatataaaacccccaactatttctcaatatcaaacaccattatttgtttgatctattcttatcaccactgttcttctactccttgctctccctgttcttgcagccggaattacaatattattaacagaccgcaacctcaacactacattctttgaccccgcagggggaggggacccaattctctatcaacactta"),
			),
		mainPanel(

			# Output: HTML table with requested number of observations 
			tableOutput("view") 
	    )
	)
)



#################
# Create Shiny app 
#################
shinyApp(ui, server)
