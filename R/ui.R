require(leaflet)
require(shinyjs)
require(plotly)

shinyUI(navbarPage("YelpSí",
                   tabPanel("Explore", 
                            div(class="outer",
                                
                                tags$head(
                                    # Include our custom CSS
                                    includeCSS("www/css/style.css"),
                                    includeScript("www/js/gomap.js")
                                ),
                                leafletOutput("dotMap",  width="100%", height="100%"),
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 500, height = "auto",                                              
                                              h2("Activity: Check-Ins"),
                                              plotlyOutput("checkinActivityPlot")
                                              
                                ),
                                selectInput("citySelect", label="", choices= c("Madison","Fort Mill","Queen Creek"),
                                            selected = "Madison")
                            )
                   ),
                   tabPanel("Observe",
                            br(),
                            fluidRow(
                                column(12,
                                       checkboxGroupInput("weekdayCheckGroup", label = h3("Weekdays"), 
                                                          choices = list("Sunday"=0, "Monday"=1, "Tuesday"=2,
                                                                         "Wednesday"=3,"Thursday"=4, 
                                                                         "Friday"=5, "Saturday"=6),
                                                          selected = c(0:6), inline=TRUE )                                    
                                )                             
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
                                column(9, 
                                       plotlyOutput("weekdayActivityPlot", width = "100%", height = 400)
                                ),
                                column(3,
                                       selectInput("categorySelect", label="", choices= c("..."),
                                                   selected = "...") 
                                )                             
                            ),
                            fluidRow(
                                column(12,
                                       h4(textOutput("pickedCategoryB", inline=TRUE),
                                          "activity @", 
                                          textOutput("trendCityB", inline = TRUE),
                                          align="center")
                                )
                            ),
                            fluidRow(
                                column(9, 
                                       plotlyOutput("weekdayActivityPlotB",  width = "100%", height = 400)                                    
                                ),
                                column(3,
                                       selectInput("categorySelectB", label="", choices= c("..."),
                                                   selected = "...") 
                                )                             
                            ),
                            fluidRow(
                                br()
                            )
                   ),
                   tabPanel("Businesses",
                            br(),
                            column(12,
                                DT::dataTableOutput("businesses", width = "100%", height = 400)
                            )
                   ), 
                   tabPanel("About",
                            fluidRow(
                                column(2),
                                column(10,
                                       br(),
                                       p("This visuzaliation tool let's you explore past daily activity trends of Yelpers around the world."),
                                       p(tags$b("Explore"), "the different cities where Yelpers are engaged in reviewing and checking into their favorite places on the map.
                                                         Once you've found a place of interest, you can observe the particular trends of level of activity at the top 10 business categories
                                                         on the", tags$b("Observe"), "tab."),
                                       br(),
                                       p("Lives on ", tags$a(href="https://github.com/guidj/yelpsi", "Github"), ".Report issues", tags$a(href="https://github.com/guidj/yelpsi/issues", "here"))
                                )
                            )
                   )               
))
