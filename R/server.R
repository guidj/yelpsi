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
            
#             fdata$hour <- as.factor(fdata$period)
            plot_ly(data = fdata, x = category, y = checkins, type = "bar", color = period, xlab="Checkins", ylab="Hour")  %>% 
                    layout(barmode='stack', margin = list(b=100))            

        })
        
#         output$checkinStreamPlot <- rCharts::renderChart2({
#             
#             CITY <- input$citySelect
#             N <- 10
#             tmpdf = summarise(
#                 group_by(filter(bag$checkin, as.character(city)==CITY), category), 
#                 totalCheckin=sum(checkin_count)
#             )
#             
#             tmpdf <- arrange(tmpdf, desc(totalCheckin))
#             categories <- head(as.character(tmpdf$category), N)
# 
#             fdata <- summarise(group_by(filter(bag$checkin, as.character(city)==CITY, category %in% categories), category, hour), tt=sum(checkin_count))
#             
#             dat <- data.frame(
#                 t = fdata$hour, 
#                 var = fdata$category, 
#                 val = fdata$tt
#             )
#             
#             streamP <- nPlot(val ~ t, group =  'var', data = dat, 
#                              type = 'stackedAreaChart', id = 'streamChartB',
#                              legend
#                             
#             )
#             
#             streamP$xAxis(axisLabel="Hour")
#             streamP$yAxis(axisLabel="Number of Checkins")
#             streamP$chart(margin=list(left=80, right=70, bottom=110))
#             
#             streamP
#         })
        
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
            
            randomIndex <- as.integer(runif(1, 1, dim(bag$cities)[1]))
            initialMark <- bag$cities[randomIndex,]
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

