/************************************************
Description: This do file creates the data file for publication. Work at the ISS lab was conducted on a large file called "BL_SAMPLE_FULL_UPDATED_WithParents".
This file included many fields that cannot be published. In order to make data available for reproduction, we were required to create a new data set, with
only the most important variables. This do file records this process. It cannot be run outside the ISS lab.

Please contact the author if you wish to reproduce these results at the ISS lab.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name DataSetCreationForPublication

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

* KEEPING OBSERVATIONS THAT ARE FOUND IN THE DEMOGRAPHIC SAMPLE *
keep if dmg == 1

* DROPPING INDIVIDUALS WHO HAVE WAGE PROBLEM*
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

drop if sum_wage_2000a > 400000 |sum_wage_2001a > 400000 |sum_wage_2002a > 400000 |sum_wage_2003a > 400000 |sum_wage_2004a > 400000 |sum_wage_2005a > 400000 |sum_wage_2006a > 400000 |sum_wage_2007a > 400000 |sum_wage_2008a > 400000 |sum_wage_2009a > 400000 | sum_wage_2010a > 400000 | sum_wage_2011a > 400000 | sum_wage_2012a > 400000 | sum_wage_2013a > 400000

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


***Drop if wage is negative***

foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	drop if sum_wage_`year'a<0
	drop if sum_wage_`year'b<0
	drop if sum_wage_`year'c<0
	}

	
/*adding madmug 	
compress
merge 1:1 zehut using "W:\victor_lavi\Incoming\olim1\Boaz\Teachers Bonuses\programs\Revision 2017 - Assaf\for merge madmug.dta"
replace madmug=. if _merge!=3
drop if _merge==2
*/
	
	
	
*In order to cluster by school_codeYear
gen school_codeYear = school_code
replace school_codeYear = school_code * 1000 if year == 2001

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

gen before = (year == 2000)
gen after = (year == 2001)

/**************************************************
III. DEFINE TREATMENT AND CONTROL GROUPS
***************************************************/

gen treatment = (treated == 1)
gen control = (treated == 0)

gen afterXtreatment = after * treatment

*** SET QUARTILES SAMPLES ***
drop q1 q2 q3 q4
gen q4 = 1
gen q3 = (q != 4)


*** SET EXPERIMENT SAMPLE GROUPS ***
rename inNE NE
rename inRD RD

/**************************************************
IV. CREATE LAGGED VARIABLES
***************************************************/

***Generate lag education for the 2000 cohort (E A B educ uni col)
foreach var in E A B educ uni col {
foreach year in  2010 2011 2012 2013 2014 2015 {
	local years_after_school = `year'-2001
	gen `var'_`years_after_school'_afterSchool = `var'`year'
	local yearMinus1 = `year'-1
	replace `var'_`years_after_school'_afterSchool = `var'`yearMinus1' if year==2000
	}
	}


***Generate lagged labor market outcomes
	foreach year in  2010 2011 2012  {
	local years_after_school = `year'-2001
	gen sum_wage_`years_after_school'_afterSchoola = sum_wage_`year'a
	gen work_`years_after_school'_afterSchoola = work_`year'a
	local yearMinus1 = `year'-1
	replace sum_wage_`years_after_school'_afterSchoola = sum_wage_`yearMinus1'a if year==2000
	replace work_`years_after_school'_afterSchoola = work_`yearMinus1'a if year==2000
	gen months_`years_after_school'_afterSchoola = sum_month_`year'a
	gen avt_`years_after_school'_afterSchool = avt`year'
	gen avt_tot_`years_after_school'_afterSchool = avt_tot`year'
	replace months_`years_after_school'_afterSchoola = sum_month_`yearMinus1'a if year==2000
	replace avt_`years_after_school'_afterSchool = avt`yearMinus1' if year==2000
	replace avt_tot_`years_after_school'_afterSchool = avt_tot`yearMinus1' if year==2000
	}

***Generate lagged percentile rank	
	foreach i in 9 10 11 {
		xtile pctle_wage_`i'_afterSchool = sum_wage_`i'_afterSchoola if year==2000, nquantiles(100)
		xtile Ppctle_wage_`i'_afterSchool = sum_wage_`i'_afterSchoola if year==2001, nquantiles(100)
		replace pctle_wage_`i'_afterSchool = Ppctle_wage_`i'_afterSchool if year==2001
		drop Ppctle_wage_`i'_afterSchool
		}

*gen  school type dummy
gen arab =  schtype=="NON JEWISH"
replace arab=. if  schtype==""
gen dati =  schtype=="JEWISH REL."
replace dati=. if  schtype==""
encode schtype , g(schtype2)

			
*Generate age at birth of first child (in months)
gen  age_at_first_birth=(gil_yld1_yy-leda_yy)*12+(gil_yld1_mm-leda_mm)

*Generate age at marriage (in months)

*gen age_at_marriage=(nis1_tar_yy-leda_yy)*12+(nis1_tar_mm-leda_mm)
*gen age_at_first_birth_y=gil_yld1_yy-leda_yy

gen age_at_first_birth_years=gil_yld1_yy-leda_yy
gen age_at_marriage_years=(nis1_tar_yy-leda_yy)

	
*Generate variables for having children and getting married x years after graduation
foreach i in 9 10 11 {
	gen kids_`i'_afterSchool = 0
	gen marr_`i'_afterSchool = 0
	replace kids_`i'_afterSchool = 1 if (gil_yld1_yy<=2000+`i' & year==2000) | (gil_yld1_yy<=2001+`i' & year==2001)
	replace marr_`i'_afterSchool = 1 if (nis1_tar_yy<=2000+`i' & year==2000) | (nis1_tar_yy<=2001+`i' & year==2001)
	}

*alternative bandwidth
***Bandwidth 37-54***
di "Bandwidth 37-54"
gen RD_new=1 if  tmp_b>0.37 & tmp_b<0.4
replace RD_new =1 if  tmp_b>0.52 & tmp<0.54
tab RD_new treatment
gen RD_alternative1 = RD
replace RD_alternative1=1 if RD_new==1
***Bandwidth 38-54***
di "Bandwidth 38-53"
drop RD_new
gen RD_new=1 if  tmp_b>0.38 & tmp_b<0.4
replace RD_new =1 if  tmp_b>0.52 & tmp<0.53
tab RD_new treatment
gen RD_alternative2 = RD
replace RD_alternative2=1 if RD_new==1

keep if (RD==1) |(NE==1) |(RD_alternative2==1) |(RD_alternative1==1)


keep NE RD RD_alternative1 RD_alternative2 year  /// 
m_ahim educav educem ole boy asiafr euram school_code school_codeYear /// 
yeladim kids age_at_first_birth_years age_at_marriage_years married /// 
att_lgcr att_lgsc awr_lgcr e_awr_lgcr hoodWeight /// 
sum_wage_9_afterSchoola sum_wage_10_afterSchoola sum_wage_11_afterSchoola /// 
months_9_afterSchoola months_10_afterSchoola months_11_afterSchoola /// 
work_9_afterSchoola work_10_afterSchoola work_11_afterSchoola /// 
avt_9_afterSchool avt_10_afterSchool avt_11_afterSchool /// 
avt_tot_9_afterSchool avt_tot_10_afterSchool avt_tot_11_afterSchool /// 
pctle_wage_9_afterSchool pctle_wage_10_afterSchool pctle_wage_11_afterSchool ///
A_10_afterSchool A_11_afterSchool A_12_afterSchool /// 
uni_10_afterSchool uni_11_afterSchool uni_12_afterSchool /// 
B_10_afterSchool B_11_afterSchool B_12_afterSchool /// 
col_10_afterSchool col_11_afterSchool col_12_afterSchool /// 
E_10_afterSchool E_11_afterSchool E_12_afterSchool /// 
educ_10_afterSchool educ_11_afterSchool educ_12_afterSchool /// 
kids_9_afterSchool kids_10_afterSchool kids_11_afterSchool /// 
marr_9_afterSchool marr_10_afterSchool marr_11_afterSchool /// 
before after treatment control afterXtreatment q3 q4 schtype /// 
av_avwage00_02 em_avwage00_02 house_avwage00_02 house_avwage00_02H house_avwage00_02L 

*in NE sample, in main RD sample, in alternative RD sample 1, in alternative RD sample 2, year at 12th grade
*number of siblings, father's y of education, mother's y of education, immigrant indicator, name, asia-africa origin, european-american origin, school code, school code for different for the two years
*number of kids, kids indicator, name, name
*attempted bagrut credits, attempted bagrut score, awarded bagrut credits, awarded bagrut credits in english, student weight (see article)
*total yearly earnings 9,10,11 years after graduation
*months worked 9,10,11 years after graduation
*has worked indicator 9,10,11 years after graduation
*has received unemployment insurance indicator 9,10,11 years after graduation
*amount of received unemployment insurance 9,10,11 years after graduation
*percentile rank 9,10,11 years after graduation
*ever attended university 10,11,12 years after graduation
*years attended university 10,11,12 years after graduation
*ever attended college 10,11,12 years after graduation
*years attended college 10,11,12 years after graduation
*ever attended post secondary 10,11,12 years after graduation
*years attended post secondary 10,11,12 years after graduation
*had kids 9,10,11 years after graduation
*married 9,10,11 years after graduation
*before treatment indicator, after treatment indicator, control indicator, treatment indicator, after and treatment indicator, in 3 quartiles, in all quartiles (1 for all), school type
*father's average earnings 2000-2002, mother's average earnings 2000-2002, household average earnings 2000-2002, in top 50% household earnings indicator, in bottom 50% household earnings indicator


save data\PublicationDataSet.dta, replace 

cap log close

