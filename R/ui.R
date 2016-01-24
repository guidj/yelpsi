require(rCharts)
options(RCHART_LIB = 'dimple')

shinyUI(fluidPage(
    titlePanel("Yelpsee"),
    sidebarLayout(position = "right",
        sidebarPanel(
            helpText("Observe populatiry of business categories in different cities."),
            conditionalPanel(condition="input.conditionedPanels == 'Check-In'",       
                             helpText("Check-In Tab"),
             selectInput("city", 
                         label = "Choose a city",
                         choices= c("Madison","Fort Mill","Queen Creek"),
                         selected = "Madison")
            ),    
            conditionalPanel(condition="input.conditionedPanels == 'Activity'", 
                             helpText("Activity Tab")
            )
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("Check-In",
                         br(),
                         div(class="row",
                             div(class="col-md-1"),
                             div(
                                 class="col-md-8",
                                 rCharts::showOutput("checkinPlot", "dimple")
                             )
                         ),
                         br()
                ),
                tabPanel("Activity",  
                         br(),
                         p(paste("polygons by strata"))
                ),
                id = "conditionedPanels"                
            )
        )  
    )
))