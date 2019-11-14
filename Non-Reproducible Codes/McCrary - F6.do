
		
	*****************************start**********************	
		
	clear all
set mem 400m
set matsize 600
set more off




**** CONFIGURE IF CHANGED!
global name school_means

*cd "V:\teachers_tournament\Revision 07AUG\Teachers Tournament Export (Anonymized)\"
*cd "C:\Users\Tunni\Desktop\victor\teachers bonuses 25.10\new second revision 27.4.18\20060532_data\Teachers Tournament Export (Anonymized)\"
*cd "C:\Users\Tunni\Desktop\victor\from falk - teachers bonuses 04sep17\teachers_tournament\Revision 07AUG\"
cd "C:\Users\peleg\OneDrive\Documents\Victor\Other\Teacher Bonuses\Recreate T3A"


****

set logtype text
cap log close
log using McRary1.6.18.txt, replace
local today="$S_DATE"
local day=word("`today'",1)
local month=word("`today'",2)
local year=substr(word("`today'",3),3,2)
if `day'<10 local day="0`day'"	
		
		use "data\math_base00", clear

	gen year00 = 1
	append using "data\math_base01"
	replace year00 = 0 if year00 == .
	
	gen year01 = 1 - year00

	gen semarab = schtype == "NON JEWISH"
	gen semrel  = schtype == "JEWISH REL."
	
	*gen school_code = semelmos - this was used in the full data sets in which school_code was called semelmos
	// This is the error in the measurement of the rate in 1999
	gen error = tmp_bgrt - zak99
	gen error2= error
	drop error
	gen error = error2>=0
	
	egen inYear00 = max(year00), by(school_code)
	egen inYear01 = max(year01), by(school_code)

	
	
	
	
		collapse semrel semarab tmp_bgrt educav educem m_ahim boy error inYear00 inYear01, by(school_code)
	gen schtype="not jewish sec."
	replace schtype="JEWISH SEC." if semrel!=1 & semarab!=1
	
	/*
	**************************************************
************************ 565 schools
**************************************************
tab tmp_bg,m
		tab tmp_bg if educav==. | educem==. | m_ahim==. | boy==. | error == . ,m 
		tab tmp_bg if ! (inYear00 & inYear01)	,m
	// Drop if not in both schools
	*drop if educav==. | educem==. | m_ahim==. | boy==. | error == .
drop if tmp_bgrt==.
	
		*drop if ! (inYear00 & inYear01)	
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-565.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-565.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-565.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-565.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-565.png)

drop  x y z r b


	**************************************************
************************ 537 schools (without tmp_bgrt==0)
**************************************************
drop if tmp_bgrt==0
tab tmp_bgrt
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(DCdensity_2example42-537.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(DCdensity_2example43-537.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(DCdensity_2example44-537.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(DCdensity_2example45-537.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(DCdensity_2example46-537.png)

drop  x y z r b




	**************************************************
************************ secular 537 schools (without tmp_bgrt==0)
**************************************************
preserve 
keep if schtype=="JEWISH SEC."


tab tmp_bgrt
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(DCdensity_2example42-537s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(DCdensity_2example43-537s.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(DCdensity_2example44-537s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(DCdensity_2example45-537s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(DCdensity_2example46-537s.png)

drop  x y z r b

restore



	**************************************************
************************ religious 537 schools (without tmp_bgrt==0)
**************************************************
preserve 
keep if schtype!="JEWISH SEC."


tab tmp_bgrt
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(DCdensity_2example42-537r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(DCdensity_2example43-537r.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(DCdensity_2example44-537r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(DCdensity_2example45-537r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(DCdensity_2example46-537r.png)

drop  x y z r b

restore
	
*histogram tmp_bgrt, discrete frequency xtitle(Erroneously measured 1999 matriculation rate) xlabel(#25) title("Erroneously measured matriculation rate ") subtitle("entire data set - 507 schools")
	
*histogram tmp_bgrt if schtype=="JEWISH SEC.", discrete frequency xtitle(Erroneously measured 1999 matriculation rate) xlabel(#25) yscale(range(0 20)) ylabel(#6) xline(0.45 ) title("Erroneously measured matriculation rate ") subtitle("schools eligible for the program - Jewish Secular")

*histogram tmp_bgrt if schtype!="JEWISH SEC.", discrete frequency xtitle(Erroneously measured 1999 matriculation rate) xlabel(#25) yscale(range(0 20)) xline( 0.43) ylabel(#6) title("Erroneously measured matriculation rate ") subtitle("schools eligible for the program - Jewish Non Secular and Arab")

*/

**************************************************
************************ 98 eligible
*************************************************

use "C:\Users\peleg\OneDrive\Documents\Victor\Other\Teacher Bonuses\Recreate T3A\data\eng_base00.dta",clear

collapse tmp_bgrt  zak99 zakaibag treated  , by( school_code schtype )

tab tmp_bgrt,m

cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98.png)

drop  x y z r b


cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98.eps) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98.eps)

drop  x y z r b

**************************************************
************************secular 98 schools
*************************************************
dis "religiossssssssssssssssss"
preserve 
keep if schtype=="JEWISH SEC."

tab tmp_bgrt
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98s.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98s.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98s.png)

drop  x y z r b

cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98s.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98s.eps) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98s.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98s.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98s.eps)

drop  x y z r b
restore


**************************************************
************************religious 98 schools
*************************************************
dis "religiossssssssssssssssss"
preserve 
keep if schtype!="JEWISH SEC."

tab tmp_bgrt
cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98r.png) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98r.png)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98r.png)

drop  x y z r b

cap drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.42) generate (x y z r b) graphname(plots\DCdensity_2example42-98r.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.43) generate (x y z r b) graphname(plots\DCdensity_2example43-98r.eps) 
drop  x y z r b
DCdensity tmp_bgrt , breakpoint(0.44) generate (x y z r b) graphname(plots\DCdensity_2example44-98r.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.45) generate (x y z r b) graphname(plots\DCdensity_2example45-98r.eps)
drop  x y z r b

DCdensity tmp_bgrt , breakpoint(0.46) generate (x y z r b) graphname(plots\DCdensity_2example46-98r.eps)

drop  x y z r b



restore




cap log close

