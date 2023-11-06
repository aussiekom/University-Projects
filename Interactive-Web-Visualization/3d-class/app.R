library(shiny)
library(dygraphs)
library(httr2)
library(RColorBrewer)

source("load_data.r")
locations = list(longitudes = c(15.74, 16.64, 12.34),
    latitudes = c(50.74, 48.84, 50.10),
    names = c("snezka", "palava", "komorni_hurka"))

palettes = list(
    brewer = brewer.pal(6, "Set1"),
    rgb = c("red", "green", "blue")
)

ui <- fluidPage(
    tags$head(
        tags$script(src = "get_forecast.js"),
        tags$script(src = "plot.js"),
        tags$script(src = "uPlot.iife.min.js"),
        tags$script(src = "microplot.js"),
        tags$link(rel = "stylesheet", type = "text/css", href = "uPlot.min.css")),
    column(4,
        titlePanel("Data Viewer"),
        selectInput("variable", "Variable:", levels(data$variable), selected = "t2m"),
        selectInput("palette", "Color palette:", names(palettes)),
        checkboxGroupInput("locations", "Locations:", levels(data$location), selected = levels(data$location)[1:2])
    ),
    column(8,
        dygraphOutput("dygraph"),
        verbatimTextOutput("temperatures"),
        tags$div(id = "uplot")
    )
)

server <- function(input, output, session) {
    data_to_plot <- reactive({
        data[location %in% input$locations & variable == input$variable]
    })

    observe({
        session$sendCustomMessage("plotColors", palettes[[input$palette]])
    })

    observe({
        data_to_microplot = data_to_plot()[location == input$locations[1],]
        data_to_microplot$time = as.numeric(as.POSIXct(data_to_microplot$time))
        session$sendCustomMessage("dataToPlot", data_to_microplot)
    })

    output$dygraph <- renderDygraph({
        dygraph(dcast(data_to_plot(), "time ~ location + variable")) %>% dyRangeSelector() %>%
            dyOptions(colors = palettes[[isolate(input$palette)]]) %>%
            # dyShading(from = data$time[100], to = data$time[200], color = "#FFFF00") %>%
            dyCallbacks(underlayCallback = "highlightTemperatures")
    })

    output$temperatures <- renderText({
        text = "Temperatures:\n"
        for (loc in 1:length(locations$names)) {
            # url = paste0("https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=", locations$latitudes[loc], "&lon=", locations$longitudes[loc])
            # response = req_perform(request(url))
            # temperature = resp_body_json(response)$properties$timeseries[[1]]$data$instant$details$air_temperature
            text = paste0(text, locations$names[loc], ": ", input$temperatures[loc], " °C\n")
        }
        text
    })
}

shinyApp(ui = ui, server = server)
