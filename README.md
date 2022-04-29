# Omicron Severity Analysis
Author: Zachary Strasser and Hossein Estiri

Code for analyzing omicron data

This code is meant to be run to calulcate unadjusted Fischer's Exact Test between different COVID-19 periods and to calculated adjusted rates with IPTW.

Patient data cannot be shared. The analysis requires data formatted in the following matter. This can be a CSV or dataframe. THE FOLLOWING DATA IS NOT REAL AND PROVIDED ONLY FOR UNDERSTANDING THE TABLE FORMATTING

| female | age | race | hispanic | vaccine_status | mortality | hospitalization | Onset_ym | Onset | charlson_score |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 99 | BLACK OR AFRICAN AMERICAN | 0 | N | Y | Y | Wave 2 | 2021-03-15 | 3 | 
| 1 | 80 | WHITE | 1 | Fully Vaccinated | N | N | Delta | 2022-01-1 | 1 | 

The following lists the possible values for each of the columns and how the patient data should be cleaned and organized.

female: 1, 0 (1 representative of female) <br> 
age: integer  <br> 
race: "BLACK OR AFRICAN AMERICAN", "WHITE", "OTHER/UNKNOWN", "ASIAN"  <br> 
hispanic: 1, 0 (1 representative of hispanic)  <br> 
vaccine_status: "N", "First Dose Only", "Fully Vaccinated", "Fully Vaccinated with Booster"  <br> 
mortality: Y, N  <br> 
hospitalization: Y, N  <br> 
Onset_ym: "Wave 2" (Winter 20' - 21'), "Spring 2021", "Delta", "0000" (Omicron)  <br> 
Onset: date  <br> 
charlson_score: integer  (calculated using comorbidity package on extracted ICD codes) 
