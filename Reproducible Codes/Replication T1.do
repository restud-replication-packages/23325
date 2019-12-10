/************************************************
Table 1 - Descriptive Statistics


Description: this files conviniently creates a log from which table 1 can be produced.

			 
*************************************************/

clear all
set mem 500m
set matsize 800
set more off
set logtype text


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

*load data
use data\PublicationDataSet, clear	

*start logging results
log using "logs\\table t1.log", replace

***summary statistics

*~~~~~~~NE SAMPLE~~~~~~~
*(sample is selected for each line using the "if" command)


di "this is the NE sample" 

	bysort treatment:  sum A_12_afterSchool   B_12_afterSchool   uni_12_afterSchool col_12_afterSchool work_11_afterSchoola months_11_afterSchoola sum_wage_11_afterSchoola avt_11_afterSchool avt_tot_11_afterSchool [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 
	bysort treatment:  sum   married kids yeladim age_at_first_birth_years age_at_marriage_years [fweight = hoodWeight] if after == 0 & q4==1 & NE==1
	bysort treatment:  sum   av_avwage00_02 em_avwage00_02 [fweight = hoodWeight] if after == 0 & q4==1 & NE==1

**this counts unweighted observations

di "count # of observations"
	bysort treatment: sum A_12_afterSchool   B_12_afterSchool   uni_12_afterSchool col_12_afterSchool work_11_afterSchoola months_11_afterSchoola sum_wage_11_afterSchoola avt_11_afterSchool avt_tot_11_afterSchool  if after == 0 & q4==1 & NE==1 
	bysort treatment: sum   married kids yeladim age_at_first_birth_years age_at_marriage_years  if after == 1 & q4==1 & NE==1
	bysort treatment: sum   av_avwage00_02 em_avwage00_02  if after == 0 & q4==1 & NE==1
	
*~~~~~~~RD SAMPLE~~~~~~~
di "this is the RD sample" 
	bysort treatment:  sum A_12_afterSchool   B_12_afterSchool   uni_12_afterSchool col_12_afterSchool work_11_afterSchoola months_11_afterSchoola sum_wage_11_afterSchoola avt_11_afterSchool avt_tot_11_afterSchool [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 
	bysort treatment:  sum   married kids yeladim age_at_marriage_years age_at_first_birth_years  [fweight = hoodWeight] if after == 0 & q4==1 & RD	==1
	bysort treatment:  sum   av_avwage00_02 em_avwage00_02 [fweight = hoodWeight] if after == 0 & q4==1 & RD==1

di "count # of observations"
	bysort treatment: sum A_12_afterSchool   B_12_afterSchool   uni_12_afterSchool col_12_afterSchool work_11_afterSchoola months_11_afterSchoola sum_wage_11_afterSchoola avt_11_afterSchool avt_tot_11_afterSchool  if after == 0 & q4==1 & RD==1 
	bysort treatment: sum   married kids yeladim age_at_first_birth_years age_at_marriage_years  if after == 1 & q4==1 & RD==1
	bysort treatment: sum   av_avwage00_02 em_avwage00_02  if after == 0 & q4==1 & RD==1
	
	

*~~~~~~~~Regressions - find out the difference and the s.d. of the difference~~~~~~~
	 
*~~~~~~~NE SAMPLE~~~~~~~
di "this is the NE sample" 

	reg A_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg B_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg uni_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg col_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
 
	reg work_11_afterSchoola treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg months_11_afterSchoola treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg sum_wage_11_afterSchoola treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)

	reg avt_11_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg avt_tot_11_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)

	reg married treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg kids treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg yeladim treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg age_at_marriage_years treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg age_at_first_birth_years treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)

	reg av_avwage00_02 treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
	reg em_avwage00_02 treatment [fweight = hoodWeight] if after == 0 & q4==1 & NE==1 ,vce(cluster school_code)
 
*~~~~~~~RD SAMPLE~~~~~~~

  reg A_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg B_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg uni_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg col_12_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
 
  reg work_11_afterSchoola treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg months_11_afterSchoola treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg sum_wage_11_afterSchoola treatment  [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)

  reg avt_11_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg avt_tot_11_afterSchool treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  
  reg married treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg kids treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg yeladim treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg age_at_marriage_years treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg age_at_first_birth_years treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)

  reg av_avwage00_02 treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
  reg em_avwage00_02 treatment [fweight = hoodWeight] if after == 0 & q4==1 & RD==1 ,vce(cluster school_code)
	 
 
 log close
