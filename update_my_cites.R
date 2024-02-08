library(dplyr)
library(readr)
library(gsubfn)
library(here)
source("citeman_utils.R")

# repo <- '~/Benslab/myTools/citation-management'
pubfile <- file.path(here(), '../CV/cv/sec-publications.tex')
outfile <- file.path(here(), '../CV/cv/sec-output.tex')

# SCRAPE MY GOOGLE SCHOLAR PAGE
source("scrape_scholar.R")
my_id = "0Nzig9AAAAAJ" # Google Scholar ID for Ben Cowley
schlr_pubs = get_publications(my_id) # summary(schlr_pubs$cites)
write.csv(select(schlr_pubs, title, year, cites), file = "gen/scholar_cites.csv")# WRITE TO CSV
schlr_cite <- get_citation_history(my_id)
schlr_prof <- get_profile(my_id)

# READ SCOPUS FROM DOWNLOADED CSV
# sco_pubs <- read.csv('scopus_manual.csv')
source("scopusAPI-master/scopusAPI.R") # Contains my Elsevier API key "61b72f5e1b8cc52cf30cf5f68d87cbe9"
scps <- read.csv(file.path(here(), 'orig/scopus-manual.csv'))
theXML <- searchByID(theIDs = scps$EID, idtype = "eid", outfile = 'gen/scopus.csv')
sco_pubs <- extractXML(theXML)
sco_cite <- as.numeric(sco_pubs$timescited)

## UPDATE CITATION COUNTS IN ORIGINAL DATA AND WRITE TO HANDY FILES, THEN MAKE LATEX TABLES ----
doMARX <- TRUE # add identifying marks from csv sources before each publication
doNUMS <- FALSE # add consecutive number of each publication after each publication

NUM <- 0 # how many publications we have to start
rm(jrnls, chaps, confs, prpts, pstrs, books, A1.1st, A2.1st, A3.1st, A4.1st, B1.1st, B3.1st, C.1st)

list[texA1, NUM, A1.1st] <- refs2tex("orig/A1orig.csv", "gen/A1.csv", schlr_pubs, sco_pubs,
                             "A1 -- Original scientific articles", NUM,
                             doMARX = doMARX, doNUMS = doNUMS)

list[texA2, NUM, A2.1st] <- refs2tex("orig/A2orig.csv", "gen/A2.csv", schlr_pubs, sco_pubs,
                             "A2 -- Review", NUM,
                             doMARX = doMARX, doNUMS = doNUMS)
jrnls <- NUM

list[texA3, NUM, A3.1st] <- refs2tex("orig/A3orig.csv", "gen/A3.csv", schlr_pubs, sco_pubs,
                             "A3 -- Contribution to book", NUM,
                             doMARX = FALSE, doNUMS = doNUMS)
chaps <- NUM - jrnls

list[texA4, NUM, A4.1st] <- refs2tex("orig/A4orig.csv", "gen/A4.csv", schlr_pubs, sco_pubs,
                             "A4 -- Article in conference publication", NUM,
                             doMARX = doMARX, doNUMS = doNUMS)
confs <- NUM - (jrnls + chaps)

list[texB1, NUM, B1.1st] <- refs2tex("orig/B1orig.csv", "gen/B1.csv", schlr_pubs, sco_pubs,
                             "B1 -- Unreferred journal article (all are OA)", NUM,
                             doCITE = FALSE, doMARX = FALSE, doNUMS = doNUMS)
prpts <- NUM - (jrnls + chaps + confs)

list[texB3, NUM, B3.1st] <- refs2tex("orig/B3orig.csv", "gen/B3.csv", schlr_pubs, sco_pubs,
                             "B3 -- Unreferred conference proceedings (posters and oral presentations)", NUM,
                             doCITE = FALSE, doMARX = FALSE, doNUMS = doNUMS)
pstrs <- NUM - (jrnls + chaps + confs + prpts)

list[texC, NUM, C.1st] <- refs2tex("orig/Corig.csv", "gen/C.csv", schlr_pubs, sco_pubs,
                         "C -- Scientific Books (monographs)", NUM,
                         doMARX = FALSE, doNUMS = doNUMS)
books <- NUM - (jrnls + chaps + confs + prpts + pstrs)

secFin <- read_file("orig/sec-DFGI.txt")


# BUILD BIBLIO-INTRO WITH FRESH CITE-COUNTS, INDICES
biblio <- read_file("orig/sec-biblio.txt")
# sec1 <- biblio_build(biblio, sum(sco_cite), schlr_prof$total_cites, get_h(sco_cite), schlr_prof$h_index)
sec1 <- biblio_build(biblio, 
                       jrnls, chaps, confs, pstrs, prpts, books, 
                       A1.1st, A2.1st, A3.1st, A4.1st, B1.1st, B3.1st, C.1st,
                       sum(sco_cite), schlr_prof$total_cites, 
                       get_h(sco_cite), schlr_prof$h_index, 
                       get_i10(sco_cite), schlr_prof$i10_index,
                       doMARX = doMARX)

# COMBINE ALL CITATION-COUNT TABLES TO MAKE PUBLICATIONS TEX FILE
pubpg <- "\\ifnum\\PUBPG>2\n\n"
write_file(paste0(sec1, texA1, texA2, texA3, texA4, pubpg, texB1, texB3, texC, secFin), pubfile)



#  DO CV-SECTION 'OUTPUT' WITH FRESH CITE-COUNTS, INDICES
output <- read_file("orig/sec-output.txt")
# output <- biblio_header(output, sum(sco_cite), schlr_prof$total_cites, get_h(sco_cite), schlr_prof$h_index)
output <- biblio_build(output, 
                       jrnls, chaps, confs, pstrs, prpts, books, 
                       A1.1st, A2.1st, A3.1st, A4.1st, B1.1st, B3.1st, C.1st,
                       sum(sco_cite), schlr_prof$total_cites, 
                       get_h(sco_cite), schlr_prof$h_index, 
                       get_i10(sco_cite), schlr_prof$i10_index)
write_file(output, outfile)
