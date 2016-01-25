#Madison (Washington, US), Fort Mill (California, US), Queen Creek (Arizona, US)
# "Madison","Fort Mill","Queen Creek"
# library(dplry)

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