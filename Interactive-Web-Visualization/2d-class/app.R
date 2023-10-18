library(shiny)
library(ggplot2)
library(ggiraph)
library(dygraphs)
library(leaflet)

source("load_data.r")
location_colors <- c("snezka" = "deeppink3", 
                     "palava" = "darkolivegreen2", 
                     "komorni_hurka" = "cornflowerblue")

locations = list(longitudes = c(15.74, 16.64, 12.34),
                 latitudes = c(50.74, 48.84, 50.10),
                 names = c("snezka", "palava", "komorni_hurka"))

ui_parts <- c("leaflet_map", "dygraph", "girafe")


ui <- fluidPage(
  column(4,
          titlePanel("Data Viewer"),
          selectInput(
            inputId = "variable",
            label = "Variable:",
            choices = levels(data$variable)
          ),
          checkboxGroupInput(
            inputId = "location",
            label = "Location:",
            choices = levels(data$location),
            selected = "snezka"
          ),
         checkboxGroupInput(
           inputId = "shown_parts",
           label = "Shown parts",
           choices = ui_parts,
           selected = "map"
         )
  ),
  column(8,
         conditionalPanel("input.shown_parts.includes('leaflet_map')", leafletOutput("leaflet_map")),
         conditionalPanel("input.shown_parts.includes('dygraph')", dygraphOutput("dygraph")),
         conditionalPanel("input.shown_parts.includes('girafe')", girafeOutput("girafe"))
         )
)

server <- function(input, output) {
  
  # add some reactivity, so do not repeat the same code everywhere in the app
  # the opposite function id isolate(), so the function wont be executed anywhere, but present in filter 
  data_to_plot <- reactive({
    data[location %in% input$location & variable == input$variable] 
  })
  
  # leaflet map
  output$leaflet_map <- renderLeaflet({
    leaflet() %>% 
      setView(lng = 15, lat = 50, zoom = 7) %>% 
      addTiles() %>%
      addAwesomeMarkers(locations$longitudes, 
                        locations$latitudes, 
                        label = locations$names, 
                        icon = awesomeIcons(icon = "bookmark")) 
  })
  
  output$dygraph <- renderDygraph({
    
    # for ggplot
    # ggplot(data_to_plot(), aes(x = time, y = value, color = location)) +
    #   geom_line() +
    #   scale_color_manual(values = location_colors)
    
    # for dygraph
    dygraph(dcast(data_to_plot(), "time ~ location + variable")) %>% 
      dyRangeSelector()
  })
  
  output$plot_clicked_points <- renderPrint({
    nearPoints(data_to_plot(), input$plot_click)
  })
  
  output$girafe <- renderGirafe({
    
    plot = ggplot(data_to_plot(), aes(x = time, y = value, color = location, tooltip = paste(time, variable, location, value))) 
    plot = plot + geom_point_interactive() + scale_color_manual(values = location_colors)
    
    girafe(ggobj = plot)
  })
}


shinyApp(ui = ui, server = server)