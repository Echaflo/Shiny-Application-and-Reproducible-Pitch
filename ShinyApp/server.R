library(shiny)
library(leaflet)
library(RColorBrewer)
##library(tidyverse)


# load dataset
quakesa <- read.csv("https://earthquake.usgs.gov/fdsnws/event/1/query?starttime=2010-01-01T00:00:00&minmagnitude=5&format=csv&latitude=19.42847&longitude=-99.12766&maxradiuskm=6000&orderby=magnitude")
# turn to data.frame and reshape
quakesa <- as.data.frame(quakesa)
colnames(quakesa)[2] <- "lat"
colnames(quakesa)[3] <- "long"

quakesa$time <-anytime::anydate(quakesa$time)
quakesa$time <- format(quakesa$time, "%Y")
quakesa$time <- as.numeric(quakesa$time)



server <- function(input, output, session) {
  

  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakesa[quakesa$mag >= input$range[1] & quakesa$mag <= input$range[2],]
  })
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData1 <- reactive({
    quakesa[quakesa$time >= input$years[1] & quakesa$time <= input$years[2],]
  })
  

  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(input$colors, quakesa$mag)
  })
  
  
  
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakesa) %>%
      addTiles() %>%
      setView(lng = -99.12766,
              lat = 19.42847,
              zoom = 3) 
      # %>%
      # fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))

             
  })
  

  
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~6^mag/6, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
      )
  })
  
  
  observe({
    pal <- colorpal()

    leafletProxy("map", data = filteredData1()) %>%
      clearShapes() %>%
      addCircles(radius = ~6^mag/6, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
      )
  })
  
  
  
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakesa)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~mag
      )
    }
  })
}

