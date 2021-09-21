library(leaflet)
library(shiny)
library(dplyr)
library(RColorBrewer)
library(tidyverse)



# load dataset
quakes <- read.csv("https://earthquake.usgs.gov/fdsnws/event/1/query?starttime=2010-01-01T00:00:00&minmagnitude=5&format=csv&latitude=19.42847&longitude=-99.12766&maxradiuskm=6000&orderby=magnitude")
# turn to data.frame and reshape
quakes <- as.data.frame(quakes)

#quakes$time <-anytime::anydate(quakes$time)
#quakes$time <- format(quakes$time, "%Y")
#quakes$time <- as.numeric(quakes$time)



ui <- bootstrapPage(
  

  
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    titlePanel("Earthquakes since the start of 2010 that had a magnitude of 5 and above"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 100, right = 10,
                  sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                              value = range(quakes$mag), step = 0.1
                  ),
                  selectInput("colors", "Color Scheme",
                              rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                  ),
                  checkboxInput("legend", "Show legend", TRUE)
    )
)

