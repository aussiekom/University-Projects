library(dplyr)
library(leaflet)

source("model_prediction.r")

### define functions ------
test_weather_data_generation <- function(){
  
  city_weather_scooter_df <- generate_city_weather_scooter_data()
  stopifnot(length(city_weather_scooter_df) > 0)
  print(head(city_weather_scooter_df))
  return(city_weather_scooter_df)
  
}


### server part ------
shinyServer(function(input, output){
  
  color_levels <- leaflet::colorFactor(c("purple", "deeppink2", "darkorange1"), 
                              levels = c("small", "medium", "large"))
  
  city_weather_scooter_df <- test_weather_data_generation()
  
  # Create another data frame called `cities_max_scooter` with each row contains city location info and max scooter
  # prediction for the city
  cities_max_scooter <- city_weather_scooter_df %>% 
    dplyr::group_by(CITY_ASCII, LNG, LAT) %>% 
    dplyr::slice(which.max(SCOOTER_PREDICTION))
  
  # Observe drop-down event
  observeEvent(input$city_dropdown, {
    if(input$city_dropdown == "All") {
      # Then render output plots with an id defined in ui.R
      output$city_scooter_map <- leaflet::renderLeaflet({
        # If All was selected from drop down, then render a leaflet map with circle markers
        # and popup weather LABEL for all five cities
        leaflet(cities_max_scooter) %>% 
          addTiles() %>%
          addCircleMarkers(lng = cities_max_scooter$LNG, 
                           lat = cities_max_scooter$LAT,
                           popup = cities_max_scooter$DETAILED_LABEL,
                           radius = ~dplyr::case_when(cities_max_scooter$SCOOTER_PREDICTION_LEVEL == "small" ~ 6,
                                             cities_max_scooter$SCOOTER_PREDICTION_LEVEL == "medium" ~ 10,
                                             cities_max_scooter$SCOOTER_PREDICTION_LEVEL == "large" ~ 12),
                           color = ~color_levels(cities_max_scooter$SCOOTER_PREDICTION_LEVEL))
      })
    }
    else {
      # If just one specific city was selected, then render a leaflet map with one marker
      filtered_data <- cities_max_scooter %>% 
        dplyr::filter(CITY_ASCII == input$city_dropdown)
      
      city_weather_scooter_df_filter <- city_weather_scooter_df %>% 
        dplyr::filter(CITY_ASCII == input$city_dropdown)
      
      output$city_scooter_map <- leaflet::renderLeaflet({
        # on the map and a popup with DETAILED_LABEL displayed
        leaflet(filtered_data) %>% 
          addTiles() %>%
          addCircleMarkers(lng = filtered_data$LNG, 
                           lat = filtered_data$LAT,
                           popup = filtered_data$DETAILED_LABEL,
                           radius = ~dplyr::case_when(filtered_data$SCOOTER_PREDICTION_LEVEL == "small" ~ 6,
                                             filtered_data$SCOOTER_PREDICTION_LEVEL == "medium" ~ 10,
                                             filtered_data$SCOOTER_PREDICTION_LEVEL == "large" ~ 12),
                           color = ~color_levels(filtered_data$SCOOTER_PREDICTION_LEVEL))
      })
      
      
      
      ### temperature plot line
      output$temp_line <- echarts4r::renderEcharts4r({
        
        city_weather_scooter_df_filter$FORECASTDATETIME <- 
          as.POSIXct(city_weather_scooter_df_filter$FORECASTDATETIME)
        
        city_weather_scooter_df_filter %>%
          e_charts(FORECASTDATETIME) %>%
          e_line(TEMPERATURE) %>%
          e_title(paste("Temperature Chart of", input$city_dropdown)) %>%
          e_tooltip(trigger = "axis") %>%
          e_x_axis(name = "Date") %>%
          e_y_axis(name = "Temperature (Celsius)") %>%
          e_datazoom(type = "slider", show = TRUE) %>%
          e_legend(show = TRUE) %>%
          e_theme_custom('{"color":["#ff715e","#ffaf51"]}')
      })

      
      
      
      ### forecast plot line
      output$scooter_line <- echarts4r::renderEcharts4r({
        
        city_weather_scooter_df_filter$FORECASTDATETIME <- 
          as.POSIXct(city_weather_scooter_df_filter$FORECASTDATETIME)
        
        city_weather_scooter_df_filter %>%
          e_charts(FORECASTDATETIME) %>%
          e_line(SCOOTER_PREDICTION, name = "Predicted Scooter Count") %>%
          e_title(paste("Scooter Prediction of", input$city_dropdown)) %>%
          e_tooltip(trigger = "axis") %>%
          e_x_axis(type = "time") %>%
          e_y_axis(name = "Predicted Scooter Count") %>%
          e_datazoom(type = "slider", show = TRUE) %>%
          e_legend(show = TRUE) %>%
          e_theme_custom('{"color":["#ff715e","#ffaf51"]}')
      })
      
      
      ### text output
      output$scooter_date_output <- renderText({
        paste("Time = ", city_weather_scooter_df_filter[1,]$FORECASTDATETIME, " ",
              "Predicted Scooter Count = ", city_weather_scooter_df_filter[1,]$SCOOTER_PREDICTION)

      })

      
      ### humidity plot 
      output$humidity_pred_chart <- echarts4r::renderEcharts4r({
        city_weather_scooter_df_filter %>%
          e_charts(HUMIDITY) %>%
          e_effect_scatter(SCOOTER_PREDICTION, name = "Scooter Prediction") %>%
          e_visual_map(SCOOTER_PREDICTION) %>%
          e_title(paste("Scooter Prediction vs Humidity of", input$city_dropdown)) %>%
          e_tooltip(trigger = "axis") %>%
          e_x_axis(name = "Humidity") %>%
          e_y_axis(name = "Scooter Prediction") %>%
          e_datazoom(type = "slider", show = TRUE) %>%
          e_legend(show = TRUE) %>%
          e_theme_custom('{"color":["#ff715e","#ffaf51"]}')
      })

    } 
  })
})
