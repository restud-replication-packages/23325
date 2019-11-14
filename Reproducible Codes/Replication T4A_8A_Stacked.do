/************************************************
Tables 8A Stacked

Description: This do file runs the familiar DID framework for all outcomes, and calculates bootstrap standard errors. 
Note that the package boottest, which can be downloaded with the command “ssc install boottest” from within Stata. 
See documentation at https://ideas.repec.org/c/boc/bocode/s458121.html.
Results depend on seed set. May take some time to run on older / less powerful machines.

Citation for package:
David Roodman, 2015. "BOOTTEST: Stata module to provide fast execution of the wild bootstrap with null imposed," Statistical Software Components S458121, Boston College Department of Economics, revised 05 Sep 2019.
			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text


global name Boot_stacked

local today = "$S_DATE"
local day = word("`today'",1)
local month = word("`today'",2)
local year = substr(word("`today'",3),3,2)
if `day' < 10 local `day' = "0`day'"

/**************************************************
I. ENTER THE PATH NAME WHERE THE DATA FILE IS FOUND
***************************************************/

cd "C:\Users\peleg\OneDrive\Documents\Victor\Other\Teacher Bonuses\For publication\Reproduction"

cap log close

log using "logs\\${name}_`day'`month'`year'.log", replace

use data\PublicationDataSet, clear

	cap log close	
	log using "logs\\${name}_`day'`month'`year'.log", replace
	set more off
	
	
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


foreach sample in NE RD{
	postfile values str50 rowKey estimated_effect Clustered_se Boot_se boot_t_statistic boot_pval boot_conf_l boot_conf_h N_obvs using "results\automatic\\all", replace		
	preserve
	local i = `i' + 1
						
	foreach group in  q4 {
	
		
			keep if `sample' == 1 & `group' == 1  


********************************************************
***                sample : `sample'          group: `group'               **		
*********************************************************			
			
			
			
	
********************************************************
***                post secondary education outcomes                **		
*********************************************************		

	
	
********************************************************
***                labor outcomes                **		
*********************************************************		
	
	
	
	
xi: reg sum_wage_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B7 = _b[afterXtreatment]
				local C7 = _se[afterXtreatment]
local P7 =  r(p)
local N7 = e(N)
*graph save wages_11_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl1= xx[1,1]
 
 local ch1= xx[1,2]
 
 local tt1 = invttail(df,pv/2)
 
 local pp1 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	

xi: reg sum_work_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
				scalar df= e(N)-e(df_m)-1	
	
				local B0A_12_afterSchool = _b[_cons]
				local B3A_12_afterSchool = _b[afterXtreatment]
				local SE3A_12_afterSchool = _se[afterXtreatment]

				
				
boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B8 = _b[afterXtreatment]
				local C8 = _se[afterXtreatment]
local P8 =  r(p)
local N8 = e(N)
*graph save work_11_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl2= xx[1,1]
 
 local ch2= xx[1,2]
 
 local tt2 = invttail(df,pv/2)
 
 local pp2 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	

 			
			xi: reg pctle_wage_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

		scalar df= e(N)-e(df_m)-1	


boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B9 = _b[afterXtreatment]
				local C9 = _se[afterXtreatment]
local P9 =  r(p)
local N9 = e(N)
*graph save psum_wage_2013aRD90.jpg


 matrix xx= r(CI)

 local cl3= xx[1,1]
 
 local ch3= xx[1,2]
 
 local tt3 = invttail(df,pv/2)
 
 local pp3 = abs(_b[afterXtreatment]/invttail(df,pv/2))
 
 
	
	

				xi: reg avt_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
		scalar df= e(N)-e(df_m)-1	

boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B10 = _b[afterXtreatment]
				local C10 = _se[afterXtreatment]
local P10 =  r(p)
local N10 = e(N)
*graph save avt_11_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl4= xx[1,1]
 
 local ch4= xx[1,2]
 
 local tt4 = invttail(df,pv/2)
 
 local pp4 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
	
	
	

	
	xi: reg avt_total_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
		scalar df= e(N)-e(df_m)-1	


boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B11 = _b[afterXtreatment]
				local C11 = _se[afterXtreatment]
local P11 =  r(p)
local N11 = e(N)
*graph save avt_tot_11_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl5= xx[1,1]
 
 local ch5= xx[1,2]
 
 local tt5 = invttail(df,pv/2)
 
 local pp5 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
	
		
	

xi: reg sum_month_stack_adjusted afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
			scalar df= e(N)-e(df_m)-1	


boottest  afterXtreatment, seed(1234)   level(90) boottype(wild) reps(1000) cluster(school_code)

scalar pv= r(p)

if pv==0 {
scalar pv=0.00001
}

*****SE cluster****
di _se[afterXtreatment]

*****SE boot*******
di invttail(df,pv/2)
di abs(_b[afterXtreatment]/invttail(df,pv/2))

				local B12 = _b[afterXtreatment]
				local C12 = _se[afterXtreatment]
local P12 =  r(p)
local N12 = e(N)
*graph save months_11_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl6= xx[1,1]
 
 local ch6= xx[1,2]
 
 local tt6 = invttail(df,pv/2)
 
 local pp6 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
 
 
 
 
 

				di "`B1'"
				post values ("B wages stacked") 		(`B7')	(`C7') 	(`pp1')		(`tt1')		(`P7')	(`cl1')		(`ch1')		(`N7')
				post values ("B work stacked") 			(`B8')	(`C8')	(`pp2')		(`tt2')		(`P8')  (`cl2')		(`ch2')		(`N8')  
				post values ("B pwages stacked") 		(`B9')	(`C9')  (`pp3') 	(`tt3')		(`P9')	(`cl3')		(`ch3')		(`N9')
				post values ("B avt stacked") 			(`B10') (`C10') (`pp4')		(`tt4')		(`P10')	(`cl4')		(`ch4')		(`N10')
				post values ("B avt_tot stacked") 		(`B11') (`C11') (`pp5')		(`tt5')		(`P11')	(`cl5')		(`ch5')		(`N11')   
				post values ("B months stacked") 		(`B12') (`C12') (`pp6')		(`tt6')		(`P12') (`cl6')  	(`ch6')		(`N12')
			

		}
		
		postclose values
		
				use "results\automatic\\all", clear

				outsheet using "results\automatic\\wildboots_1000reps_stacked_`sample'.csv", replace comma

				erase "results\automatic\\all.dta"
		restore
		}
				
			
			
				



	log close
	