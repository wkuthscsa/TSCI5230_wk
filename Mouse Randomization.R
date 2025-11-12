#This is a method for randomization of mice based on different readings

library(dplyr);#add dplyr library
library(rio);# simple command for importing and exporting

mouse_rand_import_file_loc<-"./output/Example Mouse Randomization.xlsx"

mouse_rand_data <- import(mouse_rand_import_file_loc)
View(mouse_rand_data)

arranged_mouse_rand_data <- arrange(mouse_rand_data,desc(`photons/sec`))
View(arranged_mouse_rand_data)
mouse_groups <- c("treatment1","treatment2","control","combination")
arranged_mouse_rand_data[["mouse_groups"]]<-mouse_groups
View(arranged_mouse_rand_data)
group_by(arranged_mouse_rand_data,mouse_groups) %>% summarize(average_photons_sec=mean(`photons/sec`))

unarranged_mouse_rand_data <- mouse_rand_data
View(unarranged_mouse_rand_data)
unarranged_mouse_rand_data[["mouse_groups"]]<-sample(mouse_groups,nrow(unarranged_mouse_rand_data),replace=TRUE)
View(unarranged_mouse_rand_data)
group_by(unarranged_mouse_rand_data,mouse_groups) %>% summarize(average_photons_sec=mean(`photons/sec`))
