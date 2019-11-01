/* Review the AJMC article response transition from cross sectional study to longit over 2014-2017 in response to RIT comment on 
our article published in AJMC

Robert Schuldt
10-30-19
rschuldt@uams.edu

**********************************************************************************************************************************/
options symbolgen ;
/* Folder for saving files that will be used for analysis*/
libname ajmc '*****************'

/* Accesss the POS files for ownership*/
libname pos '*****************Management\Data\POS';

/*Locate the PUF files for merging*/



%macro import(file, nm, dat, year);

proc import datafile = "***************s\AJMC Response\&file"
dbms = csv out = &nm replace;
run;

data v_&nm;
	set &nm;

 		length CMS_Certification_Number__CCN_  $ 6;
		CMS_Certification_Number__CCN_ = put(Provider_id,z6.);
	run;

data pos;
	set "*****************cy_Management\Data\&dat";
		keep prvdr_num  FIPS_STATE_CD FIPS_CNTY_CD GNRL_CNTL_TYPE_CD CRTFCTN_DT year tenure nfp fp gov CMS_Certification_Number__CCN_;
		rename prvdr_num = CMS_Certification_Number__CCN_;

	year1 = int(CRTFCTN_DT/10000); 
	tenure = &year-year1;
%let own = GNRL_CNTL_TYPE_CD;
	
	if &own = "04" then fp = 1;
		else fp = 0;
	if &own = '01' or &own = "02" or &own = "03" 
		then nfp = 1;
			else nfp = 0;
	gov = 0;
	if fp ne 1 and nfp ne 1 then gov = 1;

	run;

%include '******************t Research Work\SAS Macros\infile macros\sort.sas';

%sort(pos, CMS_Certification_Number__CCN_)
%sort(v_&nm, CMS_Certification_Number__CCN_)

data stack_&year;
merge v_&nm (in = a) pos (in = b);
by CMS_Certification_Number__CCN_;
if a;
run;

%mend;
/*prep data for each year*/
/*2014*/
%import(2014m1.csv, m2014, POS\2014\Data\pos_2014.sas7bdat, 2014);
/*2015*/
%import(2015m1.csv, m2015, POS\2015\Data\pos_2015.sas7bdat, 2015);
/*2016*/
%import(2016m1.csv, m2016, POS\2016\Data\pos_2016.sas7bdat, 2016);


/* I have merged together all the POS and HHC data that I require. Now I need to 
bring in the information from the PUF files to calculate the rest of my variables
that I need for analysis. I will not do these on macro because they can be more 
complicated files*/

/*locate the puf files and import for merging onto the data sets*/
%macro puf(file, stack, year);

proc import file = "****************x\Schuldt Research Work\puffiles\&file"
dbms = xlsx out = &file replace;
run;

%sort(&file, provider_id)
%sort(&stack, provider_id)


data puf_&year;
	merge &file (in = a) &stack (in = b);
	by provider_id;
	if a; 
	run;



%Mend;

%puf(puf2014, stack_2014, 2014)
%puf(puf2015, stack_2015, 2015)
%puf(puf2016, stack_2016, 2016)

/* Created each data set now time to stack the data together*/

data ajmc.repsonse_set;
	set puf_2014
		puf_2015
		puf_2016;


	percentt_nonwhite = ((Distinct_Beneficiaries__non_LUPA- White_Beneficiaries)/Distinct_Beneficiaries__non_LUPA)*100;

	run;

proc means data = ajmc.repsonse_set nmiss;
run;
