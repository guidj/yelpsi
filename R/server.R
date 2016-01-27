# library(rCharts)
library(htmltools)
library(leaflet)
library(shinyjs)
library(plotly)
library(dplyr)

source("utils.R")

# globalVariable <- as.character(head(bag$cities, 1)$city)

shinyServer(
    function(input, output, session) {
        
        output$tickedCity <- renderText({"..."})
        
        dayPeriodData <- reactive({
            CITY <- input$citySelect
            fetchDayPeriodData(CITY)
        })
        
        output$streamChartHeader <- renderText({
            paste("Daily Local Activity:", as.character(input$citySelect))
        })
        
        output$checkinActivityPlot <- renderPlotly({
            
            CITY <- input$citySelect
            N <- 10
            tmpdf = summarise(
                group_by(filter(bag$checkin, as.character(city)==CITY), category), 
                totalCheckin=sum(checkin_count)
            )
            
            tmpdf <- arrange(tmpdf, desc(totalCheckin))
            categories <- head(as.character(tmpdf$category), N)
            
            fdata <- summarise(group_by(filter(bag$checkin, as.character(city)==CITY, category %in% categories), category, hour), tt=sum(checkin_count))
            fdata <- unique(
                select(
                    mutate(
                        group_by(
                            mutate(fdata, period=sapply(hour, dayTime)), category, period), checkins=sum(tt)
                    ), category, period, checkins))
            
            plot_ly(data = fdata, x = category, y = checkins, type = "bar", color = period, xlab="Checkins", ylab="Hour")  %>% 
                layout(barmode='stack', margin = list(b=100))            
            
        })
        
        output$dotMap <- leaflet::renderLeaflet({
            
#             randomIndex <- as.integer(runif(1, 1, dim(bag$cities)[1]))
            initialMark <- filter(bag$cities, as.character(city)=="Madison")
            content <- paste(sep="", "<b>", initialMark$city, "</b>")
            output$tickedCity <- renderText({as.character(initialMark$city)})
            
            leaflet() %>%
                addTiles(
                    urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
                ) %>%
                setView(lat = initialMark$latitude, lng = initialMark$longitude, zoom = 14)
        })
        
        observe({
            
            leafletProxy("dotMap", data = bag$cities) %>%
                clearShapes() %>%
                addMarkers(~longitude, ~latitude, layerId = ~city, popup = ~htmlEscape(city), 
                           clusterOptions = markerClusterOptions())
            
            #                 addCircles(~longitude, , radius=radius, layerId=~zipcode,
            #                            stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
            #                 addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
            #                           layerId="colorLegend")
        })
        
        observe({
            leafletProxy("dotMap") 
            event <- input$dotMap_marker_click
            if (is.null(event)){
                return()
            }
            
            output$tickedCity <- renderText({event$id})
            updateSelectInput(session, "citySelect", selected = event$id, choices = c(event$id))
        })
        
        observeEvent(input$citySelect, {
            hide("citySelect")
        })        
        
    }
)

