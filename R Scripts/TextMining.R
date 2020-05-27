library(tm)
library(wordcloud)

#Change the directory location
cname <- file.path("G:\\Data Visualization\\Final Assignment\\Content\\TextMining\\2004\\")
docs <- Corpus(DirSource(cname))

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")
docs <- tm_map(docs, toSpace, "â")
docs <- tm_map(docs, toSpace, "???")
docs <- tm_map(docs, toSpace, """)
docs <- tm_map(docs, toSpace, "å")
docs <- tm_map(docs, toSpace, "'")


docs <- tm_map(docs,tolower)
docs <- tm_map(docs,removeWords, stopwords("english"))
docs <- tm_map(docs,removeNumbers)
docs <- tm_map(docs,removePunctuation)
docs <- tm_map(docs,stripWhitespace)
docs
dtm <- DocumentTermMatrix(docs)
m <- as.matrix(dtm)
v <- sort(colSums(m),decreasing=TRUE)
head(v,14)
words <- names(v)
d <- data.frame(word=words, freq=v, stringsAsFactors = TRUE)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=2000, random.order=FALSE, 
          colors=brewer.pal(8, "Dark2"))