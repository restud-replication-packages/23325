/************************************************
TABLES 2, 4 AND 5 - Uncontrolled regressions

Description: this files creates all the uncontrolled DID results 11 years after graduation for both samples, one by one: includes
post secondary education, labor outcomes, personal outcomes and high school outcomes. (Tables 2, 4, and 5 in the main text).

creates Clustered SE. It is also possible to generate the Wild bootstrap standard errors, but the relevant commands are commented out by default. 
The bootstrap procedure can be easily run through an appendix code named T4A_8A

			 

			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text


*set name for result and log file
global name Replication_DID_T2_4_5_uncontolled


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

use data\PublicationDataSet, clear
	
	

foreach sample in RD NE {  
	preserve
	cap log close

	*DID
	cap postclose values
	*post file is used to store the results and create an excel file with them. Creates a different file for RD and NE samples
	postfile values str50 rowKey B0 num_obs using "results\automatic\\all", replace		
	di "${name}"



	log using "logs\\${name}_`day'`month'`year'`sample'4q.log", replace
	set more off
	
	local i = `i' + 1
	*In earlier iterations we measured results for the bottom three quartiles. This can be done here with the variable q3.					
	foreach group in  q4 {
	
		
			keep if `sample' == 1 & `group' == 1  


		
********************************************************
***  sample : `sample'      group: `group'            **		
********************************************************			
						
			
	
********************************************************
***       post secondary education outcomes           **		
********************************************************		
	
*See controlled version of the code for comments on the estimation commands

	
	
				
		xi: reg A_12_afterSchool afterXtreatment  att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
 					

xi: reg uni_12_afterSchool afterXtreatment   att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
	
xi: reg B_12_afterSchool afterXtreatment    att_lgcr i.year i.school_code   [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
xi: reg col_12_afterSchool afterXtreatment    att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
	
	
xi: reg E_12_afterSchool afterXtreatment  afterXtreatment  att_lgcr i.year i.school_code   [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
	
	
xi: reg educ_12_afterSchool afterXtreatment  att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
	
	
	
xi: reg sum_wage_11_afterSchoola afterXtreatment  att_lgcr i.year i.school_code    [fweight=hoodWeight] , vce( cluster school_code)
					
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
	
	


xi: reg work_11_afterSchool afterXtreatment  att_lgcr i.year i.school_code   [fweight=hoodWeight] , vce( cluster school_code)
					
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

 
	xtile psum_wage_2013a = sum_wage_11_afterSchoola, nquantiles(100) 
			
			xi: reg psum_wage_2013a afterXtreatment  att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)

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
	
	

				xi: reg avt_11_afterSchool afterXtreatment  att_lgcr i.year i.school_code  [fweight=hoodWeight] , vce( cluster school_code)
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
	
	
	xi: reg avt_tot_11_afterSchool afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
	

xi: reg months_11_afterSchool afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
 
 
 
 
 		
********************************************************
***                personal status outcomes                **		
*********************************************************	
 

	
	
	
	
	*married kids yeladim age_at_marriage_y age_at_marriage age_first_birth_y    age_at_first_birth    
	
	


	
	
	
xi: reg married afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
 	
xi: reg kids afterXtreatment  att_lgcr  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
xi: reg yeladim afterXtreatment  att_lgcr  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

		
xi: reg age_at_marriage_y afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
		
		
		
		
xi: reg age_at_marriage afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)
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
			
	xi: reg age_at_first_birth_y afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

	
xi: reg age_at_first_birth afterXtreatment  att_lgcr  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
/*
*wbonus zakaibag units mik_mug madmug

	
xi: reg wbonus afterXtreatment  att_lgcr  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

	
	
xi: reg zakaibag afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
		
		
xi: reg units afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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

 
 
 
 xi: reg mik_mug afterXtreatment  att_lgcr  i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
 
 
 
  xi: reg madmug afterXtreatment  att_lgcr i.year i.school_code [fweight=hoodWeight] , vce( cluster school_code)

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
	*/
	 *for regular DID
	
 local P24 =  0
 local cl16 = 0
 local ch16 = 0
 local tt16 = 0
 local pp16 = 0

			*DID:

				post values ("B A") 			 (`B1') (`N1')  
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C1') (`N1')  
				post values ("B uni") 			 (`B2') (`N2')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C2') (`N2')  
				di "2"
				post values ("B B") 			 (`B3') (`N3')  
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C3') (`N3')  
				post values ("B col") 			 (`B4') (`N4') 
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C4') (`N4')
				di "4"
				post values ("B E") 			(`B5') (`N5')  
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C5') (`N5')  
				
				post values ("B educ") 			 (`B6') (`N6')  
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C6') (`N6')  
				di "6"
				
				
				post values ("B wages") 			 (`B7') (`N7')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C7') (`N7')  
							
				post values ("B work") 			 (`B8') (`N8')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C8') (`N8')  
				di "8"
				post values ("B pwages") 			 (`B9') (`N9') 
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C9') (`N9')  
				post values ("B avt") 			 (`B10') (`N10')
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C10') (`N10')
				di "10"
				post values ("B avt_tot") 			 (`B11') (`N11') 
				post values ("SCHOOL YEAR CLUSTERED SE A_12_afterSchool")   (`C11') (`N11')  
				post values ("B months") 			 (`B12') (`N12')  
				post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C12') (`N12')   
				di "12"		
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
						
				*post values ("B wbonus") 			 (`B20') (`N20') 
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C20') (`N20')  
				
				*di "20"
				*post values ("B zakaibag") 			 (`B21') (`N21') 
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C21') (`N21') 
				*post values ("B units") 			 (`B22') (`N22') 
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C22') (`N22')   
				*di"22"
				*post values ("B mik_mug") 			 (`B23') (`N23')  
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C23') (`N23')   
				*post values ("B mad_mug") 			 (`B24') (`N24') 
				*post values ("SCHOOL YEAR CLUSTERED SE months_12_afterSchool")   (`C24') (`N24')  
				*				di "24"
					*married kids yeladim age_at_marriage_y age_at_marriage age_first_birth_y    age_at_first_birth   
					
		}
			postclose values
			use "results\automatic\\all", clear

			outsheet using "results\automatic\\Table2_4_cont_`sample'_uncontrolled.csv", replace comma

			erase "results\automatic\\all.dta"
			restore
		}
			
			
			
				



	log close
	