/************************************************
Table 7 - Personal Status outcomes
Description: This code recreates all of table 7 - the DID estimates for the program's effect on personal status outcomes - marrige and fertility.
*************************************************/

clear all
set mem 500m
set matsize 800
*set more off
set logtype text

*set name for result and log file
global name Replication_T7 


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

*rename some variables so that it easier to loop through the groups
rename house_avwage00_02H hi

gen girl=(boy!=1)
gen hiXtreatment=(hi==1 & treatment==1)
gen hiXafter=(hi==1 & after==1)
gen hiXaftXtreat=(hi==1 & after==1 & treatment==1)

local i = 0
foreach var1 in att_lgcr att_lgsc awr_lgcr e_awr_lgcr educav educem m_ahim {
			gen `var1'hi=att_lgcr*hi
			}


*This table only details results for the NE sample, but this can be changed here		
foreach sample in NE {
  

	local i = `i' + 1
						
	foreach group in q4 {
		
		*preserve and restore the data if you add sample or groups	
		*preserve
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
			
			*choose variables
			foreach var in marr kids {
			*choose years after graduation
			foreach yearsAfterSchool in 11{
			
			
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls"
				di ""
				di "Outcome: `var'"
				di ""
				di "Cohorts: 2000,2001"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
				
				*i is used to run both with and without weighting (see text)		
				if `i' != 3 {
				di "all"	
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight], cluster(school_code)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				di "boys"	
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy   att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight] if boy==1, cluster(school_code)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 & boy==1 [fweight=hoodWeight]

				
				di "girls"		
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy    att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight] if boy==0, cluster(school_code)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 & boy==0 [fweight=hoodWeight]

				di "high income"
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy   att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight] if hi==1, cluster(school_code)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 & hi==1 [fweight=hoodWeight]

				di "low income"
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy   att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight] if hi==0, cluster(school_code)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 & hi==0 [fweight=hoodWeight]

				
				di "low income and cluster semelmos year"
				reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment boy   att_lgcr att_lgsc awr_lgcr e_awr_lgcr att_lgcrhi att_lgschi awr_lgcrhi e_awr_lgcrhi asiafr ole  educav educem m_ahim educavhi educemhi m_ahimhi i.year i.school_code [fweight=hoodWeight] if hi==0, cluster(school_codeYear)
				sum `var'_`yearsAfterSchool'_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 & hi==0 [fweight=hoodWeight]

				}
							
				
				
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				}
				
				}
				*restore if more than one group is being analyzed
				*restore
				}		

			*/
				}
				
				cap log close
