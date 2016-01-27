require(rCharts)
require(leaflet)
require(shinyjs)
options(RCHART_LIB = 'nvd3')

shinyUI(
    fluidPage(
        useShinyjs(),
        titlePanel("YelpSí"),
        mainPanel(
            tags$head(tags$script(src="js/main.js")),
            tabsetPanel(
                tabPanel("Map",
                         fluidRow(
                             column(2),
                             column(10,
                                    h2(paste(sep=" ", "Yelp activity @"), textOutput("tickedCity", inline = TRUE), align="center"),
                                    br()
                             )
                         ),
                         fluidRow(                             
                             column(2),
                             column(5, 
                                    rCharts::showOutput("checkinStreamPlot", "nvd3")
                             ),
                             column(2)                                                 
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
                             column(2),
                             column(5,
                                    selectInput("citySelect", label="", choices= c("Madison","Fort Mill","Queen Creek"),
                                                selected = "Madison") 
#                                     shiny::textInput(placeholder = "Loading...", )
                             )
                         )
                ),
                tabPanel("About")
            )
        )
    ))