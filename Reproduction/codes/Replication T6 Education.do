/************************************************
Table 6 - Education outcomes

Description: This file creates the parts of table 6 that deal with education outcomes. It is seperated from the employment code,
as those outcomes are stacked. First the results for the entire sample are reproduced, and then each sub-group is estimated. Each
sub-group has a different code section.
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

*set name for result and log file
global name Replication_T6_Educ

*generate local with current date, to not overwrite pervious logs
local today = "$S_DATE"
local day = word("`today'",1)
local month = word("`today'",2)
local year = substr(word("`today'",3),3,2)
if `day' < 10 local `day' = "0`day'"

/**************************************************
I. ENTER THE PATH NAME WHERE THE DATA FILE IS FOUND
***************************************************/


cd "###INSERT FOLDER PATH HERE###/Reproduction"

cap log close
log using "logs//${name}_`day'`month'`year'.log", replace


use data/PublicationDataSet, clear


***WITH CONTROLS - entire sample***

local i = 0

*This is done only for the NE sample, but RD can be added below.
foreach sample in NE    {  

	local i = `i' + 1
						
	foreach group in  q4  {
		
		*postfile writes results to excel file
		postfile values str50 rowKey B0 Binteraction using "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", replace		
	
			preserve
			
			keep if `sample' == 1 & `group' == 1 

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "Group: `group'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			*go through each education variable
			foreach var in E A B   educ uni col {
			*look at 11th and 12th year after graduation
			foreach yearsAfterSchool in   11 12  {
			
			 sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
					
				*i is used to run the regressions with and without weighting.	
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (.) (`SE3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("") (.) (.) 
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)
				*use the E variable to count observations - E was chosen arbitrarily, this has no effect
				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				post values ("Weighted N OBS `sample'")  (`wn') (.) 
				post values ("") (.) (.)
				}
				
				
				}				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", clear

				outsheet using "results/automatic//${name}_`sample'_`group'_all_educ.csv", replace comma

				erase "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}
		
		
		
*Repeat the excercise only for men (boy variable=1)	
		***WITH CONTROLS -  boys***

local i = 0

foreach sample in NE    {  

	local i = `i' + 1
						
	foreach group in  q4  {
	
		postfile values str50 rowKey B0 Binteraction using "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", replace		
	
			preserve
			
			keep if `sample' == 1 & `group' == 1 & boy==1 

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "Group: `group'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			foreach var in E A B   educ uni col{
			foreach yearsAfterSchool in   11 12  {
						sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (.) (`SE3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("") (.) (.) 
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				post values ("Weighted N OBS `sample'")  (`wn') (.) 
				post values ("") (.) (.)
				}
				
				
				}				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", clear

				outsheet using "results/automatic//${name}_`sample'_`group'_boys_educ.csv", replace comma

				erase "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}	

*Repeat the excercise only for men (boy variable=0)
				***WITH CONTROLS -  girls***

local i = 0

foreach sample in NE    {  

	local i = `i' + 1
						
	foreach group in  q4  {
	
		postfile values str50 rowKey B0 Binteraction using "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", replace		
	
			preserve
			
			keep if `sample' == 1 & `group' == 1 & boy==0

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "Group: `group'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			foreach var in E A B   educ uni col {
			foreach yearsAfterSchool in   11 12  {
						sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (.) (`SE3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("") (.) (.) 
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				post values ("Weighted N OBS `sample'")  (`wn') (.) 
				post values ("") (.) (.)
				}
				
				
				}				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", clear

				outsheet using "results/automatic//${name}_`sample'_`group'_girls_educ.csv", replace comma

				erase "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}	


*Repeat the excercise only for high income households(house_avwage00_02H=1)
***WITH CONTROLS - Hi INCOMe***

local i = 0

foreach sample in NE    {  

	local i = `i' + 1
						
	foreach group in  q4  {
	
		postfile values str50 rowKey B0 Binteraction using "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", replace		
	
			preserve
			
			keep if `sample' == 1 & `group' == 1 & house_avwage00_02H==1 

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "Group: `group'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			foreach var in E A B   educ uni col {
			foreach yearsAfterSchool in   11 12  {
						sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (.) (`SE3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("") (.) (.) 
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				post values ("Weighted N OBS `sample'")  (`wn') (.) 
				post values ("") (.) (.)
				}
				
				
				}				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag", clear

				outsheet using "results/automatic//${name}_`sample'_`group'_high_income_educ.csv", replace comma

				erase "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}	

*Repeat the excercise only for low income households (house_avwage00_02H=1)
***WITH CONTROLS - Low INCOMe***

local i = 0

foreach sample in NE  {  

	local i = `i' + 1
						
	foreach group in  q4 {
	
		postfile values str50 rowKey B0 Binteraction using "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_girls_educ_Lag", replace		
	
			preserve
			
			keep if `sample' == 1 & `group' == 1 & house_avwage00_02H==0

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "Group: `group'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			foreach var in E A B  educ uni col {
			foreach yearsAfterSchool in   11 12 {
			sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (.) (`SE3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("") (.) (.) 
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				post values ("Weighted N OBS `sample'")  (`wn') (.) 
				post values ("") (.) (.)
				}
				
				
				}				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_girls_educ_Lag", clear

				outsheet using "results/automatic//${name}_`sample'_`group'_low_income_educ.csv", replace comma

				erase "results/automatic//Table_3_Lag_NOV2015_`sample'_`group'_girls_educ_Lag.dta"
				
				restore
			
				}
				
		}	
		
cap log close
