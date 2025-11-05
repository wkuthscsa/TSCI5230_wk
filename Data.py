
import pandas as pd
import numpy as np
import pprint

from glob import glob
from datetime import datetime

def get_end_date(row):
    death_date = row['DEATHDATE']
    if pd.isna(death_date):
        return today
    else:
        return min(today, death_date.date())


debug = 0
seed = 22
np.random.seed(seed) #Set seed for reproducibility


# Load all CSV files from the data source directory
datasource = "./output/csv/"
csv_files = glob(f"{datasource}/*.csv")
data0 = {f.replace("\\","/").replace(".csv","").split("/")[-1]: pd.read_csv(f) for f in csv_files}

# Load Metformin RxNorm lookup table
met_rxnorm = "./output/Metformin_RxNav_6809_table.csv"
met_rxnorm_lookup = pd.read_csv(met_rxnorm, skiprows=2)
met_rxnorm2 = met_rxnorm_lookup
met_rxnorm3 = met_rxnorm_lookup.copy(deep=True)
rxnorm_terms = ["BN", "IN", "MIN", "PIN", "SBD", "SBDC", "SBDF", "SBDFP", "SBDG", "SCD", "SCDC", "SCDF", "SCDG"]
met_rxnorm_lookup = met_rxnorm_lookup[met_rxnorm_lookup["termType"].isin(rxnorm_terms)]

# Filter diabetes conditions starting from 2015
conditions = data0["conditions"]
conditions["START"] = pd.to_datetime(conditions["START"], errors="coerce")
diabetesjunk = conditions[
    conditions["DESCRIPTION"].str.contains(r"\bdiab", case=False, na=False) &
    (conditions["START"] >= pd.to_datetime("2015-01-01"))
]

# Get unique patients and encounters
unique_patients = diabetesjunk["PATIENT"].unique()
unique_encounters = diabetesjunk["ENCOUNTER"].unique()

# Filter medications for Metformin
medications=data0['medications'].copy(deep=True)
met_meds = medications[medications["CODE"].isin(met_rxnorm_lookup["rxcui"])]
medications['total_cost_rounded']=medications['TOTALCOST'].round

# Filter patients and encounters related to diabetes
patients = data0["patients"]
encounters = data0["encounters"]
data_diab_patients = patients[patients["Id"].isin(unique_patients)]
data_diab_encounters = encounters[encounters["Id"].isin(unique_encounters)]

# Join patient and encounter data
data_diab_patient_plus_encounters = pd.merge(
    data_diab_patients, data_diab_encounters, left_on="Id", right_on="PATIENT", how="left"
)
data_diab_patient_plus_encounters["ENCOUNTER"] = data_diab_patient_plus_encounters["Id_y"]

# Check row match
if len(data_diab_patient_plus_encounters) != len(data_diab_encounters):
    raise ValueError("Join rows do not match")
else:
    print("All clear")
    print(f"There are {len(data_diab_patient_plus_encounters)} rows in Ljoin")

# Join with Metformin medications
met_Ljoin = pd.merge(
    data_diab_patient_plus_encounters, met_meds, on="ENCOUNTER", how="left"
)

# Age distribution
patients["DEATHDATE"] = pd.to_datetime(patients["DEATHDATE"], errors="coerce")
patients["BIRTHDATE"] = pd.to_datetime(patients["BIRTHDATE"], errors="coerce")
patients["alive"] = patients["DEATHDATE"].isna()
patients["age"] = (patients["DEATHDATE"].fillna(datetime.today()) - patients["BIRTHDATE"]).dt.days / 365.25
age_summary = patients.groupby("alive")["age"].agg(
    avg_age="mean",
    min_age_at_death_or_censor="min",
    max_age_at_death_or_censor="max",
    count="count"
).reset_index()




print(age_summary)

#Converting column to a Python list (what R calls a vector)
medications['TOTALCOST'].tolist()
total_cost_list=medications['TOTALCOST'].tolist()
total_cost_list.round()
round(total_cost_list)

#There are several ways to transform a value in a pyton list. Below you will find 3 commands to round a number in this list.
result=[]
for xx in total_cost_list:
    result.append(round(xx))
    #result=result+round(xx)
    #result+=[round(xx)]

#List Comprehension is creating and modifying a list in the same line of code
#Another way to do this
result2=[round(xx) for xx in total_cost_list]
result2
result3=[round(xx) if xx >10 else -1 for xx in total_cost_list ] # the if statement is nested in the for loop and the round function is inside the if statement
result3

#Dictionary
dresult={}
for xx in  data0.keys():
    #dresult[xx]=data0[xx].keys().tolist()
    dresult.update({xx:data0[xx].keys().tolist()}) #the ":" in this line is to signify the name:value pairs of the dataframes, like allergies:START
pprint.pprint(dresult) #to see the dictionary list in a more formated format

dresult2={xx:data0[xx].keys().tolist() for xx in data0.keys()}
pprint.pprint(dresult)

#Creating Dictionary with Zip
#Create list with of keys  then create a with table names using list comprehension
table_names=data0.keys()
column_names=[data0[xx].keys().tolist()for xx in table_names]
column_names
dresult3=dict(zip(table_names,column_names))
pprint.pprint(dresult3)

unzi    
