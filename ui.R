library(shiny)
source("getData.R")

shinyUI(navbarPage("S&P500Vis",
    
    tabPanel("Documentation",
                      
             h3("Introducing S&P500Vis"),
             p("S&P500Vis is an application that displays the geographical location of the firms listed on the ", em("S&P 500"), " index"),
             h4("Features"),
             p("The App splits the index into two main groups (USA or Europe) and visualises the location of the Headquarter. Using the sidebarpanel on the left is possible to select which macroregion visualise."),
             p("Using the dropdown menu on the sidepanel, it is possible to focus on a particular sector and visualise the geographical position and statistics of the firms that are grouped in that segment. It is possible to select more than one sector."),
             p("the GeoChart shows the geographical position of the firms' headquarters. Markers' color indicates the number of companies present in a particular state; the dimension indicates the number of different sectors present in the state. The statistics shown on the map depends on the segments: they change dynamically depending on which and how many segments have been selected."),
             p("The datatables show statistics on the firms composing the index that belong to the geographical area and the sectors selected."),
             p("The data is retrieved dynamically from the web: for a correct visualisation, please wait until the app fully uploads the GeoChart."),
             p("For R code visit the", a("GitHub repository", href = "https://github.com/DavidJT0"))
     
             ),
    
    tabPanel("Application",
  
  fluidRow(
    column(10,
           
           fluidRow(
             column(9,
                    
                    sidebarPanel(   
                      
                      selectInput("Macroregion", "Region to display:",
                                  choices = c("USA", "Europe"),
                                  selected = "USA",
                                  multiple = FALSE
                      ),
                                   
                      selectInput("Sectors", "Sectors to display:",
                                  choices = as.character(unique(Companies$GICS.Sector)),
                                  selected = "All",
                                  multiple = TRUE
                      ),  
                      
                      br(),
                      textOutput("nrCompanies")
                    ),
                    
                    mainPanel(            
                      
                      htmlOutput("mapRegion")
                      
                    )
             )
           ),
           
           fluidRow(
             column(12, 
                    
                    hr(),
                    tabsetPanel(
                      id = "dataset",
                      tabPanel("Companies", dataTableOutput("tableSectors1")),
                      tabPanel("Sectors", dataTableOutput("tableSectors2")),
                      tabPanel("Industries", dataTableOutput("tableSectors3"))  
                      
                    )
             )
           )
    )
  )	  
)

))