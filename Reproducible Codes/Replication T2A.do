/************************************************

TABLE 2A

Description: This file creates a pre- and post-treatment analysis of cross section DID for both the NE and RD samples
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name T2A

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


*depvars holds a list of variables to perfore the analysis on
local depvars "sum_wage_11_afterSchoola months_11_afterSchoola"

*depvars holds a list of control variables
local controls "att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim"

 
   
foreach sample in NE RD  {  

	
	postfile values str50 rowKey  pre_treat post_treat using "results\automatic\\${name}", replace
	
		preserve
			
			keep if `sample' == 1

			di "***************************************************************"
			di "***************************************************************"
			di ""
			di "Sample: `sample'"
			di ""
			di "***************************************************************"
			di "***************************************************************"
			
			foreach var of varlist `depvars' {
			
				
				// SUMMARY STATISTICS
				di ""
				di "*********************************************************"
				di ""
				di "COMPUTING SAMPLE MEAN AND STANDARD DEVIATIONS FOR T AND C"
				di ""
				di "Outcome: `var'"
				di ""
				di "Cohorts: 2000"
				di ""
				di "Sample: All Observations"
				di ""
				di "*********************************************************"
				di ""
				
				*DID regressions
				regress `var' treatment    [fweight = hoodWeight]  if after == 0 & q4==1, vce(cluster school_code)
				local B1_pre_noC = _b[treatment]
				local SE_pre_noC = _se[treatment]
				xi: regress `var' treatment  i.schtype [fweight = hoodWeight]   if after == 0 & q4==1, vce(cluster school_code)
				local B1_pre_C = _b[treatment]
				local SE_pre_C = _se[treatment]
				regress `var' treatment    [fweight = hoodWeight]   if after == 1 & q4==1, vce(cluster school_code)
				local B1_post_noC = _b[treatment]
				local SE_post_noC = _se[treatment]
				xi: regress `var' treatment  i.schtype [fweight = hoodWeight] if after == 1 & q4==1, vce(cluster school_code)
				local B1_post_C = _b[treatment]
				local SE_post_C = _se[treatment]
				
				*save results to file
				post values ("Estimate `var' WITH school type control")     (`B1_pre_C')  (`B1_post_C')
				post values ("CLUSTERED SCHOOL SE `var' WIT school type control")   (`SE_pre_C') (`SE_post_C')
				post values ("Estimate `var' WITHOUT school type control")     (`B1_pre_noC')  (`B1_post_noC')
				post values ("CLUSTERED SCHOOL SE `var' WITHOUT school type control")   (`SE_pre_noC') (`SE_post_noC')
				
			
						
				}

 
				
				
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results\automatic\\${name}", clear

				outsheet using "results\automatic\\${name}_`sample'.csv", replace comma

				erase "results\automatic\\${name}.dta"

				cap log close
				
				restore
}

