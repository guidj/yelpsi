# require(rCharts)
require(leaflet)
require(shinyjs)
# options(RCHART_LIB = 'nvd3')

shinyUI(
    fluidPage(
        useShinyjs(),
        titlePanel("YelpSí"),
        mainPanel(
            tags$head(tags$script(src="js/main.js")),
            tabsetPanel(
                tabPanel("Xplore",
                         fluidRow(
                             column(2),
                             column(10,
                                    h2("Yelp activity @", textOutput("tickedCity", inline = TRUE), align="center"),
                                    br()
                             )
                         ),
                         fluidRow(                             
                             column(2),
                             column(10, 
                                    plotlyOutput("checkinActivityPlot")
                             )                                                
                         ),
                         fluidRow(
                             column(2),
                             column(10, 
                                    h4("Pick a City", align="center")
                             )
                         ),
                         fluidRow(
                             column(2),
                             column(10,leafletOutput("dotMap"))
                             
                         ),
                         fluidRow(
                             br(),br()
                         ),
                         fluidRow(
                             column(2),
                             column(5,
                                    selectInput("citySelect", label="", choices= c("Madison","Fort Mill","Queen Creek"),
                                                selected = "Madison")
                             )
                         )
                ),
                tabPanel("Find",
                         br(),
                         fluidRow(
                             column(4,
                                    selectInput("categorySelect", label="", choices= c("..."),
                                                selected = "...") 
                             ),
                             column(10)
                         ),
                         fluidRow(
                             column(12,
                                    h4(textOutput("pickedCategoryA", inline=TRUE),
                                       "activity @", 
                                       textOutput("trendCityA", inline = TRUE),
                                       align="center")
                             )
                         ),
                         fluidRow(
                             column(12, 
                                    plotlyOutput("weekdayActivityPlot")                                    
                             )
                         )                         
                ),
                tabPanel("About")
            )
        )
    ))