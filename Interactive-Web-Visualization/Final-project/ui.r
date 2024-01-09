library(leaflet)
library(echarts4r)
library(shiny)

source("model_prediction.r")

# functions to generate the map labels
get_weather_label <- function(city_name, weather_main) {
  weather_label <- paste(sep = "",
                         "<b><a href=''>",
                         city_name,
                         "</a></b>", "</br>",
                         "<b>", weather_main, "</b></br>")
  return(weather_label)
}

get_weather_detail_label <- function(result, city_name) {
  weather_detail_label <- paste(sep = "",
                                "<b><a href=''>",
                                city_name,
                                "</a></b>", "</br>",
                                "<b>", result$weather[[1]]$main, "</b></br>",
                                "Temperature: ", result$main$temp, " C </br>",
                                "Visibility: ", result$visibility, " m </br>",
                                "Humidity: ", result$main$humidity, " % </br>",
                                "Wind Speed: ", result$wind$speed, " m/s </br>",
                                "Datetime: ", result$dt_txt, " </br>")
  return(weather_detail_label)
}


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
                           conditionalPanel(
                             condition = "input.city_dropdown != 'All'",
                             echarts4r::echarts4rOutput('temp_line'),
                             echarts4r::echarts4rOutput("scooter_line"),
                             shiny::verbatimTextOutput("scooter_date_output"), 
                             echarts4r::echarts4rOutput('humidity_pred_chart')
                           )),
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



