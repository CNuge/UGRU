# app3.R
# Example with shinyjs package
# Shinyjs allows you to perform advanced ui functions easily like toggling ui elements on/off between a hidden and viewable state in the ui, 
# reseting parameters in the ui and setting alerts based on user input
# Shinyjs can also modify underlying html code to modify things like font-size with the shinyjs::inlineCSS() argument

# install.packages("shinyjs")
library(shinyjs)

ui = fluidPage(
  # Whenever using shinyjs, you need this first argument - shinyjs::useShinyjs(), right below fluidPage
  shinyjs::useShinyjs(),
  shinyjs::inlineCSS(list(.big = "font-size: 2em")),
  
  # instead of defining side and main panels, you can also divide up your ui into discrete elements with div but make sure you assign unique ids to each unique ui element you create
  # so they can be easily referenced back to
  div(id = "myapp",
      
      #h1, h2, h3 etc. refer to header font subtypes, the header will appear at the top of your ui
      h2("shinyjs demo"),
      # checkboxInput specifies a radiobutton that can be toggled on or off, or TRUE (meaning on), FALSE (meaning off)
      checkboxInput("big", "Bigger text", FALSE),
      # textInput specifies a blank text box where a user can input character or numerical based data
      textInput("name", "Name", ""),
      
      # Shinyjs can also toggle ui elements between hidden and viewable states
      a(id = "toggleAdvanced", "Show/hide advanced info", href = "#"),
      # You first need this shinyjs::hidden argument
      shinyjs::hidden(
        div(id = "advanced",
            numericInput("age", "Age", 31),
            textInput("company", "Company", "Aperture Science")
        )
      ),
      
      # you can also add timestamps that can be refreshed in a shiny ui 
      p("Timestamp: ",
        span(id = "time", date()),
        a(id = "update", "Update", href = "#")
      ),
      # action buttons are ui elements that are usually used to perform a submission action of some kind
      # like submission of an online form or resetting to default parameters on a form
      actionButton("submit", "Submit"),
      actionButton("reset", "Reset form")
  )
)

server = function(input, output) {
  # default observe state before any user actions are completed
  observe({
    shinyjs::toggleState("submit", !is.null(input$name) && input$name != "")
  })
  
  # Onclick actions can be specified with shinyjs, 
  # here toggle and update functions are used to hide a ui element or refresh the timestamp in the ui
  shinyjs::onclick("toggleAdvanced",
                   shinyjs::toggle(id = "advanced", anim = TRUE))    
  
  shinyjs::onclick("update", shinyjs::html("time", date()))
  
  # this observe the input of the "big" radio button and returns larger font if clicked via input$big
  observe({
    shinyjs::toggleClass("myapp", "big", input$big)
  })
  
  # To customize our alert we can create an empty reactive variable first
  alert <- reactiveValues(customResponse=NULL)
  
  # We can then observe the name inputted by the user (stored in input$name) and use it in a customized alert expression
  observeEvent(input$name, {
    alert$customResponse <- paste("Thank you for your submission ", input$name, sep="")
  })
  
  # How to set up an alert on observation of an input using the observeEvent argument
  # This alert can itself be customized
  observeEvent(input$submit, {
    shinyjs::alert(alert$customResponse)
  })
  
  # how to reset interface settings based on observation of an input using the observeEvent argument
  observeEvent(input$reset, {
    shinyjs::reset("myapp")
  })    
}

shinyApp(ui, server)