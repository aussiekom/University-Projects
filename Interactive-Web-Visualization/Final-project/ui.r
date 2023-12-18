library(dplyr)
library(leaflet)
library(tidyverse)

source("model_prediction.r")

### define functions ------
test_weather_data_generation <- function(){
  
  city_weather_scooter_df <- generate_city_weather_scooter_data()
  stopifnot(length(city_weather_scooter_df) > 0)
  print(head(city_weather_scooter_df))
  return(city_weather_scooter_df)
}

test_weather_data_generation()




### ui part --------
ui <- shinyUI(
  fluidPage(padding = 5,
            titlePanel(title = "Scooter Demand Prediction"),
            
            sidebarLayout( 
              sidebarPanel(
                width = 2,
                selectInput(inputId = "city_dropdown", 
                            label = "Select City: ", 
                            choices = c("All", "Prague", "Berlin", "Milan", 
                                        "Paris", "Warsaw", "Vienna", "Zurich", 
                                        "Barcelona", "Rome", "Bucharest"))
            ),
            mainPanel(
              tabsetPanel(
                tabPanel(title = "Map", 
                         leaflet::leafletOutput("city_scooter_map", 
                                       height = 1000)),
                tabPanel(title = "Plots", 
                         echarts4r::echarts4rOutput('temp_line'),
                         echarts4r::echarts4rOutput("scooter_line"),
                         shiny::verbatimTextOutput("scooter_date_output"), 
                         echarts4r::echarts4rOutput('humidity_pred_chart')),
                tabPanel(title = "About", 
                         br(),
                         strong("The Scooter Demand Prediction App"),
                         p("This simple app uses machine learning and weather forecasting 
                           to offer insights into scooter demand across various cities in Europe. 
                           The predictive model, rooted in regression analysis, 
                           estimates scooter demand by considering factors such as temperature, 
                           humidity, wind speed, visibility, and time-related elements."),
                         br(),
                         strong("The interactive interface empowers users to:"),
                         p("- Explore scooter predictions on an intuitive leaflet map."),
                         p("- View temperature trends."),
                         p("- Analyze the impact of humidity on scooter demand through insightful charts."),
                         em("This app serves as a valuable tool for urban planners and scooter-sharing services, 
                            aiding in the optimization of fleet management based on prevailing weather conditions."),
                         br(),
                         br(),
                         strong("Technologies Used:"),
                         p("- R Shiny: To create the web application."),
                         p("- Leaflet: For the interactive map."),
                         p("- Echarts4r library: For interactive plots and graphs."),
                         p("- API requests from the OpenWeatherMap: Integrating weather data."),
                         p("- Regression Analysis: Forming the basis of the predictive model."),
                         br(),
                         strong("Data Source:"),
                         p("The data used in this project was downloaded from:"),
                         tags$a(href="https://simplemaps.com/data/world-cities", "SimpleMaps"),
                         p(" The dataset was filtered to select cities in European countries."),
                         br(),
                         br(),
                         em("This app was done as a semestral project for the class 'Interactive web visualisations' by Evgeniia Komarova."),
                         br(),
                         em("Czech University of Life Sciences Prague. 2023")
                )
              )
            )
            
        )
  )
)



