#!/usr/bin/Rscript

# sink(".log")

suppressMessages(require(rvest))
suppressMessages(require(dplyr))
suppressMessages(require(stringr))
suppressMessages(require(yaml))

# isRStudio <- Sys.getenv("RSTUDIO") == "1"
# if(isRStudio){
#   this.dir <- dirname(parent.frame(2)$ofile)
#   setwd(this.dir)
# }

tweet <- "test"
args = commandArgs(trailingOnly=TRUE)
# print(commandArgs())
if(length(args)==1){
  tweet <- args[1]  
}


# Enter show name as formatted on the Springfield! Springfield! website 
# (http://www.springfieldspringfield.co.uk)
show <- "battlestar-galactica"
seriesURL <- paste0("http://www.springfieldspringfield.co.uk/view_episode_scripts.php?tv-show=", show)

# Function scrapes the episode script and cleans up the text
getScript <- function(URL){
  script <- read_html(URL) %>% 
    html_node(".scrolling-script-container") %>%
    html_text() %>% 
    cleanText() %>%
    convert_text_to_sentences() 

  return(script)
}

# Define input datasets
showfile <- paste0(show, ".txt")
charfile <- paste0(show, "_chars.txt")
effectfile <- paste0(show, "_effects.txt")

# Only need to build datasets once
if(!all(file.exists(showfile, charfile, effectfile))){
  # build df with episode indices
  series <- read_html(seriesURL) %>%
    html_nodes(".season-episode-title") %>%
    html_text() %>%
    data.frame(episode=.) %>%
    mutate(episode=substr(episode, regexpr("s", episode)[1], nchar(episode)),
           url=paste0(seriesURL, "&episode=", episode))
  
  # get all text from episode scripts
  sentences <- unlist(lapply(ep_grid$url, function(x) getScript(x)), recursive=T)
  
  # Get list of characters and frequencies
  characters <- data.frame(chars=toupper(grep(":", word(sentences, 1), value=T))) %>%
    mutate(chars=gsub(":.*",":",chars)) %>%
    group_by(chars) %>%
    summarise(n=n()) %>% 
    arrange(desc(n)) %>%
    mutate(wt=n/sum(n))
  
  # Get list of effects used
  effects <- data.frame(effect=unlist(strsplit(testbr, "(?<=[\\]])", perl=T))) %>%
    mutate(effect=gsub("^.*?\\[", "[", effect)) %>%
    group_by(effect) %>%
    summarise(n=n())
  
  # Strip effects from sentences
  sents <- gsub("\\[|\\]", "", gsub(paste(gsub("\\[|\\]", "", effects$effect), collapse="|"), "", sents))
  sents <- trimws(sents)
  
  # Write show script to data file
  write.table(sents, showfile, quote=F, sep="\t", col.names=F, row.names=F)
  write.table(characters, charfile, quote=F, sep="\t", col.names=T, row.names=F)
  write.table(effects, effectfile, quote=F, sep="\t", col.names=T, row.names=F)
} else {
  # Read data if already cached
  sents <- readLines(showfile)
  characters <- read.table(charfile, header=T, stringsAsFactors=F, sep="\t")
  effects <- read.table(effectfile, header=T, stringsAsFactors=F, sep="\t")
}

# Function calls the sentence-generator.py script to generate a tweet
getTweet <- function(){
  line <- character()
  validated <- NA
  
  while(is.na(validated)){
    quote <- system(paste("python sentence-generator.py", showfile, "2"), intern=TRUE)
    
    line <- paste(sample(characters$chars, 1, prob=characters$wt), quote)
    
    p_effects <- runif(1, 0, 1)
    
    if(p_effects > 0.6){
      n_effects <- rpois(1,1)
      if(n_effects>0){
        line <- paste(paste(sample(effects$effect, n_effects), collapse=""), line)  
      }
    }
    
    if(length(grep(tolower(quote), sentences))!=1 & 
       nchar(line)<=140 & 
       str_count(quote, boundary("word"))>5){
      validated <- TRUE
    }
  }
  
  return(line)
}

txt<-getTweet()

# tweet <- 1
if(tweet=="tweet"){
  suppressMessages(require(twitteR))

  # must create a '_config.yaml' file specifying your unique access tokens to use the twitter API
  # See '_example_config.yaml' for an example
  data <- yaml.load_file("_config.yaml")
  setup_twitter_oauth(data$api_key, data$api_secret, data$access_token, data$access_token_secret)
  # sink()
  # Generates and posts a tweet
  updateStatus(txt)
} else {
  # sink()
  txt
}

# file.remove(".log")

  


