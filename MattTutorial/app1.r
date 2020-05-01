# install.packages("shiny")
library(shiny)

# Divided into two major code segments: server side code and ui side code

# Server side code - the server side code is where your program actually does stuff, ex: performs operations, uses functions etc.
server <- function(input, output) {
  # to show a simple plot in the ui, you have to create a "reactive expression" and then within that expression, create a plot as you normally would within R 
  # within the shiny function renderPlot 
  output$distPlot <- renderPlot({
    hist(rnorm(input$obs), col = 'darkgray', border = 'white')
  })
}

# ui - ui side is mostly aesthetic and sets the visual layout for your shiny app

# fluidpage is an argument that can be used to intialize your ui
# fluidpages can be sub-divided into different sections for your ui called panels (side panels and main panels)
# side panels usually are where parameter changes are made in the form of drop-down menus, radio buttons and sliders whearas the main panel is usually where you show
# an output of some kind, be it a plot or map or table of some kind
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      # Important to note that these min, max and value variables can themselves be reactive variables but more on that later
      sliderInput("obs", "Number of observations:", min = 10, max = 500, value = 100)
    ),
    # Our mainpanel is where we will have the plot output
    mainPanel(plotOutput("distPlot"))
  )
)

shinyApp(ui, server)