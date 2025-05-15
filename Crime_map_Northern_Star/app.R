library(shiny)
library(leaflet)
library(readr)
library(dplyr)
library(lubridate)

# Load the data
data <- read_csv("updated_crime_data_google_with_coords_combined.csv")  # Replace with your CSV file path

data <- data %>%
  mutate(Offense_date = as.Date(`Date Occurred`, format = "%m/%d/%y"))

data <- data %>%
  filter(Offense_date >= as.Date("2024-12-01"))

available_months <- unique(format(data$Offense_date, "%B"))
available_years <- unique(year(data$Offense_date))

# Group data by address and summarize offenses
grouped_data <- data %>%
  group_by(Full_Address, Latitude, Longitude) %>%
  summarize(
    Current_Column = first(Current_Column),  # Keep the first place name
    OffenseDates = paste("<li>", Offense, "(", Offense_date, ")", "</li>", collapse = ""),# Combine offenses as an HTML list
    .groups = "drop"
  )

# UI (User Interface)
ui <- fluidPage(
  titlePanel("Crime Map: NIU Campus"),
  leafletOutput("crimeMap", height = 800),  # Display the map
  hr(),
  fluidRow(
    column(4,
           selectInput("offenseType", "Filter by Offense:", 
                       choices = c("All", unique(data$Offense)), 
                       selected = "All"),
           uiOutput("monthDropdown"),
           uiOutput("yearDropdown")
           )
  )
)

# Server (Logic)
server <- function(input, output, session) {
  filteredData <- reactive({
    filtered <- data 
    #Filter by offense type 
    
    filtered <- filtered %>% filter(Offense_date >= as.Date("2024-12-01"))
    
    if (input$offenseType != "All") {
      filtered <- filtered %>% filter(Offense == input$offenseType)
    }
    # Filter by month
    if (!is.null(input$monthFilter) && input$monthFilter != "All") {
      filtered <- filtered %>% filter(format(Offense_date, "%B") == input$monthFilter)
    }
    # Filter by year
    if (!is.null(input$yearFilter) && input$yearFilter != "All") {
      filtered <- filtered %>% filter(year(Offense_date) == as.numeric(input$yearFilter))
    }
    # Group data by offense and summarize offenses 
    filtered %>%
      group_by(Full_Address, Latitude, Longitude) %>%
      summarize(
        Current_Column = first(Current_Column),
        OffenseDates = paste0("<li><span style='white-space: nowrap;'>", Offense, " (", Offense_date, ")</span></li>", collapse = ""),
        .groups = "drop"
      )
    
  })
  
  #Dynamically generate the month dropdown based on the filtered data
  output$monthDropdown <- renderUI({
    available_months <- unique(format(data$Offense_date, "%B"))
    selectInput("monthFilter", "Filter by Month:",
                choices = c("All", available_months),
                selected = "All")
  })
  
  # Dynamically generate the year dropwdown based on filtered date 
  output$yearDropdown <- renderUI({
    available_years <- unique(year(data$Offense_date))
    selectInput("yearFilter", "Filter by Year:",
                choices = c("All", available_years),
                selected = "All")
  })
  
  
  output$crimeMap <- renderLeaflet({
    leaflet(data) %>%
      addTiles() %>%
      setView(
        lng = mean(data$Longitude, na.rm = TRUE),  # Center the map on the average longitude
        lat = mean(data$Latitude, na.rm = TRUE),   # Center the map on the average latitude
        zoom = 13  # Adjust the zoom level
      ) %>%
      addMarkers(
        ~Longitude, ~Latitude,
        popup = ~paste(
          "<b>Place:</b>", Current_Column, "<br>",
          "<b>Address:</b>", Full_Address, "<br>",
          "<b>Offense:</b><ul>", Offense, "</ul>"  # Display all offenses as a list
        ),
        popupOptions = popupOptions(maxWidth = 500, minWidth = 300)
      )
  })
  
  observe({
    leafletProxy("crimeMap", data = filteredData()) %>%
      clearMarkers() %>%
      addMarkers(
        ~Longitude, ~Latitude,
        popup = ~paste(
          "<b>Place:</b>", Current_Column, "<br>",
          "<b>Address:</b>", Full_Address, "<br>",
          "<b>Offenses and Date Occurred:</b><ul>", OffenseDates, "</ul>"
        ),
        popupOptions = popupOptions(maxWidth = 500, minWidth = 300)
      )
  })
}

# Run the Shiny app
shinyApp(ui, server)
