#####Load Libraries + Datasets -----
library(shiny)
library(tidyverse)
titanic <-as.data.frame(Titanic)

ui <- fluidPage(
  div(id = "header",
      h1("Titanic Survival Exploration", align = "center", style = "color:blue"),
      h4("In Shiny!", align = "center")
  ),
  
  #titlePanel("Titanic Survival Exploration",align = "center", style = "color:blue"),
  fluidRow(
    column(6,      #Therefore column width is 6/12
        div(id= "form",
        radioButtons("graph_type", "Please select graph type", c("bar", "scatterplot")),
        selectInput("x_value", "Please select the variable to plot by", c("Class", "Sex", "Age"))
         )
          ),
    column(6,
           plotOutput("plot")
          )
  )
)

server <- function(input, output){
  output$plot<-renderPlot({
   if(input$graph_type == "bar"){
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