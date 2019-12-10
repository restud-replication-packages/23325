/************************************************
Table 6 - Stacjed labor market outcomes

Description: This file creates the parts of table 6 that deal with labor market outcomes. It is seperated from the education code,
as those outcomes are NOT stacked. First the results for the entire sample are reproduced, and then each sub-group is estimated. Each
sub-group has a different code section.
*************************************************/

clear all
set mem 500m
set matsize 800
*set more off
set logtype text

*set name for result and log file
global name Replication_Stacked_T6

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

*stack outcomes (as in code 'Replication T4 T5 Stacked.do')
		
gen pctle_wage_stack_adjusted = pctle_wage_9_afterSchool
gen sum_wage_stack_adjusted = sum_wage_9_afterSchoola
gen sum_month_stack_adjusted = months_9_afterSchool
gen sum_work_stack_adjusted = work_9_afterSchool
gen avt_stack_adjusted = avt_9_afterSchool
gen avt_total_stack_adjusted = avt_tot_9_afterSchool

gen panel = 2010
tempfile temp
save tempA , replace

use data\PublicationDataSet, clear

	
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

gen girl = (boy==0)
local i = 0

foreach sample in NE{  

	local i = `i' + 1
	*in this code we iterate over groups using a loop.		
	foreach group in boy girl house_avwage00_02H house_avwage00_02L{
	
		di "sample is `sample' and group is `group'"
				
				***Age Adjusted***
				
				
				xi: reg pctle_wage_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum pctle_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
				
				xi: reg sum_wage_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_wage_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				xi: reg sum_month_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_month_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				
				xi: reg sum_work_stack_adjusted afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.panel i.year i.school_code if `sample' == 1 & `group' == 1 [fweight=hoodWeight], cluster(school_code)
				sum sum_work_stack_adjusted if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				
				
	}
}
