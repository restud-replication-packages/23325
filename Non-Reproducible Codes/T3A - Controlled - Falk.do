/***************************************************

Creator:	
			Roy

Date:		
			1 August 2007

file name:	
			diff_in_diffs
			
Description:

			This file runs a diff-in-diffs regression.
			It creates tables 4, 7 and A2.

Input Data:	
			math_base00.dta
			math_base01.dta
			eng_base00.dta
			eng_base01.dta

I know that there can be a much faster way to do this, but this program was based on a simple program
and I didn't want to rewrite it, since it doesn't worth the effort.

******************************************************/

clear all
set mem 400m
set matsize 600
set more off

set logtype text

**** CONFIGURE IF CHANGED!
global name diff_in_diffs
cd "W:\teachers_tournament\Lavy_MS20060532_data_programs_readme\Teachers Tournament Export (Anonymized)\"
****

local today="$S_DATE"
local day=word("`today'",1)
local month=word("`today'",2)
local year=substr(word("`today'",3),3,2)
if `day'<10 local day="0`day'" 

**************************** PROGRAMS ***********************

* This program does all the work.
* It needs the following arguments:
*	sample_cond (for later keep if <sample_cond>)
*	table_name (it will be saved under <table_name>_united)
*	fweightVar (optional) - the prefix of the weight variable in data\school_level_with_weights (hoodWeights probably)
*   useRate (optional)    - specifies whether to use the variable rate (lagged matriculation rate) as a control
*   useSlrate (optional)  - specifies whether to use the variable slrate (lagged matriculation rate) as a control
*  (the difference between the rates is that the second one is from Slava from the Ministry of Education and it's slightly
*   different, and we have it for different years).

capture prog drop DIDTournament
program DIDTournament
	version 9
	
	syntax , sampleCond(string) table_name(string) [fweightVar(string) useRate useSlrate]
	
	foreach subject in eng {
	
	// Once for math and once for english
		// Load bases to memory
		use "data\\math_base00", clear
		
		gen year   = 2000
		gen school_codeYear = school_code
		
		// append 2001
		append using "data\\math_base01"
		
		replace year = 2001 if year == .
		
		replace school_codeYear = school_code * 1000 if year == 2001
		
		sort student_code
		
		// Samples definitions
		egen inNE = anymatch(school_code), values(  3 8 9 11    13 24 27 28 29 30 33 34    41 42 43 46 53 55 56 57 69 70 71 73 74 75    78 79 80 82 86 87       93 94 96 97)
		egen inRD = anymatch(school_code), values(1 3 8 9 11 12       27       30 33    37    42       53    56       70 71 73 74 75 76 78          86 87 88 91    94 96 97)
		gen inEL = 1
		
		*keep if `sampleCond'
		keep if inNE

		drop if rule2 == 1
		
		tempfile eng
		save `eng' , replace
		
		use "data\\eng_base00", clear
		
		gen year   = 2000
		gen school_codeYear = school_code
		
		// append 2001
		append using "data\\eng_base01"
		
		replace year = 2001 if year == .
		
		replace school_codeYear = school_code * 1000 if year == 2001
		
		sort student_code
		
		// Samples definitions
		egen inNE = anymatch(school_code), values(  3 8 9 11    13 24 27 28 29 30 33 34    41 42 43 46 53 55 56 57 69 70 71 73 74 75    78 79 80 82 86 87       93 94 96 97)
		egen inRD = anymatch(school_code), values(1 3 8 9 11 12       27       30 33    37    42       53    56       70 71 73 74 75 76 78          86 87 88 91    94 96 97)
		gen inEL = 1
		
		*keep if `sampleCond'
		keep if inNE
		
		drop if rule2 == 1
		
		merge student_code using `eng'
		drop _merge

		// If weighting was asked, merge the weights file (schools level) into the raw file (students level)
		if ("`fweightVar'" != "") {
			di "Weights were asked for (fweight = `fweightVar') - merging 2001 weights for subject `subject'"

			sort school_code
			merge school_code using "data\school_level_with_weights.dta", keep (`fweightVar'_00_`subject') uniqusing nokeep
			drop _merge
			
			rename `fweightVar'_00_`subject' `fweightVar'
			
			di "Weights were asked for (fweight = `fweightVar') - merging 2000 weights for subject `subject'"
			
			sort school_code
			merge school_code using "data\school_level_with_weights.dta", keep (`fweightVar'_01_`subject') uniqusing nokeep
			drop _merge

			replace `fweightVar' = `fweightVar'_01_`subject' if year == 2001
			drop `fweightVar'_01_`subject'
		}
		
		// I will create the list of lagged-matriculation-rate control variables according to the 
		// arguments entered when the program was called
		local laggedScoreControl ""
		
		// Check which lagged-matriculation rate to take
		if ("`useRate'" != "") {
			sort school_code
			merge school_code using "data\rate98_collapsed", keep (rate98) nokeep
			drop _merge
			sort school_code
			merge school_code using "data\rate99_collapsed", keep (rate99) nokeep
			drop _merge
			gen rate = rate98
			replace rate = rate99 if year == 2001
			local laggedScoreControl "rate"
		}
		
		if ("`useSlrate'" != "") {
			gen slrate = slrate99
			replace slrate = slrate00 if year == 2001
			local laggedScoreControl "`laggedScoreControl' slrate"
		}
		
		di " "
		di "lagged bagrut rate controls asked for are `laggedScoreControl'"
				
		local subjectLetter = substr("`subject'", 1, 1)
	
		// Change the "treated" variable to be, actually, treated*after (by setting treated=0 for those who are "before"
		// that is, 2000)
		gen treat1=treated
		replace treated = 0 if year == 2000

		// Find quartiles of lagged students' performance for each cohort, and assign the quartile to the student.
		forvalues q = 1/4 {
			gen q`q' = 0
		}
		
		foreach year in 2000 2001 { 
		    //*** quartiling algorithm that conforms with the SAS algorithm (in terms of which values to include
		    //    when there are many observations with the same value on the margin between the quartiles)
		    
		    // If weighting was asked, determine quartiles with weights
			if ("`fweightVar'" != "") {
				sum att_lgsc if year == `year' [fweight=`fweightVar'], detail
			}
			else {
				sum att_lgsc if year == `year', detail
			}
			// Assign quartiles (as dummies)
		    replace q1 = 1 if 				  att_lgsc < r(p25) & att_lgsc != . & year == `year'
		    replace q2 = 1 if q1 == 0	 	& att_lgsc < r(p50) & att_lgsc != . & year == `year'
		    replace q3 = 1 if q1+q2 == 0 	& att_lgsc < r(p75) & att_lgsc != . & year == `year'
		    replace q4 = 1 if q1+q2+q3 == 0 					& att_lgsc != . & year == `year'
		}
		// Create also one variable that holds the quartile number
		gen q = q1 + 2 * q2 + 3 * q3 + 4 * q4
	
		// Create interaction of the quartile and the treatment status (treatment*after status)
		// It was used in previous versions (before each quartile was run separately in the quartiles regressions)
		forvalues q = 1/4 {
			gen t`q' = (q`q' == 1 & treated == 1)
		}
	
		// Define the output table's variables
		postfile `table_name'_`subject' str10 panel str100 rowKey `subject'_all_simple `subject'_all gap_`subject' `subject'_q1 `subject'_q2 `subject'_q3 `subject'_q4 gap using "results\automatic\\`table_name'_`subject'", replace
	
		//***** Run regressions
		
		//* I'm doing it just because xtreg fe doesn't work with fweights (Stata 9)
		xi i.year i.org_m_ahim i.org_educav i.org_educem i.school_code
		
		local regCommand = "reg"
		local _I_controls_for_simple = "_Iyear* _Isch* "

		if ("`fweightVar'" != "") {
			local fweightStr = "[fweight=`fweightVar']"
		}
		
		else {
			local fweightStr = ""
		}
		rename zakaibag z
		rename mik_mug mkmg
		// Run the regressions for three outcomes: testing rate, pass rate and external score
		foreach dependent in z wbonus  mkmg units{
			// All quartiles - first, simple DID regression (no controls)
			di " "
			di "------------------------------------------------------------------------------"
			di "running regression for subject `subject' for all quartiles WITHOUT CONTROLS"
			// 		First time, clustered at the school level
			di "`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_code)"
			`regCommand' `dependent' treated treat1 att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_code)
			outreg2 using secondary_teach.xls, replace
			local all_ltd_`dependent'_b               = _b[treated]	
			local all_ltd_`dependent'_se_clst_school  = _se[treated]
			
			// 		Second time, clustered at the school*year level (just for the standard errors)
			di "`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_codeYear)"
			`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_codeYear)
			
			local all_ltd_`dependent'_se_clst_schYear = _se[treated]
			
			/*
			// 		Third time, robust
			di "`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  robust"
			`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  robust
			local all_ltd_`dependent'_se_robust = _se[treated]
			*/
			di "------------------------------------------------------------------------------"
			
			
			// All quartiles - DID regression (with controls)
			di " "
			di "------------------------------------------------------------------------------"
			di "running regression for subject `subject' for all quartiles"
			// 		First time, clustered at the school level
			di "`regCommand' `dependent' treated `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr',  cluster(school_code)"
			`regCommand' `dependent' treated `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr',  cluster(school_code)
			outreg2 using secondary_teach.xls, append
			local all_`dependent'_b              = _b[treated]
			local all_`dependent'_se_clst_school = _se[treated]
			
			// 		Second time, clustered at the school*year level (just for the standard errors)
			di "`regCommand' `dependent' treated `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr',  cluster(school_codeYear)"
			`regCommand' `dependent' treated `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr',  cluster(school_codeYear)
			
			local all_`dependent'_se_clst_schYear = _se[treated]
			
			di "------------------------------------------------------------------------------"
				//Cross Section (without controls)
			
			local _I_controls_for_simple = "_Iyear* "
		di "running regression for subject `subject' for all quartiles WITHOUT CONTROLS"
			// 		First time, clustered at the school level
			di "`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_code)"
			`regCommand' `dependent' treat1 att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr' if year==2000,  cluster(school_code)
			outreg2 using secondary_teach.xls, append
			local all_ltd_`dependent'_00b               = _b[treat1]	
			local all_ltd_`dependent'_00se_clst_school  = _se[treat1]
			
			di "`regCommand' `dependent' treated att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr',  cluster(school_code)"
			`regCommand' `dependent' treat1 att_lgcr `laggedScoreControl' `_I_controls_for_simple' `fweightStr' if year==2001,  cluster(school_code)
			outreg2 using secondary_teach.xls, append
			local all_ltd_`dependent'_01b               = _b[treat1]	
			local all_ltd_`dependent'_01se_clst_school  = _se[treat1]
				
				//Cross Section (with controls)
			di " "
			di "------------------------------------------------------------------------------"
			di "running regression for subject `subject' for all quartiles"
			// 		First time, clustered at the school level
			di "`regCommand' `dependent' treated `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr',  cluster(school_code)"
			`regCommand' `dependent' treat1 `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr' if year==2000,  cluster(school_code)
			outreg2 using secondary_teach.xls, append
			local all_`dependent'_b00              = _b[treat1]
			local all_`dependent'_se00_clst_school = _se[treat1]
			
				`regCommand' `dependent' treat1 `laggedScoreControl' att_lgsc att_lgcr awr_lgcr `subjectLetter'_awr_lgcr asiafr ole boy _I* `fweightStr' if year==2001,  cluster(school_code)
				outreg2 using secondary_teach.xls, append
			local all_`dependent'_b01              = _b[treat1]
			local all_`dependent'_se01_clst_school = _se[treat1]
		
	di "------------------------------------------------------------------------------"
			
			di "Mean `dependent' for the control group"
			
			// Save the mean outcome for the control group in 2001
			sum `dependent' `fweightStr' if treated == 0 & year == 2001
			local cmean_all_`dependent' = r(mean)
	
			// Count observations
			sum treated
			local n_all = r(N)
			if ("`fweightVar'" != "") {
				sum treated `fweightStr'
				local n_all_w = r(N)
			}
	
			// Now the full controls specification (the previous one), but by quartiles
			di " "
			di "------------------------------------------------------------------------------"
			di "running regression for subject `subject' for each quartile separately"
			
			// Post all the locals that were saved from all the regressions according to the table's format
			post `table_name'_`subject' ("A" ) ("`dependent'")				 								(.)										(.)									(.) (.)									(.)									(.)									(.)									(.)
			post `table_name'_`subject' ("A" ) ("`dependent' control mean")  								(`cmean_all_`dependent'')				(.)									(.) (.)									(.)									(.)									(.)									(.)
			post `table_name'_`subject' ("A" ) ("`dependent' treat. effect")								(`all_ltd_`dependent'_b')  				(`all_`dependent'_b') 				(.) (`all_ltd_`dependent'_00b')			(`all_ltd_`dependent'_01b')			(`all_`dependent'_b00')				(`all_`dependent'_b01')				(.)
			di "0"
			post `table_name'_`subject' ("A" ) ("`dependent' treat. ef. SE clustered at school-year level")	(`all_ltd_`dependent'_se_clst_schYear')	(`all_`dependent'_se_clst_schYear')	(.) (.)	(.)	(.)	(.)	(.)
					di "1"
			post `table_name'_`subject' ("A" ) ("`dependent' treat. ef. SE clustered at school level")		(`all_ltd_`dependent'_se_clst_school')	(`all_`dependent'_se_clst_school')	(.) (.)	(.)	(.)	(.)	(.)
		
		
		/*	post `table_name'_`subject' ("A" ) ("`dependent' treat. ef. SE clustered at school-year level")	(`all_ltd_`dependent'_se_clst_schYear')	(`all_`dependent'_se_clst_schYear')	(.) (`t1_`dependent'_se_clst_schYear')	(`t2_`dependent'_se_clst_schYear')	(`t3_`dependent'_se_clst_schYear')	(`t4_`dependent'_se_clst_schYear')	(.)
					di "1"
			post `table_name'_`subject' ("A" ) ("`dependent' treat. ef. SE clustered at school level")		(`all_ltd_`dependent'_se_clst_school')	(`all_`dependent'_se_clst_school')	(.) (`t1_`dependent'_se_clst_school')	(`t2_`dependent'_se_clst_school')	(`t3_`dependent'_se_clst_school')	(`t4_`dependent'_se_clst_school')	(.)
			post `table_name'_`subject' ("A" ) ("`dependent' treat. ef. SE robust")							(`all_ltd_`dependent'_se_robust')		(`all_`dependent'_se_robust')		(.) (`t1_`dependent'_se_robust')		(`t2_`dependent'_se_robust')		(`t3_`dependent'_se_robust')		(`t4_`dependent'_se_robust')		(.) */
	

		}
		
		// Posting #obs
		post `table_name'_`subject' ("B") ("N") 	(`n_all') 	(.) (.) (.) 	(.) 	(.) 	(.)	(.)
*		post `table_name'_`subject' ("B") ("N") 	(`n_all') 	(.) (.) (`n_t1') 	(`n_t2') 	(`n_t3') 	(`n_t4')	(.)
		if ("`fweightVar'" != "") {

		post `table_name'_`subject' ("B") ("N_weighted") 	(`n_all_w') 	(.) (.) (.) 	(.) 	(.) 	(.)	(.)
		*post `table_name'_`subject' ("B") ("N_weighted") 	(`n_all_w') 	(.) (.) (`n_t1_w') 	(`n_t2_w') 	(`n_t3_w') 	(`n_t4_w')	(.)
		}
	
		postclose `table_name'_`subject' 
	
}

	// Now, after we prepared the same tables for math and for English, it is time to merge them into one big table.
	// **** Join math and eng results
	// First, opening math results file
	use "results\automatic\\`table_name'_eng", clear
	
	// Saving the united file
	save "results\automatic\\`table_name'_united", replace
end
**************************** END OF PROGRAMS ***********************

cap log close
log using "logs\l_${name}_`year'`month'`day'.log", replace


/************* TABLE 4 - DID for the RT (NE) sample **************/

DIDTournament , sampleCond(inNE) table_name(table4_NE) fweightVar(hoodWeight) useRate useSlrate
		

foreach tableNum in 4_NE 7_RD A2_DID_all {
	use "results\automatic\table`tableNum'_united", clear
	outsheet using "results\automatic\table`tableNum'_united.csv", comma replace
}

log close
