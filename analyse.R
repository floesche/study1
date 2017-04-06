library('rjson')
library('plyr')
library('jsonlite')

setwd("/home/paul/Desktop/pilot/data")
path <- "p1"
survey <- "sms"

process_json_files <- function(path, survey) {
  f <- paste(path,'/', path, '_', survey, '.json', sep='')
  data <- jsonlite::stream_in(file(f))
  # use gather or melt
  #  data <- fromJSON(file=f)
  
  df <- data.frame()
  # a survey is a list of lists
  ldply(survey, function(l) {
    Value
    
  })
}

bigval <- NULL
for(x in 1:10) {
  bigval <- c(bigval,data[[x]]$value)
}


paths <- list.files(".")
sms <- ldply(paths, process_json_files, 'sms')