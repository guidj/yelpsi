#Madison (Washington, US), Fort Mill (California, US), Queen Creek (Arizona, US)
# "Madison","Fort Mill","Queen Creek"
# library(dplry)
library(data.table)
library(dplyr)

dayTime <- function (hour){
    
    if (6 <= hour && hour <= 12){return("Morning")}
    else if (13 <= hour && hour <= 18){return("Afternoon")}
    else if (19 <= hour && hour <= 23){return("Night")}
    else{return("AfterHours")}
}

bag <- list()
# bag$review <- dplyr::tbl_df(data.table(read.csv("data/reviews.csv")))
bag$checkin <- dplyr::tbl_df(data.table::fread("data/checkin.csv"))
bag$business <- dplyr::tbl_df(data.table::fread("data/businesses.csv"))
bag$cities <- dplyr::tbl_df(data.table::fread("data/cities.csv"))

activeCities <- unique(as.character(bag$checkin$city))
bag$business <- bag$business %>% filter(as.character(city) %in% activeCities)
bag$cities <- bag$cities %>% filter(as.character(city) %in% activeCities)
bag$checkin <- mutate(bag$checkin, period=sapply(hour, dayTime))
