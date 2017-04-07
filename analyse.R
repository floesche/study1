library('plyr')
library('jsonlite')

setwd("/home/paul/Desktop/pilot/data")

#' Process expfactory survey data
#' @param p Participant number
#' @param survey Survey name
#' @return Data frame (long format)
# http://expfactory.readthedocs.io/en/latest/development.html#contributing-to-surveys
process_expfactory_survey <- function(p, survey) {
  f    <- paste(p,'/', p, '_', survey, '.json', sep='')
  df   <- jsonlite::stream_in(file(f))
  df$p <- p

  df$question     <- as.numeric(apply(df[1], 2, function(x) stringr::str_match(x,'survey_(\\d+)')[,2]))
  df[,"question"] <- df[,"question"] - 1 # questions start at 2
  df$name         <- survey
  df              <- df[, !(names(df) %in% c('text','options'))]
  names(df)[names(df) == 'name'] <- 'survey'
  return(df)
}

process_surveys <- function (s) {
  return(ldply(paths, process_expfactory_survey, s))
}

paths   <- list.files(".")
surveys <- c('demographics','sms','ffmq')
df      <- ldply(surveys, process_surveys)
