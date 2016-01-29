# library(rCharts)
library(htmltools)
library(leaflet)
library(shinyjs)
library(RColorBrewer)
library(plotly)
library(dplyr)

source("utils.R")

# globalVariable <- as.character(head(bag$cities, 1)$city)

topBusinessCategories <- function(pCity, n=10){
    tmpdf = summarise(
        group_by(filter(bag$checkin, as.character(city)==pCity), category), 
        totalCheckin=sum(checkin_count)
    )
    tmpdf <- arrange(tmpdf, desc(totalCheckin))
    head(as.character(tmpdf$category), n)
}

updateCategorySelection <- function(session, pickedCity, n=10){
    categories <- topBusinessCategories(pickedCity, n)
    updateSelectInput(session, "categorySelect", 
                      selected = categories[1], 
                      choices = categories,
                      label="Pick a Category")
    
    if (length(categories) > 1){
        updateSelectInput(session, "categorySelectB", 
                          selected = categories[2], 
                          choices = categories,
                          label="Pick a Category")
    }else{
        updateSelectInput(session, "categorySelectB", 
                          selected = "...", 
                          choices = c("..."),
                          label="No Other Categories Avaiable")
    }
}

weekdayName <- function(intValue){
    tmpValue <- as.character(intValue)
    switch(tmpValue, "0"="Sunday", "1"="Monday", "2"="Tuesday", "3"="Wednesday", "4"="Thursday", "5"="Friday",
           "6"="Saturday")
}

periodCols <- RColorBrewer::brewer.pal(nlevels(as.factor(c("Morning", "Afternoon", "Night", "AfterHours"))), "Set2")

shinyServer(
    function(input, output, session) {
        
        output$tickedCity <- renderText({"..."})
        
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
            
            fdata <- fdata %>% mutate(period=sapply(hour, dayTime)) %>%
                group_by(category, period) %>% 
                mutate(checkins=sum(tt)) %>%
                group_by(category) %>%
                select(category, period, checkins)
            
            fdata <- unique(fdata)
            fdata <- fdata %>% ungroup() %>% group_by(category) %>% mutate(total=sum(checkins))            
            fdata <- fdata %>% ungroup() %>% arrange(desc(total))
            
            fdata <- fdata %>% rename(`Category`=category, `# Check-In`=checkins)

            plot_ly(data = fdata, x = Category, y = `# Check-In`, type = "bar", color = period, 
                    colors = c("#00CC20", "#D40000", "#FFDB0D", "#0485FF"), xlab="Checkins", ylab="Hour")  %>% 
                layout(barmode='stack', margin = list(b=150))                
        })
        
        output$weekdayActivityPlot <- renderPlotly({
            
            CITY <- input$citySelect
            CATEGORY <- input$categorySelect
            WEEKDAYS <- input$weekdayCheckGroup
            
            df <- select(
                filter(bag$checkin, as.character(city)==CITY, as.character(category)==CATEGORY,
                       day %in% WEEKDAYS), 
                day, hour, checkin_count)
            
            df <- mutate(df, day=sapply(day, weekdayName)) %>%
                    mutate(day=as.factor(day), `CheckIn Count`=checkin_count) %>%
                     arrange(day, hour)
            
            df <- df %>% rename(Hour=hour)

            plot_ly(df, x = Hour, y = `CheckIn Count`, color = day)
        })
        
        output$weekdayActivityPlotB <- renderPlotly({
            
            CITY <- input$citySelect
            CATEGORY <- input$categorySelectB
            WEEKDAYS <- input$weekdayCheckGroup
            
            if (CATEGORY == "..."){
                df <- data.frame(hour=rep(0:23,7), `CheckIn Count`=rep(0, 168), day=rep(sapply(WEEKDAYS, weekdayName), 24))
                return(plot_ly(df, x = hour, y = `CheckIn Count`, color = day))
            }
            
            df <- select(
                filter(bag$checkin, as.character(city)==CITY, as.character(category)==CATEGORY,
                       day %in% WEEKDAYS), 
                day, hour, checkin_count)
            
            df <- mutate(df, day=sapply(day, weekdayName)) %>%
                mutate(day=as.factor(day), `CheckIn Count`=checkin_count) %>%
                arrange(day, hour)
            
            df <- df %>% rename(Hour=hour)
            
            plot_ly(df, x = Hour, y = `CheckIn Count`, color = day)
        })
        
        output$dotMap <- leaflet::renderLeaflet({
            
            initialMark <- filter(bag$cities, as.character(city)=="Madison")
            content <- paste(sep="", "<b>", initialMark$city, "</b>")
            output$tickedCity <- renderText({as.character(initialMark$city)})
            output$trendCityA <- renderText({as.character(initialMark$city)})
            output$trendCityB <- renderText({as.character(initialMark$city)})
            
            # other providers
            #                 addProviderTiles("OpenStreetMap.Mapnik",
            #                                  options = providerTileOptions(noWrap = TRUE)
            #                 ) %>%                
            leaflet( width = "100%", height = "100%") %>%
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
            # first time only
            
            #                 addCircles(~longitude, , radius=radius, layerId=~zipcode,
            #                            stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
            #                 addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
            #                           layerId="colorLegend")
            
            updateCategorySelection(session, "Madison", 10)
        })
        
        observe({
            leafletProxy("dotMap") 
            event <- input$dotMap_marker_click
            if (is.null(event)){
                return()
            }
            
            output$tickedCity <- renderText({event$id})
            output$trendCityA <- renderText({event$id})
            output$trendCityB <- renderText({event$id})
            updateSelectInput(session, "citySelect", selected = event$id, choices = c(event$id))
            
            # update category selection on Data Tab
            updateCategorySelection(session, event$id, 10)
        })

        output$pickedCategoryA <- renderText({
            input$categorySelect
        })
        
        output$pickedCategoryB <- renderText({
            input$categorySelectB
        })        
        
        observeEvent(input$citySelect, {
            hide("citySelect")
        })
        
        output$businesses <- DT::renderDataTable({
            
            CITY <- input$citySelect
            
            cityData <- bag$geo %>% filter(as.character(city) == CITY)
            
            fdata <- cityData %>% select(city, name, address, stars, categories)
            
            fdata <- unique(fdata) %>% 
                rename(Name=name, City=city, Address=address, Stars=stars, Categories=categories) %>%
                select(Name, Address, Stars, Categories)
            
            return(fdata)
        })
        
    }
)

