# Matt Orton Shiny Tutorial Mar 14 - A simple way to create highly interactive graphical user interfaces!
# install.packages("shiny")
library(shiny)

###################
# ***How to use this tutorial***

# Create an additional scripts and name them app1.R, app2.R etc

# Make sure you have installed the shiny package (this may require additional dependencies depending on 
# what version of R you have and what packages you have previously installed)

# Then for each app example (server, ui and shinyApp command together) copy and paste the code below, 
# you will see that instead of the run button for your code at the top of this window, you will
# have now have a "runApp" button instead that will allow you to run each app example

###################
# app1.R
# Basic example from shiny.Rstudio website
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

# Server side and ui side get combined to make a functional graphical user interface (GUI)
# Once you have both ui and serve side code elements, you just have to have this command:
shinyApp(ui, server)

##################
# app2.R
# More complex example with more reactive expressions from shiny.Rstudio website

# Define UI for dataset viewer app 
ui <- fluidPage(
  
  # App title
  titlePanel("Reactivity"),
  
  # Sidebar layout with input and output definitions 
  sidebarLayout(
    
    # Sidebar panel for inputs 
    sidebarPanel(
      
      # Input: Text for providing a caption 
      # Note: Changes made to the caption in the textInput control
      # are updated in the output area immediately as you type
      textInput(inputId = "caption",
                label = "Caption:",
                value = "Anything can go here for your title"),
      
      # Input: Selector for choosing dataset 
      selectInput(inputId = "dataset",
                  label = "Choose a dataset: (Changing the dataset will alter output in the main panel)",
                  choices = c("rock", "pressure", "cars")),
      
      # Input: Numeric entry for number of obs to view 
      numericInput(inputId = "obs",
                   label = "Number of observations to view:",
                   value = 10)
      
    ),
    
    # Main panel for displaying outputs 
    mainPanel(
      
      # Output: Formatted text for caption 
      h3(textOutput("caption", container = span)),
      
      # Output: Verbatim text for data summary
      verbatimTextOutput("summary"),
      
      # Output: HTML table with requested number of observations 
      tableOutput("view")
      
    )
  )
)

# Define server logic to summarize and view selected dataset 
server <- function(input, output) {
  
  # Return the requested dataset
  # By declaring datasetInput as a reactive expression we ensure
  # that:
  #
  # 1. It is only called when the inputs it depends on changes
  # 2. The computation and result are shared by all the callers,
  #    i.e. it only executes a single time
  datasetInput <- reactive({
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  })
  
  # Create caption ----
  # The output$caption is computed based on a reactive expression
  # that returns input$caption. When the user changes the
  # "caption" field:
  #
  # 1. This function is automatically called to recompute the output
  # 2. New caption is pushed back to the browser for re-display
  #
  # Note that because the data-oriented reactive expressions
  # below don't depend on input$caption, those expressions are
  # NOT called when input$caption changes
  output$caption <- renderText({
    input$caption
  })
  
  # Generate a summary of the dataset ----
  # The output$summary depends on the datasetInput reactive
  # expression, so will be re-executed whenever datasetInput is
  # invalidated, i.e. whenever the input$dataset changes
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # Show the first "n" observations ----
  # The output$view depends on both the databaseInput reactive
  # expression and input$obs, so it will be re-executed whenever
  # input$dataset or input$obs is changed
  output$view <- renderTable({
    head(datasetInput(), n = input$obs)
  })
  
}

# Create Shiny app 
shinyApp(ui, server)


##############
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
    alert$customResponse <- paste("Thank you for your submission ", input$name, "!", sep="")
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
###################
# app4.R 
# How to integrate plots via ggplot and plotly, dynamic file downloads and shinydashboard with tabset functionality
# install.packages("shinydashboard")
library(shinydashboard)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("plotly")
library(plotly)
# install.packages("data.table)
# data.table is just for fread function, dont really need
library(data.table)
# install.packages("scales")
# scales is just for one code element that uses monthweek date format
library(scales)

# For this tutorial im using a subset of ontario weather station data from Environment Canada I used in a more advanced 
# version of this app (may take a min or two to load if you want to take a look):
# https://mattorton.shinyapps.io/ontarioweatherapp/

# Some dataframe formating first (can ignore for the purposes of this tutorial)
ddata <- fread("EnvCanDataSubsetDaily.csv")
ddata$FullDate <- as.Date(ddata$FullDate)
ddata$StationId <- toupper(ddata$StationId)
colnames(ddata) <- make.unique(names(ddata))

wdata <- fread("EnvCanDataSubsetWeekly.csv")
wdata$StationId <- toupper(wdata$StationId)
colnames(wdata) <- make.unique(names(wdata))

# This tutorial will make use of shinydashboard, a package that will restructure the ui to look more professional and is generally
# easier to use than vanilla shiny for ui structuring
shinyApp(
  ui = dashboardPage(title = "Ontario Weather Station Precipitation and Temperature Data",
                     # dashboard is broken up into header, sidebar and body components
                     dashboardHeader(title = "Ontario Weather Data Visualization", titleWidth = 350),
                     # In this case the sidebar shown will depend on the tab being viewed by the user so it is defined in the server code
                     dashboardSidebar(sidebarMenu(id="tabs", sidebarMenuOutput("menu"))),
                     # The dashboard body is where our plots will be displayed and is subdivided between 3 separate tabs
                     dashboardBody(
                       # within the dashboard body, you have to define a tabset first to hold each of your tabs and assign it a unique id
                       tabsetPanel(id="tabs2", 
                                   # Then we can define each unique tabpanel with a title and tab value (that gets referenced back to from the server code)
                                   tabPanel(title = 'Weekly Averages', value = "1",
                                            # the header is customized based on the plot being viewed and so it is defined in the server code
                                            uiOutput("Header1"),
                                            # Fluid rows define discrete ui segments within the dashboard body, a column value of 12 will use all available width in the dashboard body
                                            # whearas a column value of 6 would only use half of the available width of the dashboard body
                                            fluidRow(
                                              column(12, plotlyOutput("plot1a"), plotlyOutput("plot1b"),
                                                     br(),
                                                     # download button that connects with the download handler in the server code
                                                     downloadButton('download1', 'Download Current Dataset in .csv'))
                                            )
                                   ),
                                   # Another tab panel for daily averages of temp and precipitation data
                                   tabPanel(title = 'Daily Averages', value = "2",
                                            uiOutput("Header2"),
                                            fluidRow(
                                              column(12, plotlyOutput("plot2a"), plotlyOutput("plot2b"),
                                                     br(),
                                                     downloadButton('download2', 'Download Current Dataset in .csv'))
                                            )
                                   ),
                                   # 
                                   tabPanel(title = 'About', value = "5",
                                            fluidRow(
                                              column(5, 
                                                     h4("Input info about your app here")
                                              ))
                                            
                                   )
                       )
                     )
  ),
  
  server = function(input, output, session) {
    
    # Output$menu is the argument that stores our sidebar menu items generated from the weather data input file
    output$menu <- renderMenu({
      # You can use conditional operators to change your sidebar layout depending on what tab you are on
      if(input$tabs2 == 1 | input$tabs2 == 2) {
        sidebarMenu(
          menuItem("Select Parameters", icon = icon("cog"), startExpanded = TRUE,
                   uiOutput("Station"),
                   uiOutput("Year")
          ))
      }
      else {
        sidebarMenu(
          menuItem("Data Dashboard", tabName = "datavis", icon = icon("dashboard")))
      }
    })
    
    # Output$Station will render our dropdown menu that is populated by unique station ids for the weather station data csv
    output$Station <- renderUI({
      selectInput("Stations", "1. Select a Station", choices = sort(unique(ddata$StationId)), selected = "ALEXANDRIA")
    })
    
    output$Year <- renderUI({
      # to populate a dropdown menu with years, we need to subset based on the station selected first since
      # not all stations posses data for all years
      subset1 <- ddata[ddata$StationId %in% input$Stations,]
      selectInput("Years", "2. Select a Year", choices = sort(unique(subset1$Year)), selected = 2004)
    })
    
    # These are our header arguments that are generated from the current station id and year selected from the dropdown menus
    # and will be displayed based on which tab is being viewed
    output$Header1 <- renderUI({
      h4(paste("Plots of Ontario Weather Data Summarized according to Week (5 day period) for ", input$Stations, " ", input$Years))
    })
    
    output$Header2 <- renderUI({
      h4(paste("Plots of Ontario Weather Data Summarized according to Day for ", input$Stations, " ", input$Years))
    })
    
    # stations_sub1 is a reactive argument that will subset the daily weather data based on selected inputs in the dropdown menus and store that data for use in plotting
    stations_sub1 <- reactive({
      subset2 <- ddata[ddata$StationId %in% input$Stations,]
      subset3 <- subset2[subset2$Year %in% input$Years,]
    })
    
    # stations_sub2 is a reactive argument that will subset the weekly weather data based on selected inputs in the dropdown menus and store that data for use in plotting
    stations_sub2 <- reactive({
      subset4 <- wdata[wdata$StationId %in% input$Stations,]
      subset5 <- subset4[subset4$Year %in% input$Years,]
    })
    
    # These are the arguments that will generate our plots dynamically based on the dropdown menu selections
    # renderPlotly is used to render our plot that was generated with ggplot and then converted to a plotly plot
    # Plots 1a and 1b will be for our weekly averaged weather data
    output$plot1a <- renderPlotly({
      p1a <- ggplot(stations_sub2(), aes(x=monthweek, y=totalprecipitation, text=paste("Total Weekly Precipitation: ", totalprecipitation, ", Month and Day: ", monthweek, sep=""))) + 
        geom_point(aes(colour = factor(data))) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        labs(x = "", y = "Total Precipitation (mm) per Week") +
        theme(legend.position="top", legend.title = element_blank(), plot.margin=unit(c(0.5,0.5,0.5,2.5),"cm"), axis.title.y = element_text(size = 12))
      # ggplotly converts a plot generated with ggplot into a plotly plot but you can just as easily render a plot with ggplot only
      # plotly allows for more interactive plots so I like to use it insetad of ggplot but i like the syntax of ggplot more so I use a hybrid of both
      ggplotly(p1a, tooltip="text")
    })
    
    output$plot1b <- renderPlotly({
      p1b <- ggplot(stations_sub2(), aes(x=monthweek, y=meantemp, text=paste("Weekly Mean, Min and Max of Temperature: ", meantemp, ", ", mintemp, ", ", maxtemp, ", Month and Week: ", monthweek, sep=""))) + 
        geom_point(aes(colour = factor(data)), position = position_dodge(0.8)) +
        geom_errorbar(aes(y=meantemp, ymin = mintemp, ymax = maxtemp, colour = factor(data)), position = position_dodge(0.8)) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        labs(x = "", y = "Mean Temp (C) per Week") +
        theme(legend.position="top", legend.title = element_blank(), plot.margin=unit(c(0.5,0.5,0.5,2.5),"cm"), axis.title.y = element_text(size = 12)) 
      ggplotly(p1b, tooltip="text")
    })
    
    output$plot2a <- renderPlotly({
      p2a <- ggplot(stations_sub1(), aes(x=FullDate, y=totalprecipitation, text=paste("Total Daily Precipitation: ", totalprecipitation, ", Month and Day: ", monthDay, sep=""))) + 
        geom_point(aes(colour = factor(data)), position = position_dodge(0.8)) +
        scale_x_date(breaks = "3 day", labels=date_format("%m-%d"), expand = c(0.01,0.01)) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        labs(x = "", y = "Total Precipitation (mm) per Day") +
        theme(legend.position="top", legend.title = element_blank(), plot.margin=unit(c(0.5,0.5,0.5,2.5),"cm"), axis.title.y = element_text(size = 12)) 
      ggplotly(p2a, tooltip="text")
    })
    
    output$plot2b <- renderPlotly({
      p2b <- ggplot(stations_sub1(), aes(x=FullDate, y=meantemp, text=paste("Daily Mean, Min and Max of Temp: ", meantemp, ", ", mintemp, ", ", maxtemp, ", Month and Day: ", monthDay, sep=""))) + 
        geom_point(aes(colour = factor(data)), position = position_dodge(0.8)) +
        geom_errorbar(aes(y=meantemp, ymin = mintemp, ymax = maxtemp, colour = factor(data)), position = position_dodge(0.8)) +
        scale_x_date(breaks = "3 day", labels=date_format("%m-%d"), expand = c(0.01,0.01)) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        labs(x = "", y = "Mean Temp (C) per Day") +
        theme(legend.position="top", legend.title = element_blank(), plot.margin=unit(c(0.5,0.5,0.5,2.5),"cm"), axis.title.y = element_text(size = 12)) 
      ggplotly(p2b, tooltip="text")
    })
    
    # These are the download handlers used by shiny to download current data shown in a plot into a csv named according to the year and station that is being viewed
    output$download1 <- downloadHandler(
      filename = function() { 
        paste(input$Stations, "_", input$Years, "_", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(stations_sub1(), file)
      })
    
    output$download2 <- downloadHandler(
      filename = function() { 
        paste(input$Stations, "_", input$Years, "_", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(stations_sub2(), file)
      })
    
  }
)

########################
# Tutorial on how to set up a shiny app on a personal website:
# https://deanattali.com/2015/05/09/setup-rstudio-shiny-server-digital-ocean/
# Very helpful guide that explains how to set up shiny with rstudio server and shiny server to make a shiny app that runs on a website

