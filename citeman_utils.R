# calculate h-index of a vector of random integers
get_h <- function(vec){
  sortvec <- sort(vec, decreasing = TRUE)
  for (ix in 1:length(vec)){
    if (sortvec[ix] < ix){
      h = ix - 1
      break
    }
  }
  return(h)
}

get_i10 <- function(vec){
  return(sum(vec > 9))
}

# FUNCTIONS TO REFRESH CITATION COUNTS, FOR:
# GOOGLE SCHOLAR
updateScholar <- function(cv_pubs, schorape){
  if("google" %in% colnames(cv_pubs))
  {
    for (v in 1:NROW(cv_pubs)){
      scrapes <- tolower(gsub('[[:punct:] ]+', ' ', as.character(schorape$title)))
      cv_cite <- tolower(gsub('[[:punct:] ]+', ' ', as.character(cv_pubs[v,]$title)))
      idx = pmatch(scrapes, cv_cite)
      if (any(!is.na(idx))){
        cv_pubs[v,]$google <- as.numeric(schorape[!is.na(idx),]$cites)
      }
    }
  }
  return(cv_pubs)
}
# SCOPUS
updateScopus <- function(cv_pubs, scorape){
  if("scopus" %in% colnames(cv_pubs))
  {
    for (v in 1:NROW(cv_pubs)){
      scrapes <- tolower(gsub('[[:punct:] ]+', ' ', as.character(scorape$articletitle)))
      cv_cite <- tolower(gsub('[[:punct:] ]+', ' ', as.character(cv_pubs[v,]$title)))
      idx = pmatch(scrapes, cv_cite)
      if (any(!is.na(idx))){
        cv_pubs[v,]$scopus <- as.numeric(scorape[!is.na(idx),]$timescited)
      }
    }
  }
  return(cv_pubs)
}

# ADD LIVE CITE COUNTS AND H-INDEX TO HEADER
biblio_header <- function(content, sco_n, schlr_n, sco_h, schlr_h){
  tex <- paste0(content, " ", sco_n, " | ", schlr_n, 
                ", \\quad {\\it h}-index ", sco_h, " | ", schlr_h, 
                " }\n\n\\vspace{10pt}\n")
  return(tex)
}

# ADD LIVE CITE COUNTS AND H-INDEX TO GIVEN HEADER
biblio_build <- function(content, jrnls, chaps, confs, pstrs, prpts, books, A1.1st, A2.1st, A3.1st, A4.1st, B1.1st, B3.1st, C.1st, sco_n, schlr_n, sco_h, schlr_h, sco_i10, schlr_i10, doMARX = FALSE){
  if (!doMARX){
    content <- gsub('Open access', '%Open access', content)
    content <- gsub('Papers with', '%Papers with', content)
  }
  if (A3.1st + C.1st == books + chaps){
    book.1st <- 'all'
  }else{
    book.1st <- A3.1st + C.1st
  }
  dat <- paste0("{\\it ", jrnls + chaps + confs + books, " peer reviewed publications}:",
                "\\begin{itemize}\n \\item ",
                jrnls, " journal papers (", A1.1st + A2.1st + 1, " as first or joint-first author); \n \\item ", #TODO hack for Ahonen SciRep paper
                books - 1, " book, ", chaps, " book chapters (", book.1st, " as first author); \n \\item ",
                confs, " conference proceedings (", A4.1st, " as first author); \n \\item ",
                "monograph doctoral dissertation\n \\end{itemize} \\\\ \n",
                "{\\it Unreviewed works, and software or other research outputs}:\n",
                "\\begin{itemize}\n \\item ",
                pstrs, " conference posters/oral presentations, and over 10 invited presentations; \n \\item ", #FIXME HOW TO COUNT INVITED PRESENTATIONS?
                prpts, " preprints (", B1.1st, " as first author); \n \\item ",
                "6 significant software repositories\n \\end{itemize} \\\\ \n",                                          #FIXME HOW TO COUNT CODE REPOS??
                "{\\noindent\\bf Total citations (Scopus|Scholar): ", sco_n, " | ", schlr_n, 
                ", \\quad {\\it h}-index ", sco_h, " | ", schlr_h, 
                ", \\quad {\\it i10}-index ", sco_i10, " | ", schlr_i10, 
                " }\n\n\\vspace{10pt}\n")
  ltb <- ltabulary("Bibliometrics", "L", dat, FALSE)
  tex <- paste0(content, "\n ", ltb)
  return(tex)
}

# Make a Latex ltabulary table with given title, cols, and content
ltabulary <- function(title, cols, content, headerline = TRUE){
  colN <- nchar(cols)
  if (headerline){
    headerline = ' \\hline'
  }else{
    headerline = ''
  }
  tex <- paste0("\\begin{ltabulary}{", cols, "}\n\\multicolumn{", colN, 
                "}{l}{{\\bf ", title, 
                ".}} \\\\", headerline, 
                "\n\\endfirsthead\n\\multicolumn{", colN, 
                "}{l}{{\\bf ", title, 
                "{\\it - cont.}}} \\\\", headerline, 
                "\n\\endhead\n", content, 
                "\n\\end{ltabulary}\n\n\n")
  return(tex)
}

# TURN REFS INTO LATEX FOR ONE JUFO CATEGORY 
refs2tex <- function(inf, outf, sclr, scop, ttl, NUM, doCITE = TRUE, doMARX = TRUE, doNUMS = TRUE){
  dat <- read.delim(inf, quote = "")
  dat <- updateScholar(dat, sclr)
  dat <- updateScopus(dat, scop)
  
  if (doNUMS){
    dat$ampn <- rep("&", nrow(dat))
    dat$nums <- seq(NUM + 1, NUM + nrow(dat), 1)
  }
  NUM <- NUM + nrow(dat)
  Num1st <- sum(unlist(lapply(as.vector(dat$authors), startsWith, '\\B{Cowley')))
  
  if (!doMARX && any(c("marks", "amp2") %in% colnames(dat))){
    dat <- dat |> select(!any_of(c("marks", "amp2"))) 
  }
  if (!doCITE && any(c("scopus", "bar", "google", "amp1") %in% colnames(dat))){
    dat <- dat |> select(!any_of(c("scopus", "bar", "google", "amp1")))
  }
  dat$lineend <- c(rep("\\\\", nrow(dat) - 1), "")
  
  write.table(dat, file = outf, sep = "\t", quote = FALSE, na = "", row.names = FALSE, col.names = FALSE)
  dat <- read_file(outf)
  
  cols <- c("l", "L", "L", "l")
  cols <- paste(cols[c(doCITE, doMARX, TRUE, doNUMS)], collapse = '')
  tex <- ltabulary(ttl, cols, dat)
  
  return(list(tex, NUM, Num1st))
}