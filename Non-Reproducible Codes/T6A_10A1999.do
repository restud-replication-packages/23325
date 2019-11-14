/************************************************

Creator: Assaf

Created: Mar 2017

Description: Revision checks - clustering at school level (instead of school-year). this code is based on 
W:\victor_lavi\Incoming\olim1\Boaz\Teachers Bonuses\programs\Wage and Work\Table4_DID_AgeAdjusted.do 
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name T6A_T10A_1999_

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

append using "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\Palcebo_sample_1999_11May17", force
*cap drop _f
*append using "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\Palcebo_sample_1999_May17.dta", force

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

replace school_codeYear = school_code * 1000 if year == 2000

* KEEP INDIVIDUALS WITH POSITIVE WAGE *
*keep if (sum_wage_2009a > 0 & sum_wage_2010a > 0 & sum_wage_2011a > 0 & sum_wage_2012a > 0) & (work_2009 == 1 & work_2010 == 1 & work_2011 == 1 & work_2012 == 1) 

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
changed according to the referees' suggestion
***************************************************/
*constructing schools constant vars

foreach var in educav educem m_ahim {
replace `var'=. if `var'==99
replace `var'=0 if `var'==88
replace `var'=25 if `var'>25 & `var'!=.
}

foreach var in treated inRD inNE school_code {
bysort semelmos: egen `var'_temp=mean(`var')
replace `var'= `var'_temp if year==1999
drop `var'_temp
}
*Constructing New Before and After

drop if year==2001
gen before = (year == 1999)
gen after = (year == 2000)

************************************

/*
drop if year==1999

gen before = (year == 2000)
gen after = (year == 2001)
*/

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
gen q_1 = (q==1)
gen q_2 = (q==2)
gen q_3 = (q==3)
gen q_4 = (q==4)

*** SET EXPERIMENT SAMPLE GROUPS ***
rename inNE NE
rename inRD RD
rename inEL EL


***Sum up all forms of education except university***
foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
	gen NonUniEduc`year' = col`year'+teach`year'+semeng`year'+other`year'
	gen NonUniEnrol`year' = max(B`year', C`year', S`year', O`year')
	gen AtLeast3Uni`year' = (uni`year'>=3)
	gen AtLeast4Uni`year' = (uni`year'>=4)
	gen AtLeast5Uni`year' = (uni`year'>=5)
}

***Generate lag education for the 2000 cohort (E A B C S O educ uni col teach semeng other)
foreach var in E A B C S O educ uni col teach semeng other NonUniEduc NonUniEnrol AtLeast3Uni AtLeast4Uni AtLeast5Uni {
foreach year in 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
	local years_after_school = `year'-2000
	gen `var'_`years_after_school'_afterSchool = `var'`year'
	local yearMinus1 = `year'-1
	replace `var'_`years_after_school'_afterSchool = `var'`yearMinus1' if year==1999
	}
	}

	
***Generate lag earnings for the 2000 cohort


		
	foreach year in  2010 2011 2012 {
	local years_after_school = `year'-2000
	gen sum_wage_`years_after_school'_afterSchoola = sum_wage_`year'a
	gen work_`years_after_school'_afterSchoola = work_`year'a
	
	local yearMinus1 = `year'-1
	replace sum_wage_`years_after_school'_afterSchoola = sum_wage_`yearMinus1'a if year==1999
	replace work_`years_after_school'_afterSchoola = work_`yearMinus1'a if year==1999
	gen months_`years_after_school'_afterSchoola = sum_month_`year'a
	replace months_`years_after_school'_afterSchoola = sum_month_`yearMinus1'a if year==1999
	
	}
	


*To run table only on the sub-sample above median for household income
*keep if house_avwage00_02H==1

*To run table only on the sub-sample of boys
*keep if boy==1

/**************************************************
IV. RUN DID REGRESSIONS - PART I (FULL SAMPLE) 
***************************************************/

/***************
DEFINITION A
**************/

replace school_code = semelmos
	
**2000 to 2002 placebo**
local i = 0

foreach sample in NE {  

	local i = `i' + 1
						
	foreach group in q4 {
	
		postfile values str50 rowKey B0 Binteraction using "results\automatic\\Table_4_lagged_`sample'_`group'_incomeALagged", replace	
	
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
			
			foreach var in sum_wage work months{
			foreach yearsAfterSchool in  11  {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls placebo 1999-2000"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchoola"
				di ""
				di "Cohorts: 1999,2002"0
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {

				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment   ole boy educav educem m_ahim i.year i.school_code , cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchoola afterXtreatment   ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				
			
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1 
				local B0`var'_`yearsAfterSchool'_afterSchoola = r(mean)
				local S0`var'_`yearsAfterSchool'_afterSchoola = r(sd)
			
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`S0`var'_`yearsAfterSchool'_afterSchoola') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("") (.) (.)
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1  
				local wntb = r(N)

				su E if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
				}
				
				}				
				}
			{

			foreach var in A B col uni{
			foreach yearsAfterSchool in  12 {
			
				di "*********************************************************"
				di ""
				di "SIMPLE DD with FE and controls placebo 2000-2002"
				di ""
				di "Outcome: `var'_`yearsAfterSchool'_afterSchool"
				di ""
				di "Cohorts: 1999,2000"
				di ""
				di "Sample: `sample'"
				di ""
				di "*********************************************************"
				di ""
						
				if `i' != 3 {
				tab year
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment  ole boy educav educem m_ahim i.year i.school_code  , cluster(school_code)
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment  ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				
			
				local B3`var'_`yearsAfterSchool'_afterSchoola = _b[afterXtreatment]
				local SE3`var'_`yearsAfterSchool'_afterSchoola = _se[afterXtreatment]
				
				su `var'_`yearsAfterSchool'_afterSchool if treatment == 1 & before == 1 
				local B0`var'_`yearsAfterSchool'_afterSchoola = r(mean)
				local S0`var'_`yearsAfterSchool'_afterSchoola = r(sd)
			
		
				post values ("B `var'_`yearsAfterSchool'_afterSchoola") 			 (`B0`var'_`yearsAfterSchool'_afterSchoola') (`B3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("SCHOOL YEAR CLUSTERED SE `var'_`yearsAfterSchool'_afterSchoola")   (`S0`var'_`yearsAfterSchool'_afterSchoola') (`SE3`var'_`yearsAfterSchool'_afterSchoola') 
				post values ("") (.) (.)
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				post values ("N OBS `sample'_treated_before") (`ntb') (.)
				post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1  [fweight=hoodWeight] 
				local wntb = r(N)

				su E if (treatment == 1 | control == 1) & (after == 1 | before == 1) [fweight=hoodWeight] 
				local wn = r(N)
				
				post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.) 
				post values ("Weighted N OBS `sample'")  (`wn') (.)  
				post values ("") (.) (.)
				}
				
				}				
				}

			}
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				use "results\automatic\\Table_4_lagged_`sample'_`group'_incomeALagged", clear

				outsheet using "results\automatic\\{$name}_`sample'_`group'.csv", replace comma

				erase "results\automatic\\Table_4_lagged_`sample'_`group'_incomeALagged.dta"
				
				restore
			
				}
				
		}		
cap log close
