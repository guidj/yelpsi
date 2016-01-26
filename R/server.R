library(rCharts)
library(htmltools)
library(leaflet)

source("utils.R")

shinyServer(
    function(input, output) {
        
        dayPeriodData <- reactive({
            CITY <- input$citySelect
            fetchDayPeriodData(CITY)
        })
        
        output$streamChartHeader <- renderText({
            paste("Daily Local Activity:", as.character(input$citySelect))
        })
        
        output$checkinStreamPlot <- rCharts::renderChart2({
            
            categories = unique(as.character(dayPeriodData()$category))
            fdata <- summarise(group_by(filter(bag$checkin, category %in% categories), category, hour), tt=sum(checkin_count))
            
            dat <- data.frame(
                t = fdata$hour, 
                var = fdata$category, 
                val = fdata$tt
            )
            
            streamP <- nPlot(val ~ t, group =  'var', data = dat, 
                             type = 'stackedAreaChart', id = 'streamChartB'
            )
            streamP$xAxis(axisLabel="AM-PM")
            streamP$yAxis(axisLabel="Daily Checkins")
            streamP$chart(margin=list(left=80, right=70, bottom=110))
            
            streamP
        })
        
        #         output$checkinPlot <- rCharts::renderChart2({
        # 
        #             d1 = dPlot(y="category", x="Day Time Total", data=dayPeriodData(), groups="period", 
        #                        type="bar",
        #                        bounds = list(x=150,y=30,width=600,height=320)
        #                     )
        #             d1$yAxis(type="addCategoryAxis", orderRule="sum")
        #             d1$xAxis(type="addMeasureAxis")
        #             d1$legend(x=0, y=0, width=600, height=75, horizontalAlign="right")
        #   
        #             d1
        #         })
        
        output$dotMap <- leaflet::renderLeaflet({
            leaflet() %>%
                addTiles(
                    urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
                ) %>%
                setView(lat = head(bag$cities$latitude,1), lng = head(bag$cities$longitude, 1), zoom = 4)
                
                
            
        })
        
        observe({
            
            # pick 100 places for each city
            
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
            #%>% clearPopups()
            event <- input$dotMap_marker_click
            if (is.null(event)){
                return()
            }
            output$tickedCity <- renderText({event$id})
        })
    }
)

