# Install and load necessary packages
library(tidyverse)
library(readxl)
library(bibtex)
library(xml2)

# This url fetches a html report with nice APA refs categorised by TENK,
# presumably only if one is signed into tuhat already
# https://tuhat.helsinki.fi/admin/services/searchresultexport/personal/html/apa


# Find Pure pubs file patterns from the directory and read
dir <- "orig"
file <- "Pure publications - [0-9]{8}."
files <- list.files(dir, pattern = paste0(file, "xls"), full.names = TRUE)
file_path <- files[1]
data <- read_excel(file_path)

files <- list.files(dir, pattern = paste0(file, "bib"), full.names = TRUE)
file_path <- files[1]
bibs <- read.bib(file_path)

files <- list.files(dir, pattern = paste0(file, "xml"), full.names = TRUE)
file_path <- files[1]
xmlr <- read_xml(file_path)

# Function to create APA style reference string
create_apa_reference <- function(row) {
  # Extract authors
  author_columns <- grep("Contributors > Person", names(row))
  authors <- sapply(seq(1, length(author_columns), by = 4), function(i) {
    first_name <- row[[author_columns[i]]]
    last_name <- row[[author_columns[i + 1]]]
    if (!is.na(first_name) && !is.na(last_name)) {
      # Tokenize first_name and create initials
      initials <- strsplit(first_name, " ")[[1]] |>
        substr(1, 1) |>
        paste0(".") |>  #add a period after each initial
        paste(collapse = "")
      paste0(last_name, ", ", initials)
    } else {
      NA
    }
  })
  authors <- authors[!is.na(authors)]
  authors <- paste(authors, collapse = ", ")

  # Extract year
  year_col <- names(row)[grep("Current publication status > Date", names(row))]
  year <- str_extract(year_col, "\\d{4}$") #get last four digits

  # Extract title
  title <- paste(row$`1 Title of the contribution in original language`
                 , row$`2 Subtitle of the contribution in original language`
                 , sep = ": ")

  # Extract journal title and clean it
  journal <- gsub(" → …$", "", gsub("[0-9]", ""
                                    , row$`13.1 Journal > Journal[1]:Titles`))

  # Create APA reference string
  apa_reference <- paste0(authors
                          , " (", year, "). "
                          , title, ". "
                          , journal, ", ")
                          # , volume, "(", issue, "), "
                          # , pages, ".")
  return(apa_reference)
}

# Apply the function to each row and create a new column with APA references
df_apa <- data %>%
  rowwise() %>%
  mutate(APA_Reference = create_apa_reference(across(everything()))) %>%
  ungroup() %>%
  select(1, APA_Reference)

# View the data with APA references
print(df_apa)
