# app4.R 
# How to integrate plots via ggplot and plotly, dynamic file downloads and shinydashboard with tab navigation functionality
# install.packages("shinydashboard")
library(shinydashboard)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("plotly")
library(plotly)
# install.packages("data.table)
library(data.table)
# install.packages("scales")
library(scales)

# For this tutorial im using a subset of ontario weather station data from Environment Canada I used in a more advanced 
# version of this app (may take a min or two to load if you want to take a look):
# https://mattorton.shinyapps.io/ontarioweatherapp/

# Some dataframe import and formating first (can ignore for the purposes of this tutorial)
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
                                     # About section tab
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
      selectInput("Stations", "1. Select a Station", choices = sort(unique(ddata$StationId)), selected = input$Stations)
    })
    
    output$Year <- renderUI({
      # to populate a dropdown menu with years, we need to subset based on the station selected first since
      # not all stations posses data for all years
      subset1 <- ddata[ddata$StationId %in% input$Stations,]
      selectInput("Years", "2. Select a Year", choices = sort(unique(subset1$Year)), selected = input$Years)
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