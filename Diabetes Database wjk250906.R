#' title: "TSCI 5230 Processing a Data Set"
#' Author: Will Kelly
##Copy over the init section
debug <- 0;seed <-22;#Seed is to generate a random number but in a different way. You will have a random number and reproducibility.

knitr::opts_chunk$set(echo=debug>-1, warning=debug>0, message=debug>0, class.output="scroll-20", attr.output='style="max-height: 150px; overflow-y: auto;"');

library(ggplot2); # visualization
library(GGally);
library(rio);# simple command for importing and exporting
library(pander); # format tables
#library(printr); # set limit on number of lines printed
library(broom); # allows to give clean dataset
library(dplyr);#add dplyr library
library(tidymodels);
library(ggfortify);
library(DataExplorer)
#init----
options(max.print=500);
panderOptions('table.split.table',Inf); panderOptions('table.split.cells',Inf)
datasource <- "./output/csv/"
#data0<-import(list.files(datasource,full.names = T) [9]) is to name files to identify/ specific files
data0<-sapply(list.files(datasource,full.names = T),import) %>%
  #rename all objects in data0 to get rid of the prefix "../output/csv/" and suffix ".csv"
  setNames(gsub(paste0("^",datasource,"/{0,1}|\\.csv$"),"",names(.)))#"paste0" takes several varaible and puts them together. "gsubs" substitutes
#how to create name files of many files at the same time
#To view data list put View(data0) in the terminal
#To view data frame (such as encounters) use View(data0[["../output/csv/DATAFRAMEs.csv"]]) in terminal
##To create a report use create_report(data0[["../output/csv/encounters.csv"]],config = configure_report(add_plot_prcomp = F))


# Get all csv files
files <- list.files(datasource, pattern = "\\.csv$", full.names = TRUE)

results <- lapply(files, function(file) {
  df <- import(file)
  
  # Turn into a character matrix so we can search everything
  mat <- as.matrix(df)
  
  # Find matches for "diabetes" (case insensitive)
  hits <- which(grepl("diabetes", mat, ignore.case = TRUE), arr.ind = TRUE)
  
  if (nrow(hits) > 0) {
    data.frame(
      File = basename(file),
      Row = hits[, 1],
      Column = colnames(mat)[hits[, 2]],
      Value = mat[hits],
      stringsAsFactors = FALSE
    )
  } else {
    NULL
  }
})

# Combine all results into one dataframe
diabetes_hits <- bind_rows(results)

print(diabetes_hits)

#Age distribution (average, min, max)
data0$patients %>%
  summarize( 
    avg_age = mean(Sys.Date()-BIRTHDATE, na.rm=TRUE))

    