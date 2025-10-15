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

check_unique <- function(xx){nrow(xx) == nrow(unique(xx))}
#This is to check all rows in a given dataframe are unique

met_rxnorm<-"./output/Metformin_RxNav_6809_table.csv"

met_rxnorm_lookup <- import(met_rxnorm,skip=2) %>% filter(.,termType %in% c("BN","IN","MIN","PIN","SBD","SBDC","SBDF","SBDFP","SBDG","SCD","SCDC","SCDF","SCDG"))

#data0<-import(list.files(datasource,full.names = T) [9]) is to name files to identify/ specific files
data0<-sapply(list.files(datasource,full.names = T),import) %>%
  #rename all objects in data0 to get rid of the prefix "../output/csv/" and suffix ".csv"
  setNames(gsub(paste0("^",datasource,"/{0,1}|\\.csv$"),"",names(.)))#"paste0" takes several varaible and puts them together. "gsubs" substitutes

#how to create name files of many files at the same time
#To view data list put View(data0) in the terminal
#To view data frame (such as encounters) use View(data0[["../output/csv/DATAFRAMEs.csv"]]) in terminal
##To create a report use create_report(data0[["../output/csv/encounters.csv"]],config = configure_report(add_plot_prcomp = F))
##

.diabetesjunk <- data0[["conditions"]]
.criteria1 <- grepl(pattern="\\bdiab",x=.diabetesjunk$DESCRIPTION,ignore.case=TRUE)
.criteria2 <- .diabetesjunk$START >= as.Date("2015-01-01")
.diabetesjunk <- filter(.diabetesjunk, .criteria1 & .criteria2)
diabetesjunkelegant <- data0[["conditions"]] %>% 
  filter(.,grepl("\\bdiab",DESCRIPTION,ignore.case=TRUE) & START >= as.Date("2015-01-01")) 
identical(diabetesjunkelegant,.diabetesjunk)
#with(data0[["conditions"]],browser())

.diabetesjunk <- filter(data0[["conditions"]],grepl("\\bdiab",x=DESCRIPTION, ignore.case=TRUE)) 
diabetes_unique_patient_and_encounter <-  with(data=.diabetesjunk,list(patient=unique(PATIENT),encounter=unique(ENCOUNTER))) 


.diabetesjunk <- filter(data0[["conditions"]],grepl("\\bdiab",x=DESCRIPTION, ignore.case=TRUE)) 
diabetes_unique_patient_rows_detailed <-  select(.diabetesjunk, PATIENT, ENCOUNTER, DESCRIPTION) 


  criteria <- filter(data0[["conditions"]], grepl("\\bdiab",DESCRIPTION, ignore.case = TRUE)) %>% 
    with(data=.,list(patient_diabetes=unique(PATIENT), encounter_diabetes=unique(ENCOUNTER)))
  
  
  #meds_for_diabetes <- data0[["medications"]] %>%
    #filter(PATIENT %in% criteria$patient_diabetes)
  
  met_meds <- filter(data0$medications, CODE %in% met_rxnorm_lookup$rxcui)

  
 # Id <- data0$patients$Id 
 # Id %in%criteria$patient_diabetes
  
data_diab_patients <- data0[["patients"]] %>%
  filter(.,Id %in%criteria$patient_diabetes)
      
      
data_diab_encounters <- data0[["encounters"]] %>%
  filter(.,Id %in%criteria$encounter_diabetes)

data_diab_patient_plus_encounters <- left_join(data_diab_patients, data_diab_encounters, by=c("Id"="PATIENT")) %>% 
  mutate(ENCOUNTER=Id.y)
if (nrow(data_diab_patient_plus_encounters)-nrow(data_diab_encounters) != 0){ #testing number of rows
stop('join rows do not match') } else  {message('all clear')}
  message('There are ', nrow(data_diab_patient_plus_encounters),' rows in Ljoin')
  met_Ljoin <- left_join(data_diab_patient_plus_encounters, met_meds, by=c("ENCOUNTER"="ENCOUNTER"))

  #Age distribution (average, min, max)
  data0$patients %>% mutate(deathdate=as.Date(DEATHDATE),birthdate=as.Date(BIRTHDATE),
                            alive=is.na(deathdate),
                            age=as.numeric(pmin(Sys.Date(),deathdate,na.rm=TRUE)-birthdate)/365.25) %>%
    group_by(alive) %>%
    summarize( 
      avg_age = mean(age,na.rm=TRUE),
      min_age_at_death_or_censor=min(age,na.rm=TRUE),
      max_age_at_death_or_censor=max(age,na.rm=TRUE),
      count=n())
      
  
