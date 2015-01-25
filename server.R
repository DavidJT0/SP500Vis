library(shiny)
library(googleVis)

CreateTable <- function(DataFrame, whichColumn) {
                                                  if(dim(DataFrame)[1] == 0) {return()} 
                                                  Table <- as.data.frame(table(DataFrame[,whichColumn]))
                                                  Table <- Table[order(Table[,2], decreasing = TRUE),]
                                                  colnames(Table) <- c(names(DataFrame)[whichColumn], "Nr. Companies")
                                                  Table$Weight <- paste(round(Table[,2]/sum(Table[,2])*100, digits = 2), "%", sep = "")
                                                  return(Table)
                                                  }

shinyServer(function(input, output) {

  
  output$mapRegion <- renderGvis({
    
    Region <- switch(input$Macroregion,
                     "USA" = "USA",
                     "Europe" = "nonUSA",
    )
    
      DB <- split(Companies, Companies$isUSA == Region)[[2]]
      DB$State <- as.factor(DB$State)
      CompaniesbyRegion <- DB
    
      DB <- droplevels(DB[(DB$GICS.Sector %in% input$Sectors),])
      CompaniesbyRegion <- droplevels(CompaniesbyRegion[(CompaniesbyRegion$GICS.Sector %in% input$Sectors),1:6])
      if(dim(DB)[1] == 0) {DB <- split(Companies, Companies$isUSA == Region)[[2]] 
                           CompaniesbyRegion <- DB[,1:6]}
    
      DB <- split(DB, DB$State)
      DB <- data.frame(   State = names(DB),
                          Firms = as.numeric(sapply(DB, function(e) {length(e[[2]])})),
                          Sectors = as.numeric(sapply(DB, function(e) {length(unique(e[[3]]))})),
                          Top.Sector = as.character(sapply(DB, function(e) { temp <- table(e[[3]])
                                                                             temp <- sort(temp,decreasing = TRUE)
                                                                             val <- round((temp[1]/length(e[[3]]))*100, digits = 2)
                                                                             paste(names(temp)[1]," (", val,"%)",sep="")
                                                                            }))
                          )                       
      DB$Display <- paste(DB$State, ". Top Sector: " , DB$Top.Sector, sep ="")
 
    colnames(CompaniesbyRegion) <- c("Ticker", "Security", "GICS Sector", "GICS Industry", "Location of Headquarters", "State")
    output$nrCompanies <- renderText({paste("Nr of Companies: ", as.character(dim(CompaniesbyRegion)[1]))})
    
    output$tableSectors1 <- renderDataTable({CompaniesbyRegion}, options = list(lengthMenu = c(10, 30, 50), pageLength = 10, orderClasses = TRUE))
    output$tableSectors2 <- renderDataTable({CreateTable(CompaniesbyRegion,3)}, options = list(lengthMenu = c(10, 30, 50), pageLength = 10, orderClasses = TRUE))
    output$tableSectors3 <- renderDataTable({CreateTable(CompaniesbyRegion,4)}, options = list(lengthMenu = c(10, 30, 50), pageLength = 10, orderClasses = TRUE))
    
    
    if (Region == "USA") {
    
      mapRegion <- gvisGeoChart(   DB, 
                                   locationvar = "State", 
                                   colorvar = "Firms",
                                   sizevar = "Sectors",
                                   hovervar = "Display",
                                   options = list( region = "US",
                                                   displayMode="markers",
                                                   width = 940, 
                                                   height = 420, 
                                                   keepAspectRatio = TRUE,
                                                   colorAxis="{colors:['#4374e0', '#e7711c']}"

                                   )
      )
      
    }
    else {
      
      mapRegion <- gvisGeoChart(  DB, 
                                  locationvar = "State", 
                                  colorvar = "Firms",
                                  sizevar = "Sectors",
                                  hovervar = "Display",
                                  options = list( region = 150,
                                                  displayMode="markers", 
                                                  width = 940, 
                                                  height = 420, 
                                                  keepAspectRatio = TRUE,
                                                  colorAxis="{colors:['#4374e0', '#e7711c']}"
                                  )
      )
    }
    
    
 
  })
})

