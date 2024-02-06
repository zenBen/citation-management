
library(scholar)

get_all_publications = function(authorid) {
  # initializing the publication list
  all_publications = NULL
  # initializing a counter for the citations
  cstart = 0
  # initializing a boolean that check if the loop should continue
  notstop = TRUE
  
  while (notstop) {
    new_publications = try(get_publications(my_id, cstart=cstart), silent=TRUE)
    if (class(new_publications)=="try-error") {
      notstop = FALSE
    } else {
      # append publication list
      all_publications = rbind(all_publications, new_publications)
      cstart=cstart+20
    }
  }
  return(all_publications)
}

get_all_coauthors = function(my_id, me=NULL) {
  all_publications = get_publications(my_id)
  if (is.null(me))
    me = strsplit(get_profile(my_id)$name, " ")[[1]][2]
  # make the author list a character vector
  all_authors = sapply(all_publications$author, as.character)
  # split it over ", "
  all_authors = unlist(sapply(all_authors, strsplit, ", "))
  names(all_authors) = NULL
  # remove "..." and yourself
  all_authors = all_authors[!(all_authors %in% c("..."))]
  all_authors = all_authors[-grep(me, all_authors)]
  # make a data frame with authors by decreasing number of appearance
  all_authors = data.frame(name=factor(all_authors, 
                                       levels=names(sort(table(all_authors),decreasing=TRUE))))
}

get_abstract = function(pub_id, my_id) {
  print(pub_id)
  paper_url = paste0("http://scholar.google.com/citations?view_op=view_citation&hl=fr&user=",
                     my_id, "&citation_for_view=", my_id,":", pub_id)
  paper_page = htmlTreeParse(paper_url, useInternalNodes=TRUE, encoding="utf-8")
  paper_abstract = xpathSApply(paper_page, "//div[@id='gsc_descr']", xmlValue)
  return(paper_abstract)
}

get_all_abstracts = function(my_id) {
  all_publications = get_publications(my_id)
  all_abstracts = sapply(all_publications$pubid, get_abstract)
  return(all_abstracts)
}
