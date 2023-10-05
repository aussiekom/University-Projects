library(ggplot2)
library(lubridate)

locations = c("snezka", "palava", "komorni_hurka")
variables = c("snow", "temperature")
variable_codes = c("sd", "t2m")

data_all = NULL
for (var in 1:length(variables)) {
  data_variable = NULL
  for (loc in 1:length(locations)) {
    data_location = read.csv(paste0("data/", variables[var], loc, ".csv"))
    data_location = data_location[, c("time", variable_codes[var])]
    data_location$time = as.Date(data_location$time)
    data_location = cbind(data_location, location = as.factor(locations[loc]))
    
    if (is.null(data_variable)) {
      data_variable = data_location
    } else {
      data_variable = rbind(data_variable, data_location)
    }
  }
  if(is.null(data_all)) {
    data_all = data_variable
  } else{
    data_all[[variable_codes[var]]] = data_variable[[variable_codes[var]]]
  }
}

head(data_all)

# convert kelvins into celcius
data_all$t2m <- data_all$t2m - 273.15



# visualization with ggplot
ggplot(data = data_all, aes(x = time, y = t2m, color = location)) +
  geom_line() +
  labs(title = "Temperature by Locations",
       x = "Time",
       y = "Temperature [Celcius]") +
  scale_color_manual(values = c("snezka" = "deeppink3", 
                                "palava" = "darkolivegreen2", 
                                "komorni_hurka" = "cornflowerblue")) +
  theme_minimal()




# boxplots:
# Create a new column for the month
data_all$month <- lubridate::month(data_all$time, label = TRUE)

# Create boxplots with arbitrary colors
ggplot(data = data_all, aes(x = month, y = t2m, fill = location)) +
  geom_boxplot() +
  labs(title = "Temperature Variability by Month",
       x = "time",
       y = "Temperature [Celsius]") +
  scale_fill_manual(values = c("snezka" = "cornflowerblue", 
                               "palava" = "brown1", 
                               "komorni_hurka" = "aliceblue")) +
  scale_x_discrete(labels = c(
    "Jan" = "01",
    "Feb" = "02",
    "Mar" = "03",
    "Apr" = "04",
    "May" = "05",
    "Jun" = "06",
    "Jul" = "07",
    "Aug" = "08",
    "Sep" = "09",
    "Oct" = "10",
    "Nov" = "11",
    "Dec" = "12"
  )) +
  theme_minimal()




