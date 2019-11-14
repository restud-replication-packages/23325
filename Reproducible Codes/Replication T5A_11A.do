/************************************************

Tables 5A and 11A

Description: This do file create DID analysis for the main education and labor market outcome for different bandwidths of the RD sample. The analysis is first run for the 0.37-0.54
score range, and then for the 0.38 to 0.53 score range. See text for details.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name Replication_T5A_11A

local today = "$S_DATE"
local day = word("`today'",1)
local month = word("`today'",2)
local year = substr(word("`today'",3),3,2)
if `day' < 10 local `day' = "0`day'"

/**************************************************
I. ENTER THE PATH NAME WHERE THE DATA FILE IS FOUND
***************************************************/

cd "###INSERT FOLDER PATH HERE###"

cap log close

log using "logs\\${name}_`day'`month'`year'.log", replace

use data\PublicationDataSet, clear


***Bandwidth 37-54***
di "Bandwidth 37-54"

foreach sample in RD_alternative1{  

	local i = `i' + 1
						
	foreach group in q4 {
	
		postfile values str50 rowKey B0 Binteraction using "results\automatic\\TA11_`sample'_`group'_incomeALagged", replace	
	
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
			** labor T11A
			foreach var in sum_wage work months {
			foreach yearsAfterSchool in   11  {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls alternative bandwidth 37-54"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchoola"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000
						local dd = r(sd)
						local dd2 = r(mean)
				*local B0`var'_`yearsAfterSchool'_afterSchoola = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
						
				su `var'_`yearsAfterSchool'_afterSchoola if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchoola = `dd2'
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = `dd'
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
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

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
				
				di "count observations non-weighted to log"
				su `var'_`yearsAfterSchool'_afterSchoola if treatment == 1 & before == 1

				}
				
				}				
				
				
				}
			** education T5A
				foreach var in A B col uni {
			foreach yearsAfterSchool in   12  {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls alternative RD 37-54"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchoola"
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
				sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000
						local dd = r(sd)
						local dd2 = r(mean)
				*local B0`var'_`yearsAfterSchool'_afterSchoola = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
						
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchoola = `dd2'
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = `dd'
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
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

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
				
				di "count observations non-weighted to log"
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1

				}
				
				}				
				
				
				}
						
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results\automatic\\TA11_`sample'_`group'_incomeALagged", clear

				outsheet using "results\automatic\\TA11_`sample'_`group'_band37-54.csv", replace comma

				erase "results\automatic\\TA11_`sample'_`group'_incomeALagged.dta"
				
				restore
			
				}
				
		}		

		
local i = 0

***Bandwidth 38-54***
di "Bandwidth 38-53"

foreach sample in RD_alternative2{  

	local i = `i' + 1
						
	foreach group in q4 {
	
		postfile values str50 rowKey B0 Binteraction using "results\automatic\\TA11_`sample'_`group'_incomeALagged", replace	
	
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
			
			** labor T11A
			foreach var in sum_wage work months {
			foreach yearsAfterSchool in   11  {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchoola"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000
						local dd = r(sd)
						local dd2 = r(mean)
				*local B0`var'_`yearsAfterSchool'_afterSchoola = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
						
				su `var'_`yearsAfterSchool'_afterSchoola if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchoola = `dd2'
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = `dd'
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
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

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
				di "count observations non-weighted to log"
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1

				}
				
				}				
				
				
				}
			** education T5A
				foreach var in A B col uni {
			foreach yearsAfterSchool in   12  {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls alternative bandwidth 38-53"
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
				sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000
						local dd = r(sd)
						local dd2 = r(mean)
				*local B0`var'_`yearsAfterSchool'_afterSchoola = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
						
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchoola = `dd2'
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = `dd'
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
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

				su E_12_afterSchool if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
			
				di "count observations non-weighted to log"
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1
				}
				
				}				
				
				
				}
					
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results\automatic\\TA11_`sample'_`group'_incomeALagged", clear

				outsheet using "results\automatic\\TA11_`sample'_`group'_band38-53.csv", replace comma

				erase "results\automatic\\TA11_`sample'_`group'_incomeALagged.dta"
				
				restore
			
				}
				
		}		

cap log close
