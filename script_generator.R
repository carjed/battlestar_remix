require(rvest)
require(dplyr)
require(stringr)

show <- "battlestar-galactica"
seriesURL <- paste0("http://www.springfieldspringfield.co.uk/view_episode_scripts.php?tv-show=", show)

# build df with episode indices
series <- read_html(seriesURL) %>%
  html_nodes(".season-episode-title") %>%
  html_text() %>%
  data.frame(episode=.) %>%
  mutate(episode=substr(episode, regexpr("s", episode)[1], nchar(episode)),
         url=paste0(seriesURL, "&episode=", episode))


getScript <- function(URL){
  script <- read_html(URL) %>% 
    html_node(".scrolling-script-container") %>%
    html_text() %>% 
    cleanText() %>%
    convert_text_to_sentences() 

  return(script)
}

# get all text from episode scripts
sentences <- unlist(lapply(ep_grid$url, function(x) getScript(x)), recursive=T)

# Get list of characters
characters <- toupper(unique(grep(":", word(sentences, 1), value=T)))

# Get list of effects used
testbr <- regmatches(sentences, regexpr("\\[(.*)\\]", sentences, perl=T))
# sents <- regmatches(sentences, regexpr("\\[(.*)\\]", sentences, perl=T))
effects <- data.frame(effect=unlist(strsplit(testbr, "(?<=[\\]])", perl=T))) %>%
  mutate(effect=gsub("^.*?\\[", "[", effect)) %>%
  group_by(effect) %>%
  summarise(n=n())

sents <- gsub("\\[|\\]", "", gsub(paste(gsub("\\[|\\]", "", effects$effect), collapse="|"), "", sent))
sents <- trimws(sents)

# Write show script to data file
showfile <- paste0(show,".txt")
write.table(sents, showfile, quote=F, sep="\t", col.names=F, row.names=F)


getLine <- function(){
  line <- character()
  validated <- NA
  
  while(is.na(validated)){
    quote <- system(paste("python sentence-generator.py", showfile, "2"), intern=TRUE)
    line <- paste(sample(characters, 1), quote)
    
    p_effects <- runif(1, 0, 1)
    
    if(p_effects > 0.6){
      n_effects <- rpois(1,1)
      line <- paste(paste(sample(effects$effect, n_effects), collapse=""), line)
      
    }
    
    if(length(grep(tolower(quote), sentences))!=1 & nchar(line)<=140 & str_count(quote, boundary("word"))>5){
      
      validated <- TRUE
    }
  }
  
  return(line)
}


getSample <- function(nreps){
    validated <- NA
    message <- character()
    while(is.na(validated)){
      
      line <- system("python sentence-generator.py battlestar.txt 2", intern=TRUE)
      
      str_count(line, boundary("word"))>5
      
      # Include on-topic tweets, restrict to 140 characters (&>5 words), and drops if generated string is in tweet db
      validated <- validated[grepl(searchstrsub, tolower(randlist)) &
        nchar(validated) <= 140 &
        # !grepl(searchrestr, tolower(validated)) &
        str_count(validated, boundary("word"))>5]
  
      # !(tolower(gsub('[[:punct:]]', '', randlist)) %in% tolower(gsub('[[:punct:]]', '', text2)))]
  
      validated <- validated[!grepl(tolower(gsub('[[:punct:]]', '', validated)), 
              tolower(gsub('[[:punct:]]', '', 
                           paste(text2, collapse=" "))), 
              fixed=TRUE)]
      
      message <- validated[1]
    
    }

    return(message)
  }



  


