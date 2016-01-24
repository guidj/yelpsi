library(rCharts)
library(data.table)
library(dplyr)

bag <- list()
bag$review <- dplyr::tbl_df(data.table(read.csv("../data/reviews.csv")))
bag$checkin <- dplyr::tbl_df(data.table(read.csv("../data/checkin.csv")))

dayTime <- function (hour){
    
    if (6 <= hour && hour <= 12){return("Morning")}
    else if (13 <= hour && hour <= 18){return("Afternoon")}
    else if (19 <= hour && hour <= 23){return("Night")}
    else{return("AfterHours")}
}

bag$checkin <- mutate(bag$checkin, period=sapply(hour, dayTime))

shinyServer(
    function(input, output) {
        
        output$city <- renderText({
            as.character(input$city)
        })
                
        output$checkinPlot <- rCharts::renderChart2({
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
            
            d1 = dPlot(y="category", x="Day Time Total", data=filter(dayTimeSummary, category %in% top10), groups="period", 
                       type="bar",
                       bounds = list(x=150,y=30,width=600,height=320)
                    )
            d1$yAxis(type="addCategoryAxis", orderRule="sum")
            d1$xAxis(type="addMeasureAxis")
            d1$legend(x=0, y=0, width=600, height=75, horizontalAlign="right")
  
            d1
        })        
    }
)

