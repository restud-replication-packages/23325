/************************************************

Table T7A and T9A

This program runs placebo analyses using random assignment of treatment. It creates both tables 7A and 9A (running both the education and labor market outcomes.)
The results depend on the seed given to the program - see below.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name Replicate_T9A_7A

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



	**********************************
	*****Placebo**********************
	**********************************
	
	****assigning treatment randomly
	tempfile temp
	preserve
	cap drop _f
	contract school_code
	drop _f
	
	/*	
	this command is used to generate a seed for consistent result. 
	If a seed is not set, it is given by the time the program is run (therefore being semi-random.) 
	The user is encouraged to set various seeds, to see how the effect remains insignificant statistically (That is, in 5% of the cases, a result is expected to be significant at the 95% confidence level, etc.)
	*/
	set seed 13345
	gen temp_t=runiform()
    egen treat_plac=cut(temp_t), group(2)
	keep school_code treat_plac 
	save `temp'
****************************	
	restore
	cap drop _m
	merge m:1 school_code using `temp'
	drop _m
	corr treat_plac treatment
	replace treatment=treat_plac
********************************************
	
	replace afterXtreatment = treatment*after


local i = 0

foreach sample in NE  {  

	local i = `i' + 1
						
	foreach group in  q4{
	
		postfile values str50 rowKey B0 Binteraction using "results\automatic\\Table_7A9A_`sample'_`group'_boys_educ_Lag", replace		
	
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
			
			foreach var in E A B educ uni col {
			foreach yearsAfterSchool in 12 {
			
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
				
				*local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]
				
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchool = r(mean)
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = r(sd)
				

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchool') 
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
				
				di "non weighted # of observations"
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1

				}
				
				
				}				
				}
						
			foreach var in sum_wage work months{
			foreach yearsAfterSchool in 11 {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE"
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
				
				*local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]
				local B3`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]
				
				su `var'_`yearsAfterSchool'_afterSchoola if treatment == 1 & before == 1 [fweight=hoodWeight]
				local B0`var'_`yearsAfterSchool'_afterSchool = r(mean)
				local B0`var'_`yearsAfterSchool'_afterSchool_sd = r(sd)
				

				post values ("B `var'_`yearsAfterSchool'_afterSchool") 			 (`B0`var'_`yearsAfterSchool'_afterSchool') (`B3`var'_`yearsAfterSchool'_afterSchool') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchool")   (`B0`var'_`yearsAfterSchool'_afterSchool_sd') (`SE3`var'_`yearsAfterSchool'_afterSchool') 
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
				
				
				di "non weighted # of observations"
				su `var'_`yearsAfterSchool'_afterSchoola if treatment == 1 & before == 1

				}
				
				
				}				
				}
						
						
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results\automatic\\Table_7A9A_`sample'_`group'_boys_educ_Lag", clear

				outsheet using "results\automatic\\${name}_`sample'_`group'.csv", replace comma

				erase "results\automatic\\Table_7A9A_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}	

cap log close
