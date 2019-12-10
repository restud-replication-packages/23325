/************************************************
Table 3 - Cross Sections for years 2000 and 2001
Description: This file creates all the cross section measures for the years 2000 and 2001. The results are written to two files (one for each sample.) 
Both weighted and unweighted results are calculated and written; table 3 only uses the weighted results. Therefore, to compare the results, consider columns "weights00" (for year 2000) and "weights01" for year 2001.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name Table_T3_cross_sections_2000_2001

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

rename A_12_afterSchool A_12_after
rename B_12_afterSchool B_12_after
rename uni_12_afterSchool uni_12_after
rename col_12_afterSchool col_12_after
rename work_11_afterSchoola work_11_after
rename months_11_afterSchoola months_11_after
rename sum_wage_11_afterSchoola wage_11_after
rename pctle_wage_11_afterSchool pctle_11_after

local depvars "A_12_after B_12_after uni_12_after col_12_after work_11_after months_11_after wage_11_after pctle_11_after"


local controls "att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim"


 
   
*local controls "slrate99 asiafr ole boy educav educem m_ahim att_lgsc att_lgcr awr_lgcr m_awr_lgcr e_awr_lgcr i.year i.school_code"

foreach sample in NE RD  {  

	
	postfile values str50 rowKey   no_weights00 weights00 no_weights01 weights01  using "results/automatic//${name}", replace
	
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
				di "Cohorts: 2000 and 2001"
				di ""
				di "Sample: All Observations"
				di ""
				di "*********************************************************"
				di ""
				

				
				*after==0 means 2000
				regress `var' treatment      if after == 0 & q4==1, vce(cluster school_code)

				local Ndif_00_`var'_q4 = _b[treatment]
				local Nse_dif_00_`var'_q4 = _se[treatment]		

				*after==0 means 2000
				regress `var' treatment    [fweight = hoodWeight]  if after == 0 & q4==1, vce(cluster school_code)
	
				
				local dif_00_`var'_q4 = _b[treatment]
				local se_dif_00_`var'_q4 = _se[treatment]
				
				*after==1 means 2001
				regress `var' treatment    if after == 1 & q4==1, vce(cluster school_code)

				local Ndif_01_`var'_q4 = _b[treatment]
				local Nse_dif_01_`var'_q4 = _se[treatment]		

				*after==1 means 2001
				regress `var' treatment     [fweight = hoodWeight] if after == 1 & q4==1, vce(cluster school_code)
	
				
				local dif_01_`var'_q4 = _b[treatment]
				local se_dif_01_`var'_q4 = _se[treatment]	
				
				*after==0 means 2000
				regress `var' treatment   `controls'    if after == 0 & q4==1, vce(cluster school_code)

				local CNdif_00_`var'_q4 = _b[treatment]
				local CNse_dif_00_`var'_q4 = _se[treatment]		

				*after==0 means 2000
				regress `var' treatment  `controls'    [fweight = hoodWeight] if after == 0 & q4==1, vce(cluster school_code)
	
				
				local Cdif_00_`var'_q4 = _b[treatment]
				local Cse_dif_00_`var'_q4 = _se[treatment]
				
				*after==1 means 2001
				regress `var' treatment  `controls'    if after == 1 & q4==1, vce(cluster school_code)

				local CNdif_01_`var'_q4 = _b[treatment]
				local CNse_dif_01_`var'_q4 = _se[treatment]		

				*after==1 means 2001
				regress `var' treatment  `controls'    [fweight = hoodWeight] if after == 1 & q4==1, vce(cluster school_code)
	
				
				local Cdif_01_`var'_q4 = _b[treatment]
				local Cse_dif_01_`var'_q4 = _se[treatment]	
				
				
				*uncomment this section for uncontrolled results
				*post values ("MEAN `var' without controls")                                            (`Ndif_00_`var'_q4')  (`dif_00_`var'_q4') (`Ndif_01_`var'_q4')  (`dif_01_`var'_q4')      
				*post values ("CLUSTERED SCHOOL SE `var' without controls")                           (`Nse_dif_00_`var'_q4') (`se_dif_00_`var'_q4') (`Nse_dif_01_`var'_q4') (`se_dif_01_`var'_q4')
				post values ("MEAN `var' with controls")                       (`CNdif_00_`var'_q4')  (`Cdif_00_`var'_q4') (`CNdif_01_`var'_q4')  (`Cdif_01_`var'_q4')      
				post values ("CLUSTERED SCHOOL SE `var' with controls")    (`CNse_dif_00_`var'_q4') (`Cse_dif_00_`var'_q4') (`CNse_dif_01_`var'_q4') (`Cse_dif_01_`var'_q4')
				
			
						
				}

				
				
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results/automatic//${name}", clear

				outsheet using "results/automatic//${name}_`sample'.csv", replace comma

				erase "results/automatic//${name}.dta"

				cap log close
				
				restore
		
		
}

cap log close
