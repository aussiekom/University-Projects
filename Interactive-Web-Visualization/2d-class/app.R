library(shiny)
library(ggplot2)
library(ggiraph)
library(dygraphs)
library(leaflet)
library(httr2)
library(RColorBrewer)

source("load_data.r")
# location_colors <- c("snezka" = "deeppink3", 
#                      "palava" = "darkolivegreen2", 
#                      "komorni_hurka" = "cornflowerblue")


locations = list(longitudes = c(15.74, 16.64, 12.34),
                 latitudes = c(50.74, 48.84, 50.10),
                 names = c("snezka", "palava", "komorni_hurka"))

palettes <- list(
  brewer = brewer.pal(6, "Set1"),
  rgb = c("red", "green", "blue")
)


ui <- fluidPage(
  tags$head(tags$script(src = "file.js")),
  tags$head(tags$script(src = "plot.js")),
  
  column(4,
          titlePanel("Data Viewer"),
          selectInput(
            inputId = "variable",
            label = "Variable:",
            choices = levels(data$variable),
            selected = "t2m"
          ),
         selectInput(
           inputId = "palette",
           label = "Color palettes:",
           choices = names(palettes)
         ),
          checkboxGroupInput(
            inputId = "location",
            label = "Location:",
            choices = levels(data$location),
            selected = "snezka"
          )
  ),
  column(8,
         dygraphOutput("dygraph"),
         textOutput("temperature")
)
)

server <- function(input, output, session) {
  
  # add some reactivity, so do not repeat the same code everywhere in the app
  # the opposite function id isolate(), so the function wont be executed anywhere, but present in filter 
  data_to_plot <- reactive({
    data[location %in% input$location & variable == input$variable] 
  })
  
  observe({
    session$sendCustomMessage("plotColors", palettes[[input$palette]])
  }) 
  
  output$temperature <- renderText({
    text = "Temperatures:\n"
    for (loc in 1:length(locations$names)) {

      # we have it in javascript file
      # url <- paste0("https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=",
      #               locations$latitude[loc], "&lon=", locations$longitude[loc])
      # response = req_perform(request(url))
      # temperature <- resp_body_json(response)$properties$timeseries[[1]]$data$instant$details$air_temperature
      text = paste0(text, locations$names[loc], ": ", input$temperatures[loc], "C/n")
      
    }
    text
  })
  

  output$dygraph <- renderDygraph({
    dygraph(dcast(data_to_plot(), "time ~ location + variable")) %>% 
      dyRangeSelector() %>%
      dyOptions(colors = palettes[[isolate(input$palette)]]) %>%
      # dyShading(from = data$time[100], to = data$time[200], color = "#398")
      dyCallbacks(underlayCallback = "highlightTemperatures")
  })
  
  output$plot_clicked_points <- renderPrint({
    nearPoints(data_to_plot(), input$plot_click)
  })

}


shinyApp(ui = ui, server = server)
