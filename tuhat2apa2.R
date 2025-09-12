library(tidyverse)
library(rvest)

# Define the file path
file_path <- "orig/Pure publications - 10032025.html"

# Check if the file exists
if (!file.exists(file_path)) {
  stop(paste("File not found:", file_path))
}

# Read the HTML content
html_content <- read_html(file_path)

# Extract the table
# Assuming the table has a unique class or id, you can use that for selection.
# If there's no unique identifier, you might need to adjust the selector.
# For example, if it's the only table, you could use: html_table(html_content)[[1]]
# Or if there's a specific header row, you could target it with that in the selector.
# Here, I'm going to try selecting the first table, but be ready to adjust this
# to whatever method is most appropriate for your file

# first we have to check if this is the correct html type
table_nodes <- html_nodes(html_content, "table")
if(length(table_nodes) == 0){
  stop("no tables in this html file")
}
# first we have to check if this is the correct html type

table <- html_table(table_nodes[[1]], fill = TRUE)

# Check if the table was extracted successfully
if (is.null(table) || nrow(table) == 0) {
  stop("Failed to extract table from HTML.")
}

# Clean up column names (if needed)
# this will depend on the input html
# remove any white space in names
names(table) <- make.names(names(table), unique = TRUE)
names(table) <- gsub("[.]+", ".", names(table))
names(table) <- gsub("[.]$", "", names(table))

# remove empty rows
table <- table[rowSums(is.na(table)) != ncol(table),]

# remove empty columns
table <- table[, colSums(is.na(table)) != nrow(table)]

# Print or further process the dataframe
print(head(table))
str(table)
