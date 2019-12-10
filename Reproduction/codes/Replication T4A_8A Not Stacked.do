/************************************************
Tables 4A and 8A

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


global name Boot

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

	set more off
foreach sample in NE RD{
	postfile values str50 rowKey estimated_effect Clustered_se Boot_se boot_t_statistic boot_pval boot_conf_l boot_conf_h N_obvs using "results/automatic//all", replace		
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

	
	
	
	
	
			
			xi: reg A_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B1 = _b[afterXtreatment]
				local C1 = _se[afterXtreatment]
local P1 =  r(p)
local N1 = e(N)


*graph save A_12_afterSchoolNE9040.jpg


 matrix xx= r(CI)

 local cl17= xx[1,1]
 
 local ch17= xx[1,2]
 
 dis `cl'
 dis `ch'
 
 local tt17 = invttail(df,pv/2)
 
 local pp17 = abs(_b[afterXtreatment]/invttail(df,pv/2))
 
 
					

xi: reg uni_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B2 = _b[afterXtreatment]
				local C2 = _se[afterXtreatment]
local P2 =  r(p)
local N2 = e(N)
*graph save uni_12_afterSchoolNE90.jpg


 matrix xx= r(CI)

 local cl18= xx[1,1]
 
 local ch18= xx[1,2]
 
 local tt18 = invttail(df,pv/2)
 
 local pp18 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	


	
	
	
xi: reg B_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B3 = _b[afterXtreatment]
				local C3 = _se[afterXtreatment]
local P3 =  r(p)
local N3 = e(N)
*graph save B_12_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl19= xx[1,1]
 
 local ch19= xx[1,2]
 
 local tt19 = invttail(df,pv/2)
 
 local pp19 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	

xi: reg col_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B4 = _b[afterXtreatment]
				local C4 = _se[afterXtreatment]
local P4 =  r(p)
local N4 = e(N)
*graph save col_12_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl20= xx[1,1]
 
 local ch20= xx[1,2]
 
 local tt20 = invttail(df,pv/2)
 
 local pp20 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	

	
	
xi: reg E_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B5 = _b[afterXtreatment]
				local C5 = _se[afterXtreatment]
local P5 =  r(p)
local N5 = e(N)
*graph save E_12_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl21= xx[1,1]
 
 local ch21= xx[1,2]
 
 local tt21 = invttail(df,pv/2)
 
 local pp21 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	
	
	
	
xi: reg educ_12_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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

				local B6 = _b[afterXtreatment]
				local C6 = _se[afterXtreatment]
local P6 =  r(p)
local N6 = e(N)
*graph save educ_12_afterSchoolRD90.jpg


 matrix xx= r(CI)

 local cl22= xx[1,1]
 
 local ch22= xx[1,2]
 
 local tt22 = invttail(df,pv/2)
 
 local pp22 = abs(_b[afterXtreatment]/invttail(df,pv/2))
	
 		
********************************************************
***                labor outcomes                **		
*********************************************************		
	
	
	
	
xi: reg sum_wage_11_afterSchoola afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
	


xi: reg work_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
			
			xi: reg pctle_wage_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
 
 
	
	
	

				xi: reg avt_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
	
	
	
	
	xi: reg avt_tot_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
	
		
	

xi: reg months_11_afterSchool afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
 
 
 
 
 
 
 		
********************************************************
***                personal status outcomes                **		
*********************************************************	
 

	
	
	
		xi: reg married afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

				local B13 = _b[afterXtreatment]
				local C13 = _se[afterXtreatment]
local P13 =  r(p)
local N13 = e(N)
*graph save married_RD90.jpg


 matrix xx= r(CI)

 local cl7= xx[1,1]
 
 local ch7= xx[1,2]
 
 local tt7 = invttail(df,pv/2)
 
 local pp7 = abs(_b[afterXtreatment]/invttail(df,pv/2))	
 
 	
xi: reg kids afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

				local B14 = _b[afterXtreatment]
				local C14 = _se[afterXtreatment]
local P14 =  r(p)
local N14 = e(N)
*graph save kids_RD90.jpg


 matrix xx= r(CI)

 local cl8= xx[1,1]
 
 local ch8= xx[1,2]
 
 local tt8 = invttail(df,pv/2)
 
 local pp8 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
	
	
xi: reg yeladim afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

				local B15 = _b[afterXtreatment]
				local C15 = _se[afterXtreatment]
local P15 =  r(p)
local N15 = e(N)
*graph save yeladim_RD90.jpg


 matrix xx= r(CI)

 local cl9= xx[1,1]
 
 local ch9= xx[1,2]
 
 local tt9 = invttail(df,pv/2)
 
 local pp9 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		

		
xi: reg age_at_marriage_y afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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

				local B16 = _b[afterXtreatment]
				local C16 = _se[afterXtreatment]
local P16 =  r(p)
local N16 = e(N)
*graph save age_at_marriage_y_RD90.jpg


 matrix xx= r(CI)

 local cl10= xx[1,1]
 
 local ch10= xx[1,2]
 
 local tt10 = invttail(df,pv/2)
 
 local pp10 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		

		
		
		
		
xi: reg age_at_marriage afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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

				local B17 = _b[afterXtreatment]
				local C17 = _se[afterXtreatment]
local P17 =  r(p)
local N17 = e(N)
*graph save age_at_marriage_RD90.jpg


 matrix xx= r(CI)

 local cl23= xx[1,1]
 
 local ch23= xx[1,2]
 
 local tt23 = invttail(df,pv/2)
 
 local pp23 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		
			
	xi: reg age_at_first_birth_y afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

				local B18 = _b[afterXtreatment]
				local C18 = _se[afterXtreatment]
local P18 =  r(p)
local N18 = e(N)
*graph save age_at_first_birth_y_RD90.jpg


 matrix xx= r(CI)

 local cl24= xx[1,1]
 
 local ch24= xx[1,2]
 
 local tt24 = invttail(df,pv/2)
 
 local pp24 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		

	

	
xi: reg age_at_first_birth afterXtreatment  att_lgcr att_lgsc awr_lgcr e_awr_lgcr asiafr ole boy educav educem m_ahim i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

				local B19 = _b[afterXtreatment]
				local C19 = _se[afterXtreatment]
local P19 =  r(p)
local N19 = e(N)
*graph save age_at_first_birth_RD90.jpg


 matrix xx= r(CI)

 local cl11= xx[1,1]
 
 local ch11= xx[1,2]
 
 local tt11 = invttail(df,pv/2)
 
 local pp11 = abs(_b[afterXtreatment]/invttail(df,pv/2))		
		

				di "`B1'"
				post values ("B A") 			(`B1')	(`C1')	(`pp17')	(`tt17')	(`P1')	(`cl17')	(`ch17')	(`N1')      
				post values ("B uni") 			(`B2')	(`C2')	(`pp18')	(`tt18')	(`P2')	(`cl18')	(`ch18')	(`N2')  
				post values ("B B") 			(`B3')	(`C3')	(`pp19')	(`tt19')	(`P3')	(`cl19')	(`ch19')	(`N3')
				post values ("B col") 			(`B4')	(`C4')	(`pp20')	(`tt20')	(`P4')	(`cl20')	(`ch20')	(`N4')
				post values ("B E") 			(`B5')	(`C5')	(`pp21')	(`tt21')	(`P5')  (`cl21')	(`ch21')	(`N5')  
				post values ("B educ") 			(`B6')	(`C6')	(`pp22')	(`tt22')	(`P6')  (`cl22')	(`ch22')	(`N6')
				post values ("B wages") 		(`B7')	(`C7') 	(`pp1')		(`tt1')		(`P7')	(`cl1')		(`ch1')		(`N7')
				post values ("B work") 			(`B8')	(`C8')	(`pp2')		(`tt2')		(`P8')  (`cl2')		(`ch2')		(`N8')  
				post values ("B pwages") 		(`B9')	(`C9')  (`pp3') 	(`tt3')		(`P9')	(`cl3')		(`ch3')		(`N9')
				post values ("B avt") 			(`B10') (`C10') (`pp4')		(`tt4')		(`P10')	(`cl4')		(`ch4')		(`N10')
				post values ("B avt_tot") 		(`B11') (`C11') (`pp5')		(`tt5')		(`P11')	(`cl5')		(`ch5')		(`N11')   
				post values ("B months") 		(`B12') (`C12') (`pp6')		(`tt6')		(`P12') (`cl6')  	(`ch6')		(`N12')
				post values ("B married") 		(`B13') (`C13') (`pp7')		(`tt7')		(`P13') (`cl7')		(`ch7')		(`N13')
				post values ("B kids") 			(`B14')	(`C14') (`pp8')  	(`tt8')		(`P14') (`cl8')  	(`ch8')		(`N14')
				post values ("B yeladim") 		(`B15') (`C15') (`pp9')		(`tt9')		(`P15') (`cl9')  	(`ch9')		(`N15')
				post values ("B age_at_marriage_y") 			 (`B16')	(`C16')	(`pp10')	(`tt10') 	(`P16')	(`cl10')	(`ch10')	(`N16')
				post values ("B age_at_marriage") 			 (`B17')	(`C17')	(`pp23')	(`tt23')  (`P17')	(`cl23')	(`ch23')	(`N17')
				post values ("B age_first_birth_y") 			 (`B18')	(`C18')	(`pp24')	(`tt24')	(`P18')	(`cl24')	(`ch24')	(`N18')
				post values ("B age_at_first_birth") 			 (`B19')	(`C19')	(`pp11')	(`tt11')	(`P19')	(`cl11')	(`ch11')	(`N19')
				

		}
		
		postclose values
		
				use "results/automatic//all", clear

				outsheet using "results/automatic//wildboots_1000reps_`sample'.csv", replace comma

				erase "results/automatic//all.dta"
		restore
		}
				
			
			
				



	log close
	