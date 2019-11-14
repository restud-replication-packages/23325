/************************************************
Table 3 - Cross Sections for years 1999 and 2002
Description: This file creates all the cross section measures for the years 1999 and 2000. The results are written to two files (one for each sample.) 
Both weighted and unweighted results are calculated and written; table 3 only uses the weighted results. Therefore, to compare the results, consider columns "weights99" (for year 1999) and "weights02" for year 2002.

This file requires the full data set, "BL_SAMPLE_FULL_UPDATED_WithParents".
Please see readme. It is not possible to run this code outside the ISS lab.

Please contact the author if you wish to reproduce these results at the ISS lab.
			  
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name Table_T3_cross_sections_1999_2002

local today = "$S_DATE"
local day = word("`today'",1)
local month = word("`today'",2)
local year = substr(word("`today'",3),3,2)
if `day' < 10 local `day' = "0`day'"

/**************************************************
I. ENTER THE PATH NAME WHERE THE DATA FILE IS FOUND
***************************************************/

cd "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses"
cap log close
log using "logs\\${name}_`day'`month'`year'.log", replace

use data\BL_SAMPLE_FULL_UPDATED_WithParents, clear

cap drop _f
append using "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\Palcebo_sample_2002_May17_BL_Data.dta", force
cap drop _f
	append using "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\Palcebo_sample_1999_11May17", force

* KEEPING OBSERVATIONS THAT ARE FOUND IN THE DEMOGRAPHIC SAMPLE *
keep if dmg == 1

* DROPPING INDIVIDUALS WHO HAVE WAGE PROBLEM (note that this doesnt vary according to the a/b/c definitions)*
drop if wage_problem_2000 == 1
drop if wage_problem_2001 == 1
drop if wage_problem_2002 == 1
drop if wage_problem_2003 == 1
drop if wage_problem_2004 == 1
drop if wage_problem_2005 == 1
drop if wage_problem_2006 == 1
drop if wage_problem_2007 == 1
drop if wage_problem_2008 == 1
drop if wage_problem_2009 == 1
drop if wage_problem_2010 == 1
drop if wage_problem_2011 == 1
drop if wage_problem_2012 == 1
drop if wage_problem_2013 == 1

*DROP INDIVIDUALS WITH WAGES HIGHER THAN 400,000 NIS *
*drop if sum_wage_2009a > 400000 | sum_wage_2010a > 400000 | sum_wage_2011a > 400000 | sum_wage_2012a > 400000

drop if sum_wage_2000a > 400000 |sum_wage_2001a > 400000 |sum_wage_2002a > 400000 |sum_wage_2003a > 400000 |sum_wage_2004a > 400000 |sum_wage_2005a > 400000 |sum_wage_2006a > 400000 |sum_wage_2007a > 400000 |sum_wage_2008a > 400000 |sum_wage_2009a > 400000 | sum_wage_2010a > 400000 | sum_wage_2011a > 400000 | sum_wage_2012a > 400000 | sum_wage_2013a > 400000

***Drop if wage is negative (this applies only to the b and c definitions***

foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	drop if sum_wage_`year'a<0
	drop if sum_wage_`year'b<0
	drop if sum_wage_`year'c<0
	}

* INFLATION-ADJUSTING OF WAGES (2009 PRICES)*

replace sum_wage_2010a = sum_wage_2010a / 1.026
replace sum_wage_2011a = sum_wage_2011a / ((1.026)*(1.0217))
replace sum_wage_2012a = sum_wage_2012a / ((1.026)*(1.0217)*(1.0163))
replace sum_wage_2013a = sum_wage_2013a / ((1.026)*(1.0217)*(1.0163)*(1.0182))
replace sum_wage_2008a = sum_wage_2008a * 1.0391
replace sum_wage_2007a = sum_wage_2007a * 1.0391 * 1.038
replace sum_wage_2006a = sum_wage_2006a * 1.0391 * 1.038 * 1.034
replace sum_wage_2005a = sum_wage_2005a * 1.0391 * 1.038 * 1.034 * 0.999
replace sum_wage_2004a = sum_wage_2004a * 1.0391 * 1.038 * 1.034 * 0.999 * 1.0239 
replace sum_wage_2003a = sum_wage_2003a * 1.0391 * 1.038 * 1.034 * 0.999 * 1.0239 * 1.0121 
replace sum_wage_2002a = sum_wage_2002a * 1.0391 * 1.038 * 1.034 * 0.999 * 1.0239 * 1.0121 * 0.9811
replace sum_wage_2001a = sum_wage_2001a * 1.0391 * 1.038 * 1.034 * 0.999 * 1.0239 * 1.0121 * 0.9811 * 1.065
replace sum_wage_2000a = sum_wage_2000a * 1.0391 * 1.038 * 1.034 * 0.999 * 1.0239 * 1.0121 * 0.9811 * 1.065 * 1.0141

*In order to cluster by school_codeYear
gen school_codeYear = school_code

replace school_codeYear = school_code * 1000 if year == 2001


***Drop if wage is negative***

foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	drop if sum_wage_`year'a<0
	drop if sum_wage_`year'b<0
	drop if sum_wage_`year'c<0
	}

 *** CREATE YEAR-AVERAGE WAGE VARIABLES ***
*egen avg_wage_09_11 = rowmean(sum_wage_2009a sum_wage_2010a sum_wage_2011a)
*egen avg_wage_09_12 = rowmean(sum_wage_2009a sum_wage_2010a sum_wage_2011a sum_wage_2012a)

***generate mean wage for father and mother for the years 2000-2002***
gen av_avwage00_02 = (av_sum_wage_2000a + av_sum_wage_2001a + av_sum_wage_2002a)/3
gen em_avwage00_02 = (em_sum_wage_2000a + em_sum_wage_2001a + em_sum_wage_2002a)/3



***generate household income***
foreach year in 2000 2001 2002 {
	gen house_sum_wage_`year'a = av_sum_wage_`year'a + em_sum_wage_`year'a
	}
	
gen house_avwage00_02 = (house_sum_wage_2000a + house_sum_wage_2001a + house_sum_wage_2002a)/3

*Generate dummy for above median household salary	
sum house_avwage00_02, detail
local med = r(p50)
gen house_avwage00_02H = (house_avwage00_02>=`med')
gen house_avwage00_02L = (house_avwage00_02<`med')

/**************************************************
II. DEFINE `after' AND `before' 
***************************************************/
gen before = (year == 1999)
gen after = (year == 2002)

/**************************************************
III. DEFINE TREATMENT AND CONTROL GROUPS
***************************************************/

gen treatment = (treated == 1)
gen control = (treated == 0)



*** SET QUARTILES SAMPLES ***
drop q1 q2 q3 q4
gen q4 = 1
gen q3 = (q != 4)
gen q_1 = (q==1)
gen q_2 = (q==2)
gen q_3 = (q==3)
gen q_4 = (q==4)

*** SET EXPERIMENT SAMPLE GROUPS ***
rename inNE NE
rename inRD RD
rename inEL EL

bysort semelmos: egen test = max(treatment)
bysort semelmos: egen testNE = max(NE)
bysort semelmos: egen testRD = max(RD)

bysort semelmos: egen testFW = max(hoodWeight)

replace treatment=test
replace hoodWeight=testFW
replace NE=testNE
replace RD = testRD
replace  school_code = semelmos

*Generate age at birth of first child (in months)
gen  age_at_first_birth=(gil_yld1_yy-leda_yy)*12+(gil_yld1_mm-leda_mm)

*Generate age at marriage (in months)

gen age_at_marriage=(nis1_tar_yy-leda_yy)*12+(nis1_tar_mm-leda_mm)


gen age_at_first_birth_years=gil_yld1_yy-leda_yy
gen age_at_marriage_years=(nis1_tar_yy-leda_yy)

*gen  school type dummy
gen arab =  schtype=="NON JEWISH"
replace arab=. if  schtype==""
gen dati =  schtype=="JEWISH REL."
replace dati=. if  schtype==""
encode schtype , g(schtype2)

bysort semelmos: egen tess= max(schtype2)

replace schtype2 = tess if schtype2==.
drop arab dati 
gen arab =  schtype2==3
replace arab=. if schtype2==.
gen dati =  schtype2==1
replace dati=. if schtype2==.





local depvars "A2011 A2013 B2011 B2013  uni2011 uni2013 col2011 col2013 work_2010a work_2012a sum_wage_2010a sum_wage_2012a sum_month_2010a sum_month_2012a psum_wage_2010a  psum_wage_2012a " 

local controls "  ole boy educav educem m_ahim "
***add i.schtype2 if needed for the analysis




drop if year==2000 | year==2001 |year==.



xtile psum_wage_2010a = sum_wage_2010a if year==1999, nquantiles(100)
xtile Ppsum_wage_2010a = sum_wage_2010a if year==2002, nquantiles(100)
replace psum_wage_2010a = Ppsum_wage_2010a if year==2002
drop Ppsum_wage_2010a


xtile psum_wage_2012a = sum_wage_2012a, nquantiles(100)
xtile Ppsum_wage_2012a = sum_wage_2012a if year==2002, nquantiles(100)
replace psum_wage_2012a = Ppsum_wage_2012a if year==2002
drop Ppsum_wage_2012a






gen afterXtreatment = after * treatment

foreach sample in NE RD {  

	
	postfile values str50 rowKey   no_weights99 weights99 no_weights02 weights02  using "results\automatic\\${name}", replace
	
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
				

				
				regress `var' treatment `controls'    if after == 0 & q4==1 [fweight=hoodWeight], vce(cluster school_code)

				local Ndif_00_`var'_q4 = _b[treatment]
				local Nse_dif_00_`var'_q4 = _se[treatment]		

				
				regress `var' treatment `controls'   if after == 0 & q4==1, vce(cluster school_code)
	
				
				local dif_00_`var'_q4 = _b[treatment]
				local se_dif_00_`var'_q4 = _se[treatment]
				
				
				regress `var' treatment `controls'   if after == 1 & q4==1 [fweight=hoodWeight], vce(cluster school_code)

				local Ndif_01_`var'_q4 = _b[treatment]
				local Nse_dif_01_`var'_q4 = _se[treatment]		

				
				regress `var' treatment `controls'   if after == 1 & q4==1, vce(cluster school_code)
	
				
				local dif_01_`var'_q4 = _b[treatment]
				local se_dif_01_`var'_q4 = _se[treatment]	
				
				
									regress `var' treatment    if after == 0 & q4==1 [fweight=hoodWeight], vce(cluster school_code)

				local CNdif_00_`var'_q4 = _b[treatment]
				local CNse_dif_00_`var'_q4 = _se[treatment]		

				
				regress `var' treatment    if after == 0 & q4==1, vce(cluster school_code)
	
				
				local Cdif_00_`var'_q4 = _b[treatment]
				local Cse_dif_00_`var'_q4 = _se[treatment]
				
				
				regress `var' treatment   if after == 1 & q4==1 [fweight=hoodWeight], vce(cluster school_code)

				local CNdif_01_`var'_q4 = _b[treatment]
				local CNse_dif_01_`var'_q4 = _se[treatment]		

				
				regress `var' treatment    if after == 1 & q4==1, vce(cluster school_code)
	
				
				local Cdif_01_`var'_q4 = _b[treatment]
				local Cse_dif_01_`var'_q4 = _se[treatment]	
				
				
				
				post values ("MEAN `var'")                                            (`Ndif_00_`var'_q4')  (`dif_00_`var'_q4') (`Ndif_01_`var'_q4')  (`dif_01_`var'_q4')      
				post values ("CLUSTERED SCHOOL SE `var'")                           (`Nse_dif_00_`var'_q4') (`se_dif_00_`var'_q4') (`Nse_dif_01_`var'_q4') (`se_dif_01_`var'_q4')
	
			
						
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


