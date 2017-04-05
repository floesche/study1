library('rjson')
library('plyr')
setwd("/home/paul/Desktop/pilot/data")

process_json_files <- function(path, survey) {
  prefix <- paste(path,'/', path, '_', sep='')
  survey <- fromJSON(file=paste(prefix,survey,'.json',sep=''))
  df <- data.frame()
  # a survey is a list of lists
  lapply(survey, function(l) {
    print(l)
    
  })
}

paths <- list.files(".")
# paths
sms <- ldply(paths, process_json_files(survey='sms'))