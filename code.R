#Load the required text-mining library and some useful packages to manipulate data and functions

library(tm)
library(dplyr)

#build a corpus and a term-document matrix out of the data given


data <- readLines('text.txt')
cor <- VCorpus(VectorSource(data))

cor <- cor %>% 
  tm_map(content_transformer(tolower)) %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation)

tdm <- TermDocumentMatrix(cor)


#build a dictionary of words to use

dict <- findMostFreqTerms(tdm,50000,INDEX=rep(1,length(data)))$`1`

#build a function oneoffs that takes a string, and lists out all the possible 1-distance typos from it
#a given string of length l has l deletions, l-1 transpositions, 26l substitutions and 26(l+1) insertions

oneoffs <- function(string) {
  splitstring <- strsplit(string,"")[[1]]
  l <- length(splitstring)
  
  #declare variables to contain the different types of typos
  dels <- character(l)
  trans <- character(l-1)
  subs <- character(26*l)
  inserts <- character(26*(l+1))
  
  #sub-function that creates a numeric vector to swap the kth and k+1th entries
  transpose <- function(k,l) {
    order <- 1:l
    order[k] <- k+1
    order[k+1] <- k
    order
  }
  
  for(i in 1:l) {
    if (i < l) {
      trans[i] <- paste0(splitstring[transpose(i,l)],collapse="")
    }
    dels[i] <- paste0(splitstring[-i],collapse="")
  }
  
  for(i in 1:l) {
    base <- 26*(i-1)
    for(j in 1:26) {
      index <- base+j
      substitutedstring <- splitstring
      substitutedstring[i] <- letters[j]
      subs[index] <- paste0(substitutedstring,collapse="")
      
      beforei <- splitstring[0:(i-1)]
      afteri <- splitstring[i:l]
      inserts[index] <- paste0(c(beforei,letters[j],afteri),collapse="")
    }
  }
  
  for(j in 1:26) {
    k <- 26 * l + j
    inserts[k] <- paste0(c(splitstring,letters[j]),collapse="")
  }
  
  results <- unique(c(dels,trans,subs,inserts))
  results <- setdiff(results,c(string,""))
  #typos may not be unique, and may become an empty string
  results
}



#twooffs is a function that generates all possible two-off typos

twooffs <- function(string) {
  step1 <- oneoffs(string)
  
  #iteratively perform oneoffs on each of the one-off typos. li is used to store the oneoffs
  li <- list()
  
  for(i in 1:length(step1)) {
    li[[i]] <- oneoffs(step1[i])
  }
  #collapse the list into a character vector
  li <- unique(unlist(li))
  
  #take the set difference of 2-offs and 1 offs and the original string
  li <- setdiff(li,c(string,step1,""))
  li
}


#final execution

typofind <- function(string,typoprob) {
  #dataframe of possible candidates and their likelihood score
  candidates <- data.frame(word = "",score = 0,stringsAsFactors = FALSE)
  
  #take set intersection of the dictionary with the one-off and two-off typos
  #the dictionary is already ordered by frequency, so the most likely one-off typo will naturally be top
  oneoff <- intersect(names(dict),oneoffs(string))
  twooff <- intersect(names(dict),twooffs(string))
  
  #if the string is itself in the dictionary, put it as a candidate
  if(string %in% names(dict)) {
    candidates <- rbind(candidates,c(string,as.numeric(dict[string])))
  }
  if(length(oneoff) > 0) {
    word <- oneoff[1]
    score <- as.numeric(dict[word]) * typoprob
    candidates <- rbind(candidates,c(word,score))
  }
  if(length(twooff) > 0) {
    word <- twooff[1]
    score <- as.numeric(dict[word]) * (typoprob^2)
    candidates <- rbind(candidates,c(word,score))
  }
  
  #sort and return the most likely intended word
  if(nrow(candidates) > 0) {
    candidates <- head(candidates[order(candidates$score,decreasing = TRUE),],-1)
    print(candidates)
    return(candidates[1,1])
  }
  else {
    return(NULL)
  }
}