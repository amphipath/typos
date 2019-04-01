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

#take a look at the most frequent words in this dataset, just to have a sense of what we're working with and whether the dataset has any particular quirks

list <- findMostFreqTerms(tdm,100,INDEX=rep(1,length(data)))$`1`

list

# the      and     that      was      his     with      had      for      not     from      but      you      her 
# 79403    38094    12090    11368    10014     9706     7364     6825     6579     5688     5603     5363     5255 
# him    which     were      all     this      she     they      are     have     said      one      who    their 
# 5165     4776     4293     4079     3974     3858     3842     3605     3487     3456     3215     2994     2951 
# what     when    there     been      may     them     into      its     more      out    would   prince      did 
# 2920     2863     2830     2598     2538     2218     2120     2041     1988     1957     1949     1893     1868 
# only   pierre    could      now      has     will     then     some     time      man    about    after    other 
# 1861     1785     1695     1666     1597     1564     1548     1526     1509     1502     1492     1485     1484 
# such   before     very      how   should     your     over     than    these      new      any    those    first 
# 1405     1347     1335     1297     1290     1274     1259     1204     1201     1200     1195     1188     1155 
# himself     well      old     face     down     upon      men      see  natasha      two   andrew      our   french 
# 1150     1143     1138     1122     1113     1108     1104     1094     1093     1071     1065     1065     1059 
# same     know     like  without     went     made   little     came   states    where    under     must     long 
# 1051     1041     1017     1006     1005      999      997      976      963      961      955      954      940 
# even     eyes     come princess    being     room    still     most  thought 
# 930      930      929      918      912      904      904      902      899 

#looks pretty fine, although the presence of some terms liek "prince", "french", "pierre", "natasha" shows a bit of bias toward narrative terms

#depending on the context this typo-fixer is used for we may have to use a different dictionary but this is the data we're given so just go along with it for now

#thoughts on building a metric function for typos

#basic axioms that any metric needs to obey:

#if it matches a dictionary word exactly the metric must be 0
#the more typos the further away it is
#the above rule also means that there must be some sort of definition of what a "basic" or "simple" typo is

#in this model we choose to use 4 basic kinds of typos: deletion (somthing), insertion (somerthing), swapping (soemthing), substitution (spmething)

#we consider all possible typos as equivalently likely for now. so given the typo "fluck", "pluck" is equally likely to "luck"

#initial thoughts: we can try to operate on a sentence word-by-word. this will simplify the task to just requiring a typo-fixer that fixes one word but loses the power of fixing using context

#when restricting our scope to just fixing one word, it will also allow us to make another simplification; it's pretty unlikely for a word to have two typos and almost never does a word have 3

#so let's just try to fix two typos

#a useful property about the basic typox used above is that they are reversible. application of a deletion typo requires an insertion to return it, and so on

#so given a potentially typo'd word, we can search for dictionary words by applying all of those typos by just applying the typos to them successively



#build a dictionary of words to use, let's use 10000

dict <- findMostFreqTerms(tdm,10000,INDEX=rep(1,length(data)))$`1`

#build a function oneoffs that takes a string, and lists out all the possible 1-distance typos from it

#a given string of length l has l deletions, l-1 transpositions, 26l substitutions and 26(l+1) insertions

oneoffs <- function(string) {
  splitstring <- strsplit(string,"")[[1]]
  l <- length(splitstring)
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
  results <- c(dels,trans,subs,inserts)
  print(dels)
  print(trans)
  print(subs)
  print(inserts)
  results
}

