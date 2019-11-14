/************************************************

Table 9A - stacked outcomes.

Description: This file creates a Stacked earnings regression for the 2009-2012 data: 
		     DID Estimates of the Effect of Teachers'. We add bagrut and university (enrollment and schooling)
			 to the basic model.

			 
			 
*************************************************/

clear all
set mem 500m
set matsize 800

set logtype text

global name T9A_stacked

local today = "$S_DATE"
local day = word("`today'",1)
local month = word("`today'",2)
local year = substr(word("`today'",3),3,2)
if `day' < 10 local `day' = "0`day'"
	
	/*	
	this command is used to generate a seed for consistent result. 
	If a seed is not set, it is given by the time the program is run (therefore being semi-random.) 
	The user is encouraged to set various seeds, to see how the effect remains insignificant statistically (That is, in 5% of the cases, a result is expected to be significant at the 95% confidence level, etc.)
	*/
set seed 13345

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
	
	****assining treatment randomly
	tempfile temp_rnd
	preserve
	cap drop _f
	contract school_code
	drop _f
	gen temp_t=uniform()
    egen treat_plac=cut(temp_t), group(2)
	keep school_code treat_plac 
	save `temp_rnd'
	
	restore
	cap drop _m
	merge m:1 school_code using `temp_rnd'
	drop _m
	corr treat_plac treatment
	replace treatment=treat_plac
	replace afterXtreatment = treatment*after

gen sum_wage_stack_adjusted = sum_wage_9_afterSchoola
gen work_stack_adjusted = work_9_afterSchoola
gen sum_month_stack_adjusted = months_9_afterSchool
gen avt_stack_adjusted = avt_9_afterSchool
gen avt_tot_stack_adjusted = avt_tot_9_afterSchool


gen panel = 2010
tempfile temp
save tempA , replace

use data\PublicationDataSet, clear
************************
merge m:1 school_code using `temp_rnd'
	drop _m
	corr treat_plac treatment
	replace treatment=treat_plac
	replace afterXtreatment = treatment*after

********************************
	

append using tempA
replace panel = 2011 if panel==.

replace sum_wage_stack_adjusted = sum_wage_10_afterSchoola if panel==2011
replace work_stack_adjusted = work_10_afterSchoola if panel==2011
replace sum_month_stack_adjusted = months_10_afterSchool if panel==2011
replace avt_stack_adjusted = avt_10_afterSchool if panel==2011
replace avt_tot_stack_adjusted = avt_tot_10_afterSchool if panel==2011

tempfile temp
save tempB, replace

use data\PublicationDataSet, clear


************************
merge m:1 school_code using `temp_rnd'
	drop _m
	corr treat_plac treatment
	replace treatment=treat_plac
	replace afterXtreatment = treatment*after
********************************

append using tempB
replace panel = 2012 if panel==.

replace sum_wage_stack_adjusted = sum_wage_11_afterSchoola if panel==2012
replace work_stack_adjusted = work_11_afterSchoola if panel==2012
replace sum_month_stack_adjusted = months_11_afterSchool if panel==2012
replace avt_stack_adjusted = avt_11_afterSchool if panel==2012
replace avt_tot_stack_adjusted = avt_tot_11_afterSchool if panel==2012

****STACKED REGRESSIONS***

**WHOLE SAMPLE**

set more off
*choose sample
foreach sample in NE  {  

						
	foreach group in q4 {
	
		di "sample is `sample' and quartile is `group'"
				

				
				xi: reg sum_wage_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_codeYear)
				sum sum_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				xi: reg work_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_codeYear)
				sum work_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				sum sum_month_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 
				xi: reg sum_month_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 , cluster(school_codeYear)
				
				
				}
}
