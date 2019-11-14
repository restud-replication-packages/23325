/************************************************
Creator: Genia

Created: August 2018

Description: this files creates all the DID results 11 years after graduation NE sample one by one
post secondary education, labor outcomes, personal outcomes and high school outcomes 

creates Clustered SE and wild bootstrap SE , possible to remove wild bootstrap calculation if not needed

			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text
*sysdir set BASE W:\victor_lavi\ado\base
*sysdir set PLUS W:\victor_lavi\ado\base

global name DID_T2_NE
*Boot

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


*use data\BL_SAMPLE_FULL_UPDATED_WithParents, clear
use data\BL_SAMPLE_FULL_UPDATED_WithParents_with_madmug, clear
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

*drop if sum_wage_2000a > 400000 |sum_wage_2001a > 400000 |sum_wage_2002a > 400000 |sum_wage_2003a > 400000 |sum_wage_2004a > 400000 |sum_wage_2005a > 400000 |sum_wage_2006a > 400000 |sum_wage_2007a > 400000 |sum_wage_2008a > 400000 |sum_wage_2009a > 400000 | sum_wage_2010a > 400000 | sum_wage_2011a > 400000 | sum_wage_2012a > 400000 | sum_wage_2013a > 400000

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

	
	
/*	
foreach year in 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
	local years_after_school = `year'-2001
	gen sum_wage_`years_after_school'_afterSchoola = sum_wage_`year'a
	gen work_`years_after_school'_afterSchoola = work_`year'a
	*gen sum_wage_`years_after_school'_afterSchoolb = sum_wage_`year'b
	*gen sum_wage_`years_after_school'_afterSchoolc = sum_wage_`year'c
	local yearMinus1 = `year'-1
	replace sum_wage_`years_after_school'_afterSchoola = sum_wage_`yearMinus1'a if year==2000
	replace work_`years_after_school'_afterSchoola = work_`yearMinus1'a if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolb = sum_wage_`yearMinus1'b if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolc = sum_wage_`yearMinus1'c if year==2000
	}
	
	*/
	
	foreach year in  2010 2011 2012  {
	local years_after_school = `year'-2001
	gen sum_wage_`years_after_school'_afterSchoola = sum_wage_`year'a
	gen work_`years_after_school'_afterSchoola = work_`year'a
	*gen sum_wage_`years_after_school'_afterSchoolb = sum_wage_`year'b
	*gen sum_wage_`years_after_school'_afterSchoolc = sum_wage_`year'c
	local yearMinus1 = `year'-1
	replace sum_wage_`years_after_school'_afterSchoola = sum_wage_`yearMinus1'a if year==2000
	replace work_`years_after_school'_afterSchoola = work_`yearMinus1'a if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolb = sum_wage_`yearMinus1'b if year==2000
	*replace sum_wage_`years_after_school'_afterSchoolc = sum_wage_`yearMinus1'c if year==2000
		gen months_`years_after_school'_afterSchoola = sum_month_`year'a

	gen avt_`years_after_school'_afterSchool = avt`year'
	gen avt_tot_`years_after_school'_afterSchool = avt_tot`year'
	replace months_`years_after_school'_afterSchoola = sum_month_`yearMinus1'a if year==2000
	replace avt_`years_after_school'_afterSchool = avt`yearMinus1' if year==2000
	replace avt_tot_`years_after_school'_afterSchool = avt_tot`yearMinus1' if year==2000
	}

	gen alll=1
	*gen afterXtemp = after*tmp_b 
		*gen afterXtemp2 = after*tmp_b*tmp_b
*gen afterXtemp3 = afterXtemp2*tmp_b
gen zakaut = zak99


replace zakaut = zak00 if year==2001
*replace zakaut=att_lgcr
g tmp_b2 = tmp_bg*tmp_bg
g tmp_b3 = tmp_bg*tmp_bg*tmp_bg
*replace A_12_afterSchool = sum_wage_11_afterSchoola
*replace uni_12_afterSchool =work_11_afterSchoola
*g tmp_b2=tmp_b*tmp_b 
*g tmp_b3 = tmp_b *tmp_b *tmp_b  
			***WITH CONTROLS -***
			
			
			
			
*Generate age at birth of first child (in months)
gen  age_at_first_birth=(gil_yld1_yy-leda_yy)*12+(gil_yld1_mm-leda_mm)

*Generate age at marriage (in months)

gen age_at_marriage=(nis1_tar_yy-leda_yy)*12+(nis1_tar_mm-leda_mm)


gen age_at_first_birth_y=gil_yld1_yy-leda_yy
gen age_at_marriage_y=(nis1_tar_yy-leda_yy)

	
	
	
*Generate variables for having children and getting married x years after graduation
foreach i in 0 1 2 3 4 5 6 7 8 9 10 11 {
	gen kids_`i'_afterSchool = 0
	gen marr_`i'_afterSchool = 0
	replace kids_`i'_afterSchool = 1 if (gil_yld1_yy<=2000+`i' & year==2000) | (gil_yld1_yy<=2001+`i' & year==2001)
	replace marr_`i'_afterSchool = 1 if (nis1_tar_yy<=2000+`i' & year==2000) | (nis1_tar_yy<=2001+`i' & year==2001)
	}
	

	
	
	

foreach sample in RD NE {  /* if you want to change the subsample to RD then change it here */
	preserve
	cap log close

	*DID
	cap postclose values
	postfile values str50 rowKey B0 num_obs using "results\automatic\\all", replace		
	di "${name}"
	*replace NE here for RD, for RD results


	log using "logs\\${name}_`day'`month'`year'`sample'4q.log", replace
	set more off
	
	local i = `i' + 1
						
	foreach group in  q4 {
	
		
			keep if `sample' == 1 & `group' == 1  


			
	/*		
	
	********************************************************
***                sample : `sample'          group: `group'               **		
*********************************************************			
			
			
			
	
	********************************************************
***                post secondary education outcomes                **		
*********************************************************		

	
	
	
	
	

			xi: reg   A_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
			sum A_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
		
		scalar df= e(N)-e(df_m)-1	
		local N1 = e(N)

			
				
*boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

/*scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
*di invttail(df,pv/2)
*di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B1 = _b[afterXtreatment]
				local C1 = _se[afterXtreatment]
*local P1 =  r(p)
local N1 = e(N)

**this regression documents the number of observations, unweighted in the log file.
			xi: reg A_12_afterSchool afterXtreatment  att_lgcr i.year i.school_code  , vce( cluster school_code)


*graph save A_12_afterSchoolNE9040.jpg

/*
 matrix xx= r(CI)

 local cl17= xx[1,1]
 
 local ch17= xx[1,2]
 
 dis `cl'
 dis `ch'
 
 local tt17 = invttail(df,pv/2)
 
 local pp17 = abs(_b[afterXtreatment]/invttail(df,pv/2))
 */
 
 *for regular DID
 local P1 =  0
 local cl17 = 0
 local ch17= 0
 local tt17 = 0
 local pp17 = 0
 					

xi: reg uni_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum uni_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

		scalar df= e(N)-e(df_m)-1	
			
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

	/*			
				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
*di invttail(df,pv/2)
*di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B2 = _b[afterXtreatment]
				local C2 = _se[afterXtreatment]
*local P2 =  r(p)
local N2 = e(N)
*graph save uni_12_afterSchoolNE90.jpg

/*
 matrix xx= r(CI)

 local cl18= xx[1,1]
 
 local ch18= xx[1,2]
 
 local tt18 = invttail(df,pv/2)
 
 local pp18 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/


	
 *for regular DID
 local P2 =  0
 local cl18 = 0
 local ch18 = 0
 local tt18 = 0
 local pp18 = 0
	
	
xi: reg B_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum B_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
			scalar df= e(N)-e(df_m)-1	
		
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
/*				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/

				local B3 = _b[afterXtreatment]
				local C3 = _se[afterXtreatment]
*local P3 =  r(p)
local N3 = e(N)
*graph save B_12_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl19= xx[1,1]
 
 local ch19= xx[1,2]
 
 local tt19 = invttail(df,pv/2)
 
 local pp19 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/
 *for regular DID
 local P3 =  0
 local cl19= 0
 local ch19= 0
 local tt19 = 0
 local pp19 = 0
	
xi: reg col_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum col_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
/*				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B4 = _b[afterXtreatment]
				local C4 = _se[afterXtreatment]
/*local P4 =  r(p)
*/
local N4 = e(N)
*graph save col_12_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl20= xx[1,1]
 
 local ch20= xx[1,2]
 
 local tt20 = invttail(df,pv/2)
 
 local pp20 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/
 *for regular DID
 local P3 =  4
 local cl20= 0
 local ch20= 0
 local tt20 = 0
 local pp20 = 0
	
	
	
xi: reg E_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum E_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
	/*			
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}*/

*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B5 = _b[afterXtreatment]
				local C5 = _se[afterXtreatment]
/*local P5 =  r(p)
*/
local N5 = e(N)
*graph save E_12_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl21= xx[1,1]
 
 local ch21= xx[1,2]
 
 local tt21 = invttail(df,pv/2)
 
 local pp21 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/
 *for regular DID
	
 local P5 =  4
 local cl21= 0
 local ch21= 0
 local tt21 = 0
 local pp21 = 0
	
	
	
xi: reg educ_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum educ_12_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
			scalar df= e(N)-e(df_m)-1	
		
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
/*				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}*/

*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B6 = _b[afterXtreatment]
				local C6 = _se[afterXtreatment]
/*local P6 =  r(p)
*/
local N6 = e(N)
*graph save educ_12_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl22= xx[1,1]
 
 local ch22= xx[1,2]
 
 local tt22 = invttail(df,pv/2)
 
 local pp22 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/
 		
*for regular DID
	
 local P6 =  4
 local cl22= 0
 local ch22= 0
 local tt22 = 0
 local pp22 = 0
	
	
********************************************************
***                labor outcomes                **		
*********************************************************		
	
	
	
	
xi: reg sum_wage_11_afterSchoola afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum sum_wage_11_afterSchoola if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
	/*			
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}*/

*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B7 = _b[afterXtreatment]
				local C7 = _se[afterXtreatment]
/*local P7 =  r(p)
*/
local N7 = e(N)
*graph save wages_11_afterSchoolRD90.jpg
/*

 matrix xx= r(CI)

 local cl1= xx[1,1]
 
 local ch1= xx[1,2]
 
 local tt1 = invttail(df,pv/2)
 
 local pp1 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/

*for regular DID
	
 local P7 =  0
 local cl1= 0
 local ch1= 0
 local tt1 = 0
 local pp1 = 0
	
	


xi: reg work_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
sum work_11_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
/*				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B8 = _b[afterXtreatment]
				local C8 = _se[afterXtreatment]
/*local P8 =  r(p)
*/
local N8 = e(N)
*graph save work_11_afterSchoolRD90.jpg
/*

 matrix xx= r(CI)

 local cl2= xx[1,1]
 
 local ch2= xx[1,2]
 
 local tt2 = invttail(df,pv/2)
 
 local pp2 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	*/
*for regular DID
	
 local P8 =  0
 local cl2= 0
 local ch2= 0
 local tt2 = 0
 local pp2 = 0	

 
	xtile psum_wage_2011a = sum_wage_11_afterSchoola, nquantiles(100) 
			
			xi: reg psum_wage_2011a afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum psum_wage_2011a if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

		scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}*/

*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B9 = _b[afterXtreatment]
				local C9 = _se[afterXtreatment]
/*local P9 =  r(p)
*/
local N9 = e(N)
*graph save psum_wage_2013aRD90.jpg
/*

 matrix xx= r(CI)

 local cl3= xx[1,1]
 
 local ch3= xx[1,2]
 
 local tt3 = invttail(df,pv/2)
 
 local pp3 = abs(_b[afterXtreatment]/invttail(df,pv/2))
 
 */
	*for regular DID
	
 local P9 =  0
 local cl3= 0
 local ch3= 0
 local tt3 = 0
 local pp3 = 0
	
	

	xi: reg avt_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
	sum avt_11_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	
/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B10 = _b[afterXtreatment]
				local C10 = _se[afterXtreatment]
/*local P10 =  r(p)
*/
local N10 = e(N)
*graph save avt_11_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl4= xx[1,1]
 
 local ch4= xx[1,2]
 
 local tt4 = invttail(df,pv/2)
 
 local pp4 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
	
*/
*for regular DID
	
 local P10 =  0
 local cl4= 0
 local ch4= 0
 local tt4 = 0
 local pp4 = 0
	
	
	xi: reg avt_tot_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum avt_tot_11_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

	scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B11 = _b[afterXtreatment]
				local C11 = _se[afterXtreatment]
/*local P11 =  r(p)
*/
local N11 = e(N)
*graph save avt_tot_11_afterSchoolRD90.jpg

/*
 matrix xx= r(CI)

 local cl5= xx[1,1]
 
 local ch5= xx[1,2]
 
 local tt5 = invttail(df,pv/2)
 
 local pp5 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
	
	*/
	*for regular DID
	
 local P11 =  0
 local cl5= 0
 local ch5= 0
 local tt5 = 0
 local pp5 = 0
	

xi: reg months_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum months_11_afterSchool if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

			scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B12 = _b[afterXtreatment]
				local C12 = _se[afterXtreatment]
/*local P12 =  r(p)
*/
local N12 = e(N)
*graph save months_11_afterSchoolRD90.jpg

/*

 matrix xx= r(CI)

 local cl6= xx[1,1]
 
 local ch6= xx[1,2]
 
 local tt6 = invttail(df,pv/2)
 
 local pp6 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
 
 */
 *for regular DID
	
 local P12 =  0
 local cl6= 0
 local ch6= 0
 local tt6 = 0
 local pp6 = 0
 
 
 */
 
 		
********************************************************
***                personal status outcomes                **		
*********************************************************	
 

	
	
	
	
	*married kids yeladim age_at_marriage_y age_at_marriage age_first_birth_y    age_at_first_birth    
	
	


	
	
	
xi: reg married afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum married if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B13 = _b[afterXtreatment]
				local C13 = _se[afterXtreatment]
/*local P13 =  r(p)
*/
local N13 = e(N)
*graph save married_RD90.jpg

/*
 matrix xx= r(CI)

 local cl7= xx[1,1]
 
 local ch7= xx[1,2]
 
 local tt7 = invttail(df,pv/2)
 
 local pp7 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
 */
 *for regular DID
	
 local P13 =  0
 local cl7= 0
 local ch7= 0
 local tt7 = 0
 local pp7 = 0
 	
xi: reg kids afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum kids if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B14 = _b[afterXtreatment]
				local C14 = _se[afterXtreatment]
/*local P14 =  r(p)
*/
local N14 = e(N)
*graph save kids_RD90.jpg
/*

 matrix xx= r(CI)

 local cl8= xx[1,1]
 
 local ch8= xx[1,2]
 
 local tt8 = invttail(df,pv/2)
 
 local pp8 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
	
	*/

*for regular DID
	
 local P14 =  0
 local cl8= 0
 local ch8= 0
 local tt8 = 0
 local pp8 = 0
xi: reg yeladim afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum yeladim if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B15 = _b[afterXtreatment]
				local C15 = _se[afterXtreatment]
*local P15 =  r(p)
local N15 = e(N)
*graph save yeladim_RD90.jpg
/*

 matrix xx= r(CI)

 local cl9= xx[1,1]
 
 local ch9= xx[1,2]
 
 local tt9 = invttail(df,pv/2)
 
 local pp9 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		*/
		 *for regular DID
	
 local P15 =  0
 local cl9= 0
 local ch9= 0
 local tt9 = 0
 local pp9 = 0

		
xi: reg age_at_marriage_y afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum age_at_marriage_y if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

		scalar df= e(N)-e(df_m)-1	

		
/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B16 = _b[afterXtreatment]
				local C16 = _se[afterXtreatment]
*local P16 =  r(p)
local N16 = e(N)
*graph save age_at_marriage_y_RD90.jpg

/*
 matrix xx= r(CI)

 local cl10= xx[1,1]
 
 local ch10= xx[1,2]
 
 local tt10 = invttail(df,pv/2)
 
 local pp10 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		
*/
 *for regular DID
	
 local P16 =  0
 local cl10= 0
 local ch10= 0
 local tt10 = 0
 local pp10 = 0
		
		
		
		
xi: reg age_at_marriage afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum age_at_marriage if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

		scalar df= e(N)-e(df_m)-1	

		
/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}
*/
*****SE cluster****
di _se[afterXtreatment]
/*
*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B17 = _b[afterXtreatment]
				local C17 = _se[afterXtreatment]
*local P17 =  r(p)
local N17 = e(N)
*graph save age_at_marriage_RD90.jpg

/*
 matrix xx= r(CI)

 local cl23= xx[1,1]
 
 local ch23= xx[1,2]
 
 local tt23 = invttail(df,pv/2)
 
 local pp23 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
	*/
	 *for regular DID
	
 local P17 =  0
 local cl23= 0
 local ch23= 0
 local tt23 = 0
 local pp23 = 0
			
	xi: reg age_at_first_birth_y afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum age_at_first_birth_y if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B18 = _b[afterXtreatment]
				local C18 = _se[afterXtreatment]
*local P18 =  r(p)
local N18 = e(N)
*graph save age_at_first_birth_y_RD90.jpg
/*

 matrix xx= r(CI)

 local cl24= xx[1,1]
 
 local ch24= xx[1,2]
 
 local tt24 = invttail(df,pv/2)
 
 local pp24 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		
*/
	 *for regular DID
	
 local P18 =  0
 local cl24= 0
 local ch24= 0
 local tt24 = 0
 local pp24 = 0

	
xi: reg age_at_first_birth afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum age_at_first_birth if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B19 = _b[afterXtreatment]
				local C19 = _se[afterXtreatment]
*local P19 =  r(p)
local N19 = e(N)
*graph save age_at_first_birth_RD90.jpg

/*
 matrix xx= r(CI)

 local cl11= xx[1,1]
 
 local ch11= xx[1,2]
 
 local tt11 = invttail(df,pv/2)
 
 local pp11 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		
*/
 *for regular DID
	
 local P19 =  0
 local cl11= 0
 local ch11= 0
 local tt11 = 0
 local pp11 = 0
		
		
********************************************************
***                high school outcomes                **		
*********************************************************	

*wbonus zakaibag units mik_mug madmug

	*
xi: reg wbonus afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr  asiafr ole boy educav educem m_ahim  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum wbonus if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B20 = _b[afterXtreatment]
				local C20 = _se[afterXtreatment]
*local P20 =  r(p)
local N20 = e(N)
*graph save wbonus_RD90.jpg

/*
 matrix xx= r(CI)

 local cl12= xx[1,1]
 
 local ch12= xx[1,2]
 
 local tt12 = invttail(df,pv/2)
 
 local pp12 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		*/
	 *for regular DID
	
 local P20 =  0
 local cl12= 0
 local ch12= 0
 local tt12 = 0
 local pp12 = 0

	
	*
xi: reg zakaibag afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum zakaibag if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B21 = _b[afterXtreatment]
				local C21 = _se[afterXtreatment]
*local P21 =  r(p)
local N21 = e(N)
*graph save zakaibag_RD90.jpg

/*
 matrix xx= r(CI)

 local cl13= xx[1,1]
 
 local ch13= xx[1,2]
 
 local tt13 = invttail(df,pv/2)
 
 local pp13 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		*/

		 *for regular DID
	
 local P21 =  0
 local cl7= 0
 local ch7= 0
 local tt7 = 0
 local pp7 = 0
		
		
xi: reg units afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum units if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B22 = _b[afterXtreatment]
				local C22 = _se[afterXtreatment]
*local P22 =  r(p)
local N22 = e(N)
*graph save units_RD90.jpg

/*
 matrix xx= r(CI)

 local cl14= xx[1,1]
 
 local ch14= xx[1,2]
 
 local tt14 = invttail(df,pv/2)
 
 local pp14 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
*/
 *for regular DID
	
 local P22 =  0
 local cl14= 0
 local ch14= 0
 local tt14 = 0
 local pp14 = 0

 
 
 
 xi: reg mik_mug afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum mik_mug if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	

/*
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B23 = _b[afterXtreatment]
				local C23 = _se[afterXtreatment]
*local P23 =  r(p)
local N23 = e(N)
*graph save mik_mug_RD90.jpg

/*
 matrix xx= r(CI)

 local cl15= xx[1,1]
 
 local ch15= xx[1,2]
 
 local tt15 = invttail(df,pv/2)
 
 local pp15 = abs(_b[afterXtreatment]/invttail(df,pv/2))		

 */
  *for regular DID
	
 local P23 =  0
 local cl15= 0
 local ch15= 0
 local tt15 = 0
 local pp15 = 0
 
 
 
  xi: reg madmug afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			sum madmug if year==2000 & treatment==1 & `sample' == 1 & `group' == 1 [fweight=hoodWeight]

				scalar df= e(N)-e(df_m)-1	


/*boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(semelmos)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))
*/
				local B24 = _b[afterXtreatment]
				local C24 = _se[afterXtreatment]
*local P24 =  r(p)
local N24 = e(N)
*graph save mad_mug_RD90.jpg

/*
 matrix xx= r(CI)

 local cl16= xx[1,1]
 
 local ch16= xx[1,2]
 
 local tt16 = invttail(df,pv/2)
 
 local pp16 = abs(_b[afterXtreatment]/invttail(df,pv/2))		

	*/
	 *for regular DID
	
 local P24 =  0
 local cl16 = 0
 local ch16 = 0
 local tt16 = 0
 local pp16 = 0
	*wild bootstrap:
	{
	/*
				post values ("B A") 			 (`B1') (`P1')  (`cl17')  (`ch17')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C1') (`N1')  (`tt17')  (`pp17')  
				post values ("B uni") 			 (`B2') (`P2')  (`cl18')  (`ch18')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C2') (`N2')  (`tt18')  (`pp18') 
								post values ("B B") 			 (`B3') (`P3')  (`cl19')  (`ch19')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C3') (`N3')  (`tt19')  (`pp19')  
				post values ("B col") 			 (`B4') (`P4') (`cl20')  (`ch20')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C4') (`N4')  (`tt20')  (`pp20') 
				
				post values ("B E") 			(`B5') (`P5')  (`cl21')  (`ch21')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C5') (`N5')  (`tt21')  (`pp21')
				
								post values ("B educ") 			 (`B6') (`P6')  (`cl22')  (`ch22')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C6') (`N6')  (`tt22')  (`pp22')
				
				
				
					post values ("B wages") 			 (`B7') (`P7')  (`cl1')  (`ch1')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C7') (`N7')  (`tt1')  (`pp1') 			
				
				
				post values ("B work") 			 (`B8') (`P8')  (`cl2')  (`ch2')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C8') (`N8')  (`tt2')  (`pp2') 
								post values ("B pwages") 			 (`B9') (`P9')  (`cl3')  (`ch3')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C9') (`N9')  (`tt3')  (`pp3')  
				post values ("B avt") 			 (`B10') (`P10')  (`cl4')  (`ch4')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C10') (`N10')  (`tt4')  (`pp4') 
								post values ("B avt_tot") 			 (`B11') (`P11')  (`cl5')  (`ch5')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C11') (`N11')  (`tt5')  (`pp5')  
				post values ("B months") 			 (`B12') (`P12')  (`cl6')  (`ch6')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C12') (`N12')  (`tt6')  (`pp6') 
								
								post values ("B married") 			 (`B13') (`P13')  (`cl7')  (`ch7')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C13') (`N13')  (`tt7')  (`pp7')  
				post values ("B kids") 			 (`B14') (`P14')  (`cl8')  (`ch8')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C14') (`N14')  (`tt8')  (`pp8') 
								post values ("B yeladim") 			 (`B15') (`P15')  (`cl9')  (`ch9')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C15') (`N15')  (`tt9')  (`pp9')  
				post values ("B age_at_marriage_y") 			 (`B16') (`P16') (`cl10')  (`ch10')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C16') (`N16')  (`tt10')  (`pp10') 		
												post values ("B age_at_marriage") 			 (`B17') (`P17') (`cl23')  (`ch23')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C17') (`N17')  (`tt23')  (`pp23')  
				post values ("B age_first_birth_y") 			 (`B18') (`P18')  (`cl24')  (`ch24')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C18') (`N18')  (`tt24')  (`pp24') 
						post values ("B age_at_first_birth") 			 (`B19') (`P19') (`cl11')  (`ch11')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C19') (`N19')  (`tt11')  (`pp11') 
						
						
						
						post values ("B wbonus") 			 (`B20') (`P20') (`cl12')  (`ch12')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C20') (`N20')  (`tt12')  (`pp12') 
						post values ("B zakaibag") 			 (`B21') (`P21')  (`cl13')  (`ch13')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C21') (`N21')  (`tt13')  (`pp13') 
						post values ("B units") 			 (`B22') (`P22') (`cl14')  (`ch14')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C22') (`N22')  (`tt14')  (`pp14') 
						post values ("B mik_mug") 			 (`B23') (`P23')  (`cl15')  (`ch15')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C23') (`N23')  (`tt15')  (`pp15') 
										post values ("B mad_mug") 			 (`B24') (`P24') (`cl16')  (`ch16')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C24') (`N24')  (`tt16')  (`pp16') 
					*married kids yeladim age_at_marriage_y age_at_marriage age_first_birth_y    age_at_first_birth   
					*/
					}
	*DID:

				*post values ("B A") 			 (`B1') (`N1')  
				*post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C1') (`N1')  
				*post values ("B uni") 			 (`B2') (`N2')  
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C2') (`N2')  
				*di "2"
				*post values ("B B") 			 (`B3') (`N3')  
				*post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C3') (`N3')  
				*post values ("B col") 			 (`B4') (`N4') 
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C4') (`N4')
				*di "4"
				*post values ("B E") 			(`B5') (`N5')  
				*post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C5') (`N5')  
				
				*post values ("B educ") 			 (`B6') (`N6')  
				*post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C6') (`N6')  
				*di "6"
				
				
	*			post values ("B wages") 			 (`B7') (`N7')  
	*			post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C7') (`N7')  
	*						
	*			post values ("B work") 			 (`B8') (`N8')  
	*			post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C8') (`N8')  
	*			di "8"
	*			post values ("B pwages") 			 (`B9') (`N9') 
	*			post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C9') (`N9')  
	*			post values ("B avt") 			 (`B10') (`N10')
	*			post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C10') (`N10')
	*			di "10"
	*			post values ("B avt_tot") 			 (`B11') (`N11') 
	*			post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C11') (`N11')  
	*			post values ("B months") 			 (`B12') (`N12')  
	*			post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C12') (`N12')   
	*			di "12"		
				post values ("B married") 			 (`B13') (`N13')  
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C13') (`N13')  
				post values ("B kids") 			 (`B14') (`N14')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C14') (`N14')  
				di "14"
				post values ("B yeladim") 			 (`B15') (`N15') 
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C15') (`N15')  
				post values ("B age_at_marriage_y") 			 (`B16') (`N16') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C16') (`N16')  		
				di "16"
				post values ("B age_at_marriage") 			 (`B17') (`N17')
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C17') (`N17')    
				post values ("B age_first_birth_y") 			 (`B18') (`N18')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C18') (`N18')   
				di "18"
				post values ("B age_at_first_birth") 			 (`B19') (`N19') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C19') (`N19')  
						
				post values ("B wbonus") 			 (`B20') (`N20') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C20') (`N20')  
				
				*di "20"
				post values ("B zakaibag") 			 (`B21') (`N21') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C21') (`N21') 
				post values ("B units") 			 (`B22') (`N22') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C22') (`N22')   
				*di"22"
				post values ("B mik_mug") 			 (`B23') (`N23')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C23') (`N23')   
				post values ("B mad_mug") 			 (`B24') (`N24') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C24') (`N24')  
				*di "24"
				*married kids yelpctle_wage_stack_adjustedadim age_at_marriage_y age_at_marriage age_first_birth_y    age_at_first_birth   
					
		}
			postclose values
			use "results\automatic\\all", clear

			outsheet using "results\automatic\\Table2_4_A3cont_`sample'.csv", replace comma

			erase "results\automatic\\all.dta"
			restore
		}
			
			
			
				



	log close
	
