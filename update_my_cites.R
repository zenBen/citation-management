
library(dplyr)

setwd('~/Dropbox/CV_MyJob_Professional_stuff/CurriculumVitae/CitationManagement')

# SCRAPE MY GOOGLE SCHOLAR PAGE
source("scrape_scholar.R")
my_id = "0Nzig9AAAAAJ" # Google Scholar ID for Ben Cowley
schlr_pubs = get_publications(my_id)
# summary(schlr_pubs$cites)
write.csv(select(schlr_pubs, title, year, cites), file = "gen/scholar_cites.csv")# WRITE TO CSV

# READ SCOPUS FROM DOWNLOADED CSV
# sco_pubs <- read.csv('scopus_manual.csv')
source("scopusAPI-master/scopusAPI.R") # Contains my Elsevier API key "61b72f5e1b8cc52cf30cf5f68d87cbe9"
theXML <- searchByID(theIDs = "scopusEID.txt", idtype = "eid", outfile = 'gen/scopus.csv')
sco_pubs <- extractXML(theXML)


# UPDATE CITATION COUNTS IN ORIGINAL DATA AND WRITE TO HANDY FILES
A1 <- read.delim('orig/A1orig.csv', quote = "")
A1 <- updateScholar(A1, schlr_pubs)
A1 <- updateScopus(A1, sco_pubs)
write.table(A1, file = "gen/A1.csv", sep = "\t", quote = FALSE, na = "-", row.names = FALSE, col.names = FALSE)

A2 <- read.delim('orig/A2orig.csv', quote = "")
A2 <- updateScholar(A2, schlr_pubs)
A2 <- updateScopus(A2, sco_pubs)
write.table(A2, file = "gen/A2.csv", sep = "\t", quote = FALSE, na = "-", row.names = FALSE, col.names = FALSE)

A3 <- read.delim('orig/A3orig.csv', quote = "")
A3 <- updateScholar(A3, schlr_pubs)
A3 <- updateScopus(A3, sco_pubs)
write.table(A3, file = "gen/A3.csv", sep = "\t", quote = FALSE, na = "-", row.names = FALSE, col.names = FALSE)

A4 <- read.delim('orig/A4orig.csv', quote = "")
A4 <- updateScholar(A4, schlr_pubs)
A4 <- updateScopus(A4, sco_pubs)
write.table(A4, file = "gen/A4.csv", sep = "\t", quote = FALSE, na = "-", row.names = FALSE, col.names = FALSE)

B1 <- read.delim('orig/B1orig.csv', quote = "")
G3 <- read.delim('orig/G3orig.csv', quote = "")

# COMBINE ALL CITATION-COUNT TABLES TO MAKE PUBLICATIONS TEX FILE
library(readr)
sec1 <- read_file("orig/sec-pub1.txt")
txA1 <- read_file("gen/A1.csv")
sec2 <- read_file("orig/sec-pub2.txt")
txA2 <- read_file("gen/A2.csv")
sec3 <- read_file("orig/sec-pub3.txt")
txA3 <- read_file("gen/A3.csv")
sec4 <- read_file("orig/sec-pub4.txt")
txA4 <- read_file("gen/A4.csv")
sec5 <- read_file("orig/sec-pub5.txt")

write_file(paste0(sec1, txA1, sec2, txA2, sec3, txA3, sec4, txA4, sec5), "../Latex/sec-publications.tex")

# # MAKE CO-AUTHOR COUNT BARCHART
# all_authors = get_all_coauthors(my_id, me="Cowley")
# library(ggplot2)
# p = ggplot(all_authors, aes(x=name)) + geom_bar(fill=brewer.pal(3, "Set2")[2]) +
#              xlab("co-author") + theme_bw() + theme(axis.text.x = element_text(angle=90, hjust=1))
# print(p)
# 
# 
# # MAKE A WORD CLOUD FROM FREQUENT WORDS IN ABSTRACTS!
# library(XML)
# all_abstracts = get_all_abstracts(my_id)
# library(tm)
# # transform the abstracts into "plan text documents"
# all_abstracts = lapply(all_abstracts, PlainTextDocument)
# # find term frequencies within each abstract
# terms_freq = lapply(all_abstracts, termFreq, 
#                     control=list(removePunctuation=TRUE, stopwords=TRUE, removeNumbers=TRUE))
# # finally obtain the abstract/term frequency matrix
# all_words = unique(unlist(lapply(terms_freq, names)))
# matrix_terms_freq = lapply(terms_freq, function(astring) {
#   res = rep(0, length(all_words))
#   res[match(names(astring), all_words)] = astring
#   return(res)
# })
# matrix_terms_freq = Reduce("rbind", matrix_terms_freq)
# colnames(matrix_terms_freq) = all_words
# # deduce the term frequencies
# words_freq = apply(matrix_terms_freq, 2, sum)
# # keep only the most frequent and after a bit of cleaning up (not shown) make the word cloud
# important = words_freq[words_freq > 10]
# library(wordcloud)
# wordcloud(names(important), important, random.color=TRUE, random.order=TRUE,
#           color=brewer.pal(12, "Set3"), min.freq=1, max.words=length(important), scale=c(3, 0.3))