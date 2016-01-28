#Madison (Washington, US), Fort Mill (California, US), Queen Creek (Arizona, US)
# "Madison","Fort Mill","Queen Creek"
# library(dplry)
library(data.table)
library(dplyr)

make_dataset = function(x, y, data = data){
    require(rCharts)
    toJSONArray2(data[c(x, y)], json = F, names = F)
}

# Create a polar plot given data and type
polarPlot <- function(data, type, ...){
    u <- rCharts$new()
    u$setLib('http://rcharts.github.io/howitworks/libraries/widgets/micropolar')
    if (!missing(data)) u$set(data = data)
    u$set(type = type, ...)
    return(u)
}


centralGeoCoordinates <- function(latitude, longitude){
    
    coordinate <- list()
    
    if (length(latitude) != length(longitude)){
        stop("Latitude and Longitude vectors must be of same length ", latitude, " ", longitude)
    }
    
    if (length(latitude) == 1){
        coordinate$lat <- latitude
        coordinate$lon <- longitude
        return (coordinate)        
    }
    
    x <- 0
    y <- 0
    z <- 0
    
    # convert to radians
    mapply(function(lat, lon){
        
        rlat <- lat * pi / 180
        rlon <- lon * pi / 180
        x <<- x + cos(rlat) * cos(rlon)
        y <<- y + cos(rlat) * sin(rlon)
        z <<- z + sin(rlat)
    }, latitude, longitude)
    
    total <- length(latitude)
    
    # normalize
    x <- x / total
    y <- y / total
    z <- z / total
    
    clon <- atan2(y, x)
    cSqr <- sqrt(x*x + y*y)
    clat <- atan2(z, cSqr)
    
    coordinate$lat <- clat * 180/pi
    coordinate$lon <- clon * 180/pi
    
    return (coordinate)
}    

dayTime <- function (hour){
    
    if (6 <= hour && hour <= 12){return("Morning")}
    else if (13 <= hour && hour <= 18){return("Afternoon")}
    else if (19 <= hour && hour <= 23){return("Night")}
    else{return("AfterHours")}
}

fetchDayPeriodData <- function(CITY, N=10){
    dayTimeSummary = summarise(
        group_by(filter(bag$checkin, city==CITY), category, period), 
        `Day Time Total`=sum(checkin_count)
    )
    
    dayTimeSummary = mutate(
        group_by(dayTimeSummary, category), sum=sum(`Day Time Total`)
    )            
    
    topN = head(as.character(
        select(arrange(
            summarise(group_by(dayTimeSummary, category), sum=sum(`Day Time Total`)), 
            desc(sum)), category)$category
    ), N)   
    
    filter(dayTimeSummary, category %in% topN)
}

estimateCities <- function(geo){
    
    # make this more efficient (double computation)
    unique(mutate(select(group_by(geo, city), city, latitude, longitude), latitude=centralGeoCoordinates(latitude, longitude)$lat,
              longitude=centralGeoCoordinates(latitude, longitude)$lon))
}

bag <- list()
# bag$review <- dplyr::tbl_df(data.table(read.csv("data/reviews.csv")))
bag$checkin <- dplyr::tbl_df(data.table(read.csv("data/checkin.csv")))
bag$geo <- dplyr::tbl_df(data.table(read.csv("data/business_geo.csv")))

# FIXING TOWN NAMES
bag$geo <- mutate(bag$geo, city=as.factor(replace(as.character(city), city=="London", "Edinburgh")))
bag$geo <- mutate(bag$geo, 
                  city=as.factor(replace(as.character(city), 
                                         city %in% c("De Forest", "Deforest", "De Forest"), 
                                         "DeForest")))
bag$geo <- mutate(bag$geo, 
                  city=as.factor(replace(as.character(city), 
                                         city %in% c("Mc Farland", "Mcfarland", "McFarland"), 
                                         "McFarland")))

# FILTER CITIES WITHOUT ACTIVITY

activeCities <- unique(as.character(bag$checkin$city))
bag$geo <- filter(bag$geo, as.character(city) %in% activeCities)

bag$checkin <- mutate(bag$checkin, period=sapply(hour, dayTime))
bag$cities <- estimateCities(bag$geo)



