library(shiny)
library(leaflet)
library(RColorBrewer)
#library(tidyverse)



# load dataset
quakesa <- read.csv("https://earthquake.usgs.gov/fdsnws/event/1/query?starttime=2010-01-01T00:00:00&minmagnitude=5&format=csv&latitude=19.42847&longitude=-99.12766&maxradiuskm=6000&orderby=magnitude")
# turn to data.frame and reshape
quakesa <- as.data.frame(quakesa)
colnames(quakesa)[2] <- "lat"
colnames(quakesa)[3] <- "long"

quakesa$time <-anytime::anydate(quakesa$time)
quakesa$time <- format(quakesa$time, "%Y")
quakesa$time <- as.numeric(quakesa$time)



ui <- bootstrapPage(
  

  
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    titlePanel("Earthquakesa since the start of 2010 that had a magnitude of 5 and above"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 100, right = 10,
                  sliderInput("range", "Magnitudes", min(quakesa$mag), max(quakesa$mag),
                              value = range(quakesa$mag), step = 0.1
                  ),
                  sliderInput("years", "Year", min(quakesa$time), max(quakesa$time),
                              value = range(quakesa$time), step = 1
                  ),
                  selectInput("colors", "Color Scheme",
                              rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                  ),
                  checkboxInput("legend", "Show legend", TRUE)
    )
)

