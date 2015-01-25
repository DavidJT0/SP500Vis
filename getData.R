##Gets the data from external tables (Wikipedia), cleans it and formats the data-frames

library(XML)

##Download data frame of S&P500
  url <- "http://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
  Companies <- readHTMLTable(readLines(url), which=1)
    Companies <- Companies[,c(-3,-7,-8)]
    names(Companies) <- make.names(names(Companies))

##Download Codes of US states
  url2 <- "http://en.wikipedia.org/wiki/List_of_U.S._state_abbreviations"
  StatesCodes <- readHTMLTable(readLines(url2), which=1)
    StatesCodes <- StatesCodes[4:54,c(1,4)]
    row.names(StatesCodes) <- as.character(c(1:51))
    names(StatesCodes) <- c("State", "Code")
    StatesCodes[,1] <- as.character(StatesCodes[,1])
    StatesCodes[,2] <- as.character(StatesCodes[,2])

##Format the states & Database
  Stt <- character(length(Companies[,5])); Stt <- gsub("","XX",Stt)
    for (i in 1:dim(StatesCodes)[1]) {
      Stt[c(grep(StatesCodes[i,1],Companies[,5]))] <- StatesCodes[i,1]
    }
  Companies$State <- Stt
  Companies$isUSA <- character(length(Companies[,5]))
  Companies$isUSA[Companies$State != "XX"] <- "USA"
  Companies$isUSA[Companies$State == "XX"] <- "nonUSA"
  Companies$State[Companies$State == "XX"] <-  unlist(lapply(strsplit(as.character(Companies[Companies$State == "XX",5]), ","), function(e){e[length(e)]}))
  Companies$isUSA <- as.factor(Companies$isUSA)
  Companies <- droplevels(Companies[Companies$State != " Bermuda",])
  rm(url, url2, StatesCodes, i, Stt)
