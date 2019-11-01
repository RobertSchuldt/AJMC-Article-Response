/* Create the regression models for the AJMC response paper in response 
to the RTI comments on our research on HCC scores and patient experience measures

program: Robert Schuldt
email: rschuldt@Uams.edu
11-1-2019

*******************************************************************************/
clear

cd "*****s\AJMC Response"
use full_set



*Define my time variable*/
xtset Provider_ID Year

foreach var of varlist high_rate recommend professional communicated discussed{
/* WITH VCE ROBUST OPTION*/
xtreg `var' Average_HCC_Score nfp gov percentt_nonwhite tenure ib(2014).Year, /*
*/ fe vce(robust)

}

foreach var of varlist high_rate recommend professional communicated discussed{
/*WITHOUT VCE ROBUST OPTION*/
xtreg `var' Average_HCC_Score nfp gov percentt_nonwhite tenure ib(2014).Year, fe /*
*/
}

gen count = 1

bysort Provider_ID: egen total_count = sum(count)

tab total_count

/* BALANCED DATA SETS REQUIRING AGENCY BE IN ALL THREE YEARS OF DATA*/
foreach var of varlist high_rate recommend professional communicated discussed{

/* WITH VCE ROBUST OPTION*/
xtreg `var' Average_HCC_Score nfp gov percentt_nonwhite tenure ib(2014).Year /*
*/ if total_count == 3, fe vce(robust)

}

foreach var of varlist high_rate recommend professional communicated discussed{
/*WITHOUT VCE ROBUST OPTION*/
xtreg `var' Average_HCC_Score nfp gov percentt_nonwhite tenure ib(2014).Year  /*
*/ if total_count == 3, fe vce(robust)
}