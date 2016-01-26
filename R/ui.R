require(rCharts)
require(leaflet)
options(RCHART_LIB = 'nvd3')

shinyUI(
    fluidPage(
        titlePanel("YelpSí"),
        mainPanel(
            tabsetPanel(
                tabPanel("Map",
                         fluidRow(
                             column(1),
                             column(10,
                                    h2("Spots"),
                                    br()
                             ),
                             column(1)
                         ),
                         fluidRow(
                             column(1),
                             column(10, leafletOutput("dotMap")),
                             column(1)
                         ),
                         fluidRow(
                             p(textOutput("ticked"))
                             )
                ),
                tabPanel("Daily Activity Panel",
                         fluidRow(
                             column(2),
                             column(5, 
                                    h3(textOutput("streamChartHeader", inline = TRUE), align="center"),
                                    rCharts::showOutput("checkinStreamPlot", "nvd3")
                             ),
                             column(2)                    
                         ),
                         fluidRow(
                             column(2),
                             column(6,
                                    selectInput("citySelect", label = "Choose a city", choices= c("Madison","Fort Mill","Queen Creek"),
                                                selected = "Madison"),
                                    column(2)
                             )
                         )                         
                ),                
                tabPanel("Table", tableOutput("table"))
            )
        )
        
        
        
        #     sidebarLayout(position = "right",
        #         sidebarPanel(
        #             helpText("Observe populatiry of business categories in different cities."),
        #             conditionalPanel(condition="input.conditionedPanels == 'Check-In'",       
        #                              helpText("Check-In Tab"),
        #                              selectInput("city", 
        #                                          label = "Choose a city",
        #                                          choices= c("Madison","Fort Mill","Queen Creek"),
        #                                          selected = "Madison")
        #             ),    
        #             conditionalPanel(condition="input.conditionedPanels == 'Activity Distribution'", 
        #                              helpText("Activity Distribution Tab")
        #             ),            
        #             conditionalPanel(condition="input.conditionedPanels == 'Activity'", 
        #                              helpText("Activity Tab")
        #             )
        #         ),
        #         mainPanel(
        #             tabsetPanel(
        #                 tabPanel("Check-In",
        #                          br(),
        #                          div(class="row",
        #                              div(class="col-md-1"),
        #                              div(
        #                                  class="col-md-8",
        #                                  h3(
        #                                      "Check-In: Day Period Distribution,",textOutput("city", inline = TRUE),
        #                                      align="center"),
        #                                  rCharts::showOutput("checkinPlot", "dimple")
        #                              )
        #                          ),
        #                          div(class="row",
        #                              div(class="col-md-1"),
        #                              div(
        #                                  class="col-md-4",
        #                                  h3(
        #                                      "Daily Local Activity,", textOutput("city", inline = TRUE),
        #                                      align="center"),
        #                                  rCharts::showOutput("checkinStreamPlot", "nvd3")
        #                              ),
        #                              div(class="col-md-1"),
        #                              div(class="col-md4")
        #                          ),                     
        #                          br()
        #                 ),
        #                 tabPanel("Activity Distribution",  
        #                          br(),
        #                          leafletOutput("map"),
        #                          br()
        #                 ),    
        # 
        #                 tabPanel("Activity",  
        #                          br(),
        #                          p(paste("polygons by strata"))
        #                 ),
        #                 id = "conditionedPanels"                
        #             )
        #         )  
        #     )
    ))