patients <- data.frame(
  Patient_Number = 1:5,  # IDs 1–5
  Date_of_Birth = as.Date(c("1980-05-12", "1992-11-03", "1975-07-21", "2000-01-15", "1988-09-30")),
  Sex_Gender = c("Male", "Female", "Male", "Female", "Other"),
  Race_Ethnicity = c("White", "Black", "Asian", "Hispanic", "Other"),
  Diabetes = c("Yes", "No", "No", "Yes", "No"),
  stringsAsFactors = FALSE
)

# View the dataframe
print(patients)
View(patients)