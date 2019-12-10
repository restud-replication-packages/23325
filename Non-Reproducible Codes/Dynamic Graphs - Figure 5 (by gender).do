/************************************************
Dynamic Figures - Figure 5

Description: this file creates and saves figure 5 - dynamic effects of the teacher's bonuses program on both genders. This file requires the full data set, "BL_SAMPLE_FULL_UPDATED_WithParents".
Please see readme. It is not possible to run this code outside the ISS lab.

Please contact the author if you wish to reproduce these results at the ISS lab.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text

global name DynamicGraphs_byGender

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

***Drop if wage is negative (this applies only to the b and c definitions***

foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	drop if sum_wage_`year'a<0
	drop if sum_wage_`year'b<0
	drop if sum_wage_`year'c<0
	}

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
	local years_after_school = `year'-2001
	gen `var'_`years_after_school'_afterSchool = `var'`year'
	local yearMinus1 = `year'-1
	replace `var'_`years_after_school'_afterSchool = `var'`yearMinus1' if year==2000
	}
	}

	
	
	
foreach year in 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	local years_after_school = `year'-2001
	gen sum_wage_`years_after_school'_afterSchool = sum_wage_`year'a
	gen work_`years_after_school'_afterSchool = work_`year'a
	*gen sum_wage_`years_after_school'_afterSchoolb = sum_wage_`year'b
	*gen sum_wage_`years_after_school'_afterSchoolc = sum_wage_`year'c
	local yearMinus1 = `year'-1
	replace sum_wage_`years_after_school'_afterSchool = sum_wage_`yearMinus1'a if year==2000
	replace work_`years_after_school'_afterSchool = work_`yearMinus1'a if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolb = sum_wage_`yearMinus1'b if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolc = sum_wage_`yearMinus1'c if year==2000
	}

	
	

***WITH CONTROLS - entire sample***

local i = 0

foreach sample in NE {  

	local i = `i' + 1
						
	foreach group in q4  {
	
		postfile values str50 rowKey year Gender Binteraction SEinteraction using "results\automatic\\Dynamic_Graph_by_gender_`sample'_`group'_boys_educ_Lag", replace		
	
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
			
			foreach var in sum_wage {
			foreach yearsAfterSchool in   0 1 2 3 4 5 6 7 8 9 10 11{
						sum `var'_`yearsAfterSchool'_afterSchool [fweight=hoodWeight] if treatment ==1 &  year==2000 
                         sum `var'_`yearsAfterSchool'_afterSchool  if treatment ==1 &  year==2000
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
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] if boy==1, cluster(school_code) 
				local B3boy`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3boy`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]

				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] if boy==0, cluster(school_code) 
				local B3girl`var'_`yearsAfterSchool'_afterSchool = _b[afterXtreatment]
				local SE3girl`var'_`yearsAfterSchool'_afterSchool = _se[afterXtreatment]
				
				}
				
				else{
				xi: reg `var'_`yearsAfterSchool'_afterSchool afterXtreatment att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code, cluster(school_code)
				}
				
				*local B0`var'_`yearsAfterSchool'_afterSchool = _b[_cons]

				post values  ("`var'") (`yearsAfterSchool')  (1) (`B3boy`var'_`yearsAfterSchool'_afterSchool')  (`SE3boy`var'_`yearsAfterSchool'_afterSchool')
				post values  ("`var'") (`yearsAfterSchool')  (0) (`B3girl`var'_`yearsAfterSchool'_afterSchool')  (`SE3girl`var'_`yearsAfterSchool'_afterSchool')
				
				
				// COUNTING NUMBER OF OBSERVATIONS

				count if treatment == 1 & before == 1
				local ntb = r(N)

				count if (treatment == 1 | control == 1) & (after == 1 | before == 1) 
				local n = r(N)

				*post values ("N OBS `sample'_treated_before") (`ntb') (.)
				*post values ("N OBS `sample'") (`n') (.) 
				
				if `i' != 3{
				su treatment if treatment == 1 & before == 1 [fweight=hoodWeight] 
				local wntb = r(N)

				*su E if (treatment == 1 | control == 1) & (after == 1 | before == 1)  [fweight=hoodWeight] 
				*local wn = r(N)
				
				*post values ("Weighted N OBS `sample'+treated_before")  (`wntb') (.)
				*post values ("Weighted N OBS `sample'")  (`wn') (.) 
				*post values ("") (.) (.)
				}
				
				
				}				
				
				}
						
			
				postclose values
				
				/**************************************************
				V. REFORMAT DATA TO CSV 
				***************************************************/

				
				use "results\automatic\\Dynamic_Graph_by_gender_`sample'_`group'_boys_educ_Lag", clear

				
				tw line Binteraction year if rowKey == "sum_wage" & Gender==0, yaxis(1) lpattern(dash)   || line Binteraction year if rowKey == "sum_wage" & Gender==1, yaxis(1) xlabel(0 1 2 3 4 5 6 7 8 9 10 11,labsize(vsmall) grid) ytitle("New Israeli Shekels (NIS)", size(small))  ylabel(-6000 -4000 -2000 0 2000 4000 6000 8000, ax(1) labsize(vsmall)) xtitle("Years since High School graduation", size(small)) legen(size(small) cols(1) order(1 2) label(1 "Treatment estimate - boys") label(2 "Treatment estimate - girls")) b1title("FIGURE 5 -" "Mean and treatment effect: annual earnings by gender, prices in 2009 NIS (natural experiment sample)", ring(5) size(small)) graphregion(color(white))
				graph export "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\results\automatic\Graph_5.eps", as(eps) preview(off) replace
				graph export "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\results\automatic\Graph_5.pdf", as(pdf) replace
*** no title
				tw line Binteraction year if rowKey == "sum_wage" & Gender==0, yaxis(1) lpattern(dash)   || line Binteraction year if rowKey == "sum_wage" & Gender==1, yaxis(1) xlabel(0 1 2 3 4 5 6 7 8 9 10 11,labsize(vsmall) grid) ytitle("New Israeli Shekels (NIS)", size(small))  ylabel(-6000 -4000 -2000 0 2000 4000 6000 8000, ax(1) labsize(vsmall)) xtitle("Years since High School graduation", size(small)) legen(size(small) cols(1) order(1 2) label(1 "Treatment estimate - boys") label(2 "Treatment estimate - girls")) graphregion(color(white))
				graph export "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\results\automatic\Graph_5_no_title.eps", as(eps) preview(off) replace
				graph export "W:\victor_lavi\Incoming\olim1\elior\Teachers Bonuses\results\automatic\Graph_5_no_title.pdf", as(pdf) replace
	
				outsheet using "results\automatic\\Dynamic_graphsGender_`sample'_`group'_all.csv", replace comma

				erase "results\automatic\\Dynamic_Graph_by_gender_`sample'_`group'_boys_educ_Lag.dta"
				
				restore
			
				}
				
		}
		
		


cap log close

