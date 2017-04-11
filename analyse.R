library('plyr')
library('jsonlite')
library(tidyverse)
library(stringr)

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

######################
# Solution 2
######################


#' Alternative solution to process expfactory survey data
#' 
#' This solution uses read_json instead of stream_in. This solves a number of 
#' problems: there is no more warning about incomplete last lines. Also the 
#' files are properly closed. All the transformations are done in one pipe –
#' this provides a more concise interface than changing names(df) and modifying
#' vectors.
#' 
#' @param p Participant Number
#' @param survey Survey name
#'   
#' @return Data frame
process_expfactory_survey2 <- function(p, survey) {
  f     <- paste(p, "/", p, "_", survey, ".json", sep = "")
  df    <- jsonlite::read_json(f, simplifyVector = TRUE)
  df %>%
    mutate(
      p = p,
      question = parse_number(name) - 1,
      survey = survey) %>%
    select(survey, value, p, question)
}

#' Alternative solution to process expfactory survey data
#' 
#' This is the function called from the main script. It adds another variable to
#' determine the base path, which is read from the environment in the previous
#' example process_surveys().
#' 
#' @param s list of surveys to process
#' @param base_path path to search (instead of global variable as in
#'   process_survey())
#'   
#' @return Data frame
process_surveys2 <- function(s, base_path) {
  ldply(base_path, process_expfactory_survey2, s)
}


######################
# Solution 3
######################


#' Process expfactory survey data
#'
#' @param base_path data path
#'
#' @return data frame with [survey, value, participant, question]
#'
#' @examples
process_surveys3 <- function(base_path){
  all_json_files = list.files(base_path, pattern = ".*\\.json", recursive = TRUE)
  df <- NULL
  for (f in all_json_files ) {
    df <- bind_rows(
      df, 
      jsonlite::read_json(f, simplifyVector = TRUE) %>% mutate(file = f)
      )
  }
  
  df %>%
    mutate( 
#      survey = str_extract(name, ".*(?=_survey?)"),    # use survey name from JSON, different result and as an alternative to next line
      survey = str_extract(file, "(?<=_).*?(?=.json)"), # use survey name from filename
      p = str_extract(file, "^[:digit:]*(?=/?)"),       # extract the participant number from the directory name 
      question = parse_number(name) - 1) %>%
    select(survey, value, p, question)
}

paths   <- list.files(".")
surveys <- c("demographics", "sms", "ffmq")
df      <- ldply(surveys, process_surveys)          # Original solution
df2     <- ldply(surveys, process_surveys2, paths)  # using tidyverse + keep same API
df3     <- process_surveys3(".")                    # using tidyvers + different API


## To compare speed of different solutions
microbenchmark::microbenchmark(
  ldply(surveys, process_surveys),
  ldply(surveys, process_surveys2, paths),
  process_surveys3(".")
)
