/* AJMC Paper response letter to RTI group
Program by Robert Schuldt 
Date: 9/12/2019
*/

libname puf '************';


%macro import(dat, nam, year);
proc import datafile = "&dat"
dbms = XLSX out = &nam replace;
run;

data &nam;
	set  &nam;
		year = &year;

rename Provider_ID = CMS_Certification_Number__CCN_  ;

run;

%mend;
%import(***\puf2014, puf2014, 2014);
%import(***puf2015, puf2015, 2015);
%import(***\puf2016, puf2016, 2016);

libname hhc '*************I';

%import(***\hhc2014, hhc2014, 2014);
%import(***\hhc2015, hhc2015, 2015);
%import(***\hhc2016, hhc2016, 2016);
%import(***\hhc2014, own2014, 2014);
%import(***\hhc2015, own2015, 2015);
%import(***\hhc2016, own2016, 2016);

%Macro comb(a, b, final);
proc sort data = &a;
by CMS_Certification_Number__CCN_;
run;
proc sort data = &b;
by CMS_Certification_Number__CCN_;
run;

data &final;
merge &a (in = a) &b (in = b);
by CMS_Certification_Number__CCN_;
if a;
if b;
run;

%mend;

/*Combine HHC and HCAP survey data, provides ownership*/
%comb(hhc2014, own2014, hhcap2014);
%comb(hhc2015, own2015, hhcap2015);
%comb(hhc2016, own2016, hhcap2016);

/*Combine HHC and Puf files*/
%comb(hhcap2014, puf2014, clean2014);
%comb(hhcap2015, puf2015, clean2015);
%comb(hhcap2016, puf2016, clean2016);

data ajmc_hhc;
set clean2014
clean2015
clean2016
;
run;



