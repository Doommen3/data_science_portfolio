#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# load shiny
library(shiny)
library(bdgramR)
library(tidyverse)
library(readxl)
source("data/trainer_bodyparts.R")


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Evo Workout Volume"),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("workoutPlot")
        )
    )


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
    output$workoutPlot <- renderPlot({
      plot(muscle_plot)
  
    
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
