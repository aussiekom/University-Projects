library(data.table)

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
    if (variable_codes[var] == "t2m") {
      data_location$t2m = data_location$t2m - 273.15
    }
    
    if (is.null(data_variable)) {
      data_variable = data_location
    } else {
      data_variable = rbind(data_variable, data_location)
    }
  }
  if (is.null(data_all)) {
    data_all = data_variable
  } else {
    data_all[[variable_codes[var]]] = data_variable[[variable_codes[var]]]
  }
}

data_all = data.table(data_all)
data = melt(data_all, id.vars = c("time", "location"), measure.vars = variable_codes)