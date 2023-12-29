library(httr)
library(scales)
library(stats)
library(readr)

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

# Forecast data by cities
get_weather_forecaset_by_cities <- function(city_names){
  # Vectors to hold data temporarily
  city <- c()
  weather <- c()
  temperature <- c()
  visibility <- c()
  humidity <- c()
  wind_speed <- c()
  seasons <- c()
  hours <- c()
  forecast_date <-c()
  weather_labels<-c()
  weather_details_labels<-c()

  # 5-days forecast data for each city
  for (city_name in city_names){
    url_get <- "https://api.openweathermap.org/data/2.5/forecast"
    api_key <- "b6a9b1005223a17d24f1c2441fde97a7"
    forecast_query <- list(q = city_name, appid = api_key, units = "metric")
    response <- GET(url_get, query = forecast_query)
    json_list <- content(response, as = "parsed")
    results <- json_list$list

    for(result in results) {
      # Gets weather data and append them to vectors
      city <- c(city, city_name)
      weather_main <- result$weather[[1]]$main
      weather <- c(weather, weather_main)

      # Gets predictor variables
      temperature <- c(temperature, result$main$temp)
      visibility <- c(visibility, result$visibility)
      humidity <- c(humidity, result$main$humidity)
      wind_speed <- c(wind_speed, result$wind$speed)

      forecast_datetime <- result$dt_txt
      hour <- as.numeric(strftime(forecast_datetime, format = "%H"))
      month <- as.numeric(strftime(forecast_datetime, format = "%m"))
      forecast_date <- c(forecast_date, forecast_datetime)
      season <- "Spring"
      # Simple rule to determine season
      if (month >= 3 && month <= 5)
        season <- "SPRING"
      else if(month >= 6  &&  month <= 8)
        season <- "SUMMER"
      else if (month >= 9  && month <= 11)
        season <- "AUTUMN"
      else
        season <- "WINTER"

      # HTML label for Leaflet
      weather_label <- get_weather_label(city_name, weather_main)
      weather_detail_label <- get_weather_detail_label(result, city_name)

      weather_labels <- c(weather_labels, weather_label)
      weather_details_labels <- c(weather_details_labels, weather_detail_label)

      seasons <- c(seasons, season)
      hours <- c(hours, hour)
    }
  }

  weather_df <- tibble(CITY_ASCII = city,
                       WEATHER = weather,
                       TEMPERATURE = temperature,
                       VISIBILITY = visibility,
                       HUMIDITY = humidity,
                       WIND_SPEED = wind_speed,
                       SEASONS = season,
                       HOURS = hours,
                       FORECASTDATETIME = forecast_date,
                       LABEL = weather_labels,
                       DETAILED_LABEL = weather_details_labels)

  return(weather_df)

}


# Loaded a saved regression model (variables and coefficients) from csv
load_saved_model <- function(model_name){
  
  model <- readr::read_csv(model_name)
  
  model <- model %>% 
    dplyr::mutate(Variable = gsub('"', '', Variable))
  
  coefs <- stats::setNames(model$Coef, as.list(model$Variable))
  
  return(coefs)
}


# Predicted scooter demand using a saved regression model
predict_scooter_demand <- function(TEMPERATURE, HUMIDITY, WIND_SPEED, VISIBILITY, SEASONS, HOURS){
  
  model <- load_saved_model("model.csv")
  
  weather_terms <- model["Intercept"] + TEMPERATURE*model["TEMPERATURE"] + 
    HUMIDITY*model["HUMIDITY"] + WIND_SPEED*model["WIND_SPEED"] + 
    VISIBILITY*model["VISIBILITY"] 
  
  season_terms <- c()
  
  # Calculated season related regression terms
  for(season in SEASONS) {
    season_term <- switch(season, 
                          "SPRING" = model["SPRING"],
                          "SUMMER" = model["SUMMER"],
                          "AUTUMN" = model["AUTUMN"], 
                          "WINTER" = model["WINTER"])
    season_terms <- c(season_terms, season_term)
  }
  
  # Obtain the hour term for the current hour
  current_hour <- as.numeric(format(Sys.time(), "%H"))
  hour_term <- model[as.character(current_hour)]
  
  regression_terms <- as.integer(weather_terms + season_terms + hour_term)
  
  for (i in 1:length(regression_terms)) {
    regression_terms[i] <- ifelse(regression_terms[i] < 0, 0, regression_terms[i])
  }
  
  return(regression_terms)
}



# Defines a scooter-sharing demand level, used for leaflet visualization
calculate_scooter_prediction_level <- function(predictions) {
  levels <- c()
  for(prediction in predictions){
    if(prediction <= 1000 && prediction >= 0)
      levels <- c(levels, "small")
    else if (prediction > 1000 && prediction < 3000)
      levels <- c(levels, "medium")
    else
      levels <- c(levels, "large")
  }
  return(levels)
}

# Generated a data frame containing weather forecasting and scooter prediction data
generate_city_weather_scooter_data <- function (){
  
  cities_df <- read_csv("cities_data.csv")
  weather_df <- get_weather_forecaset_by_cities(cities_df$CITY_ASCII)
  
  results <- weather_df %>% 
    mutate(SCOOTER_PREDICTION = predict_scooter_demand(TEMPERATURE, HUMIDITY, WIND_SPEED, VISIBILITY, SEASONS, HOURS)) %>%
    mutate(SCOOTER_PREDICTION_LEVEL = calculate_scooter_prediction_level(SCOOTER_PREDICTION))
  
  cities_scooter_pred <- cities_df %>% 
    left_join(results) %>% 
    select(CITY_ASCII, LNG, LAT, TEMPERATURE, HUMIDITY, 
           SCOOTER_PREDICTION, SCOOTER_PREDICTION_LEVEL, 
           LABEL, DETAILED_LABEL, FORECASTDATETIME)
  return(cities_scooter_pred)
}
