library('plyr')
library('jsonlite')

setwd("/home/paul/Desktop/pilot/data")

process_json_files <- function(path, survey) {
  f    <- paste(path,'/', path, '_', survey, '.json', sep='')
  df   <- jsonlite::stream_in(file(f))
  df$p <- substr(path,2,nchar(path))    # participant number

  df$question     <- as.numeric(apply(df[1], 2, function(x) stringr::str_match(x,'survey_(\\d+)')[,2]))
  df[,"question"] <- df[,"question"] - 1 # questions start at 2
  df$name         <- survey
  df              <- df[, !(names(df) %in% c('text','options'))]
  names(df)[names(df) == 'name'] <- 'survey'
  return(df)
}

process_surveys <- function (s) {
  return(ldply(paths, process_json_files, s))
}

paths   <- list.files(".")
surveys <- c('demographics','sms','ffmq')
df      <- ldply(surveys, process_surveys)
