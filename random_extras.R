# MAKE CO-AUTHOR COUNT BARCHART
all_authors = get_all_coauthors(my_id, me="Cowley")
library(ggplot2)
p = ggplot(all_authors, aes(x=name)) + geom_bar(fill=brewer.pal(3, "Set2")[2]) +
             xlab("co-author") + theme_bw() + theme(axis.text.x = element_text(angle=90, hjust=1))
print(p)


# MAKE A WORD CLOUD FROM FREQUENT WORDS IN ABSTRACTS!
library(XML)
all_abstracts = get_all_abstracts(my_id)
library(tm)
# transform the abstracts into "plan text documents"
all_abstracts = lapply(all_abstracts, PlainTextDocument)
# find term frequencies within each abstract
terms_freq = lapply(all_abstracts, termFreq,
                    control=list(removePunctuation=TRUE, stopwords=TRUE, removeNumbers=TRUE))
# finally obtain the abstract/term frequency matrix
all_words = unique(unlist(lapply(terms_freq, names)))
matrix_terms_freq = lapply(terms_freq, function(astring) {
  res = rep(0, length(all_words))
  res[match(names(astring), all_words)] = astring
  return(res)
})
matrix_terms_freq = Reduce("rbind", matrix_terms_freq)
colnames(matrix_terms_freq) = all_words
# deduce the term frequencies
words_freq = apply(matrix_terms_freq, 2, sum)
# keep only the most frequent and after a bit of cleaning up (not shown) make the word cloud
important = words_freq[words_freq > 10]
library(wordcloud)
wordcloud(names(important), important, random.color=TRUE, random.order=TRUE,
          color=brewer.pal(12, "Set3"), min.freq=1, max.words=length(important), scale=c(3, 0.3))