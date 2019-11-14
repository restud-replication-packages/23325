/************************************************
Table 4 and 5 - Stacked labor market outcomes

Description: This file creates a Stacked earnings regression for the emplyoment outcomes. It uses
the same DID approaches, but first stacks the employment outcomes of interest.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
*set more off
set logtype text

*set name for result and log file
global name Replication_Stacked_T4_T5

*generate local with current date, to not overwrite pervious logs
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
	

*generate the stacked variables
* 9 years after graduation
gen pctle_wage_stack_adjusted = pctle_wage_9_afterSchool
gen sum_wage_stack_adjusted = sum_wage_9_afterSchoola
gen sum_month_stack_adjusted = months_9_afterSchool
gen sum_work_stack_adjusted = work_9_afterSchool
gen avt_stack_adjusted = avt_9_afterSchool
gen avt_total_stack_adjusted = avt_tot_9_afterSchool


gen panel = 2010
tempfile temp
save tempA , replace
*add 10 years after graduation - this has to be staggered by year
use data\PublicationDataSet, clear

*add 	
append using tempA
replace panel = 2011 if panel==.
replace pctle_wage_stack_adjusted = pctle_wage_10_afterSchool if panel==2011
replace sum_wage_stack_adjusted = sum_wage_10_afterSchoola if panel==2011
replace sum_month_stack_adjusted = months_10_afterSchool  if panel==2011
replace sum_work_stack_adjusted = work_10_afterSchool if panel==2011
replace avt_stack_adjusted = avt_10_afterSchool  if panel==2011
replace avt_total_stack_adjusted = avt_tot_10_afterSchool  if panel==2011

tempfile temp
save tempB, replace
*add 11 years after graduation - this has to be staggered by year
use data\PublicationDataSet, clear

append using tempB
replace panel = 2012 if panel==.
replace pctle_wage_stack_adjusted = pctle_wage_11_afterSchool if panel==2012
replace sum_wage_stack_adjusted = sum_wage_11_afterSchoola if panel==2012
replace sum_month_stack_adjusted = months_11_afterSchool  if panel==2012
replace sum_work_stack_adjusted = work_11_afterSchool if panel==2012
replace avt_stack_adjusted = avt_11_afterSchool  if panel==2012
replace avt_total_stack_adjusted = avt_tot_11_afterSchool  if panel==2012


****STACKED REGRESSIONS***

**WHOLE SAMPLE**


local i = 0

*go through the two main samples
* NOTE - results are written to log file
foreach sample in NE RD {  

	local i = `i' + 1
						
	foreach group in q4{
	
		di "sample is `sample' and quartile is `group'"
				
				***Age Adjusted***
				**Controlled Specifications
				di "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				di "`sample'"
				di "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				di "Controled specifications, "
				di "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				
				xi: reg pctle_wage_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum pctle_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				xi: reg sum_wage_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				xi: reg sum_month_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_month_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				
				xi: reg sum_work_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_work_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				xi: reg avt_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum avt_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]


				xi: reg avt_total_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum avt_total_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				
				**Uncontrolled Specifications
				di "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				di "Uncontroled specifications, `sample'"
				di "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				
				xi: reg pctle_wage_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum pctle_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				xi: reg sum_wage_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				xi: reg sum_month_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_month_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				
				xi: reg sum_work_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_work_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				xi: reg avt_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum avt_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]


				xi: reg avt_total_stack_adjusted afterXtreatment att_lgcr i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum avt_total_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
	}
}
log close
