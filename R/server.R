library(rCharts)
library(data.table)
library(dplyr)
library(htmltools)
library(leaflet)

source("utils.R")

bag <- list()
bag$review <- dplyr::tbl_df(data.table(read.csv("../data/reviews.csv")))
bag$checkin <- dplyr::tbl_df(data.table(read.csv("../data/checkin.csv")))
bag$business <- dplyr::tbl_df(data.table(read.csv("../data/business_geo.csv")))
bag$geo <- unique(select(bag$business, id, name, latitude, longitude))
    
dayTime <- function (hour){
    
    if (6 <= hour && hour <= 12){return("Morning")}
    else if (13 <= hour && hour <= 18){return("Afternoon")}
    else if (19 <= hour && hour <= 23){return("Night")}
    else{return("AfterHours")}
}

bag$checkin <- mutate(bag$checkin, period=sapply(hour, dayTime))

shinyServer(
    function(input, output) {
        
        dayPeriodData <- reactive({
            CITY <- input$city
            
            dayTimeSummary = summarise(
                group_by(filter(bag$checkin, city==CITY), category, period), 
                `Day Time Total`=sum(checkin_count)
            )
            
            dayTimeSummary = mutate(
                group_by(dayTimeSummary, category), sum=sum(`Day Time Total`)
            )            
            
            top10 = head(as.character(
                select(arrange(
                    summarise(group_by(dayTimeSummary, category), sum=sum(`Day Time Total`)), 
                    desc(sum)), category)$category
            ), 10)   
            
            filter(dayTimeSummary, category %in% top10)
        })
        
        output$city <- renderText({
            as.character(input$city)
        })
                
        output$checkinPlot <- rCharts::renderChart2({

            d1 = dPlot(y="category", x="Day Time Total", data=dayPeriodData(), groups="period", 
                       type="bar",
                       bounds = list(x=150,y=30,width=600,height=320)
                    )
            d1$yAxis(type="addCategoryAxis", orderRule="sum")
            d1$xAxis(type="addMeasureAxis")
            d1$legend(x=0, y=0, width=600, height=75, horizontalAlign="right")
  
            d1
        })
        
        output$map <- leaflet::renderLeaflet({
            leaflet() %>%
            addTiles(
                urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
            ) %>%
            setView(lat = head(bag$geo$latitude,1), lng = head(bag$geo$longitude, 1), zoom = 4)
            
        })
        
        observe({

            leafletProxy("map", data = head(bag$geo, 1000)) %>%
                clearShapes() %>%
                addCircleMarkers(~longitude, ~latitude, layerId = ~id, popup = ~htmlEscape(name), 
                           clusterOptions = markerClusterOptions())
#                 addCircles(~longitude, , radius=radius, layerId=~zipcode,
#                            stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
#                 addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
#                           layerId="colorLegend")
        })        
    }
)

