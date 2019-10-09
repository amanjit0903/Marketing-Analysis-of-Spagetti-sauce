libname sp 'C:\Users\sxs171332\Desktop\SAS Project';

data sp.groc_store;
infile 'C:\Users\sxs171332\Desktop\SAS Project/spagsauc_groc_1114_1165' dlm=' ' firstobs=2;
input IRI_KEY WEEK SY GE VEND ITEM UNITS DOLLARS F $ D PR;
UPC=catx('-', put(SY,Z2.),put(GE,Z2.),put(VEND,Z5.),put(ITEM,Z5.));
format DOLLARS dollar8.2;
run;


/*Delivery Dataset  */
data sp.delvstores;
infile 'C:\Users\sxs171332\Desktop\SAS Project/Delivery_Stores' dlm=' ' firstobs=2;
input IRI_KEY OU$ EST_ACV MARKET_NAME$ 20. OPEN CLOSE MSKDNAME$;
run;


PROC IMPORT DATAFILE='C:\Users\sxs171332\Desktop\SAS Project/prod_sauce.xls'
	DBMS=XLS replace
	OUT=sp.product;
	GETNAMES=YES;
RUN;


data sp.groc_store;
set sp.groc_store;
SY_id = put(SY,7.); drop SY; rename SY_id = SY;
GE_id = put(GE,7.); drop GE; rename GE_id = GE;
VEND_id = put(VEND,7.); drop VEND; rename VEND_id = VEND;
ITEM_id = put(ITEM,7.); drop ITEM; rename ITEM_id = ITEM;
run;

/*Merge dataset using UPC Code*/
Proc Sort data = sp.groc_store ;
by UPC;
run;
Proc Sort data = sp.product;
by UPC;
Run;

data sp.Grocery_info;  
   merge sp.groc_store sp.product;
   by UPC;
run;


data sp.grocery_info;
set sp.grocery_info;
where iri_key ne .;
drop SY GE VEND _STUBSPEC_1575RC;
run;


   data sp.grocery_info;
   set sp.grocery_info;
   if BRAND = 'CLASSICO' then market_share = 0.102;
   if BRAND = 'FIVE BROTHERS' then market_share = 0.052;
   if BRAND = 'HUNTS' then market_share = 0.145;
   if BRAND = 'PREGO' then market_share = 0.289;
   if BRAND = 'RAGU' then market_share = 0.412; 
   run;

data sp.grocery_info;
Length BRAND $ 15.; 
set sp.grocery_info;
if L5='ALL RAGU PRODUCTS' OR
L5='RAGU' OR
L5='RAGU CARB OPTIONS' OR
L5='RAGU CHEESE CREATIONS' OR
L5='RAGU CHICKEN TONIGHT' OR
L5='RAGU CHUNKY GARDEN STYLE' OR
L5='RAGU FINO ITALIAN' OR
L5='RAGU HEARTY' OR
L5='RAGU LIGHT' OR
L5='RAGU OLD WORLD STYLE' OR
L5='RAGU RICH & MEATY' OR
L5='RAGU ROBUSTO' OR
L5='RAGU THICK & HEARTY' OR
L5='RAGU TODAYS RECIPE' THEN BRAND='RAGU';
else if
L5='HUNTS' OR
L5='HUNTS ANGELA MIA' OR
L5='HUNTS LIGHT' OR
L5='HUNTS OLD COUNTRY' OR
L5='HUNTS SUMMER SELECT' THEN BRAND='HUNTS';
else if

L5='PREGO'  OR 
L5='PREGO CHUNKY GARDEN' OR 
L5='PREGO PRIMORE' OR  
L5='PREGO HEARTY MEAT' OR
L5='PREGO EXTRA CHUNKY' THEN BRAND='PREGO';

ELSE IF 
L5='HEALTHY CHOICE' OR 
L5='HEALTHY CHOIC MEDITERRANN HAR' OR
L5='HEALTHY CHOICE GARLIC LOVERS' THEN BRAND='HEALTHY CHOICE';

ELSE IF 
L5='FRANCESCO RINALDI' THEN BRAND='FRANCESCO';
else if
L5='AUNT MILLIES' then BRAND='AUNT MILLIES';
ELSE IF
L5='CLASSICO' OR
L5='CLASSICO CREATIONS' OR
L5='CLASSICO HEARTY' THEN BRAND='CLASSICO';
else if 
L5='DEL MONTE' OR
L5='DEL MONTE D ITALIA' THEN BRAND='DEL MONTE';
else if
L5='RIENZI' then BRAND='RIENZI';
else if 
L5='FIVE BROTHERS' then BRAND='FIVE BROTHERS';
else if
L5='BARILLA' then BRAND='BARILLA';
else if L5='PRIVATE LABEL' THEN BRAND='PRIVATE LABEL';
ELSE BRAND='OTHERS';
RUN;

data sp.Grocery_info;
set sp.Grocery_info;
price_per_unit=dollars/(units*vol_eq);
run;

data sp.Grocery_info;
set sp.Grocery_info;
total_sales=units*vol_eq;
run;

data sp.PREGO;
set sp.grocery_info;
where BRAND='PREGO';
run;

data sp.PREGO;
set sp.PREGO;
IF D=0 THEN D_NO=1; ELSE D_NO=0;
IF D=1 THEN D_MINOR=1; ELSE D_MINOR=0;
IF D=2 THEN D_MAJOR=1; ELSE D_MAJOR=0;
drop D_NO;
RUN;

data sp.PREGO;
set sp.PREGO;
IF F='NONE' THEN F_NO=1; ELSE F_NO=0;
IF F='A+' THEN F_RCR=1; ELSE F_RCR=0;
IF F ='A' THEN F_LSA=1; ELSE F_LSA=0; 
IF F='B' THEN F_MSA=1; ELSE F_MSA=0;
IF F='C' THEN F_SSA=1 ;ELSE F_SSA=0;
RUN;

/*Data set RAGU */

data sp.RAGU;
set sp.grocery_info (rename=(price_per_unit=price_per_unit_RAGU D=D_RAGU F=F_RAGU PR=PR_RAGU market_share=market_share_RAGU));
where BRAND='RAGU';
run;

data sp.RAGU;
set sp.RAGU;
keep IRI_KEY WEEK price_per_unit_RAGU D_RAGU F_RAGU PR_RAGU market_share_RAGU;
run; 

data sp.RAGU;
set sp.RAGU;
/*IF D_RAGU=0 THEN D_NO=1; ELSE D_NO=0;*/
IF D_RAGU=1 THEN D_RAGUMINOR=1; ELSE D_RAGUMINOR=0;
IF D=2 THEN D_MAJOR=1; ELSE D_MAJOR=0;
drop D_NO;
RUN;

data sp.RAGU;
set sp.RAGU;
IF F='NONE' THEN F_NO=0; ELSE F_NO=1;
/*IF F='A+' THEN F_RCR=1; ELSE F_RCR=0;*/
/*IF F ='A' THEN F_LSA=1; ELSE F_LSA=0; */
/*IF F='B' THEN F_MSA=1; ELSE F_MSA=0;*/
/*IF F='C' THEN F_SSA=1 ;ELSE F_SSA=0;*/
RUN;

proc sort data= sp.RAGU;
by IRI_KEY WEEK;
run;

proc sort data=sp.PREGO;
by IRI_KEY WEEK;
run;

data sp.PREGO_RAGU;
merge sp.PREGO sp.RAGU;
by IRI_KEY WEEK;
run;
data sp.PREGO_RAGU;
   set sp.PREGO_RAGU;
   weighted_D_MINOR = D_MINOR*Market_share;
   weighted_D_MAJOR = D_MAJOR*Market_share;
   weighted_F_RCR = F_RCR*Market_share;
   weighted_F_LSA = F_LSA*Market_share;
   weighted_F_MSA = F_MSA*Market_share;
   weighted_F_SSA = F_SSA*Market_share;
   Weighted_PR=PR*Market_share;
   weighted_price = price_per_unit * Market_share;
   weighted_price_RAGU = price_per_unit_RAGU * market_share_RAGU;
  run;

data sp.PREGO;
set sp.PREGO;
lnsales=log(total_sales);
drop L1 L2 L3 L4 L9 ITEM FLAVOR_SCENT HEAT_LEVEL TYPE_OF_ITALIAN_SCE ADDITIVES LEVEL STYLE PRODUCT_TYPE ;
run;


/*Based on the output droping the F_RCR and F_SSA*/

/*creating interactiopn terms*/
data sp.PREGO_RAGU;
set sp.PREGO_RAGU;
intr0 = weighted_price*weighted_price;
intr1=  weighted_D_MINOR*weighted_F_LSA;
intr2=  weighted_D_MINOR*weighted_F_MSA;
/*intr3=  weighted_avg_D_MINOR*weighted_avg_price;*/
intr4=  weighted_D_MAJOR*weighted_F_LSA;
intr5=  weighted_D_MAJOR*weighted_F_MSA;
/*intr6=  weighted_avg_D_MAJOR*weighted_price;*/
/*intr7=  weighted_F_LSA*weighted_price;*/
/*intr8=  weighted_F_MSA*weighted_price;*/
intr9 = Weighted_PR*weighted_F_LSA;
intr10 = Weighted_PR*weighted_F_MSA;
intr11 = Weighted_PR*weighted_D_MINOR;
intr12 = Weighted_PR*weighted_D_MAJOR;
/*intr13 = Weighted_PR*weighted_avg_price;*/
run; 

proc reg data=sp.PREGO_RAGU;
  Model lnsales= weighted_price weighted_D_MINOR  weighted_D_MAJOR weighted_F_RCR weighted_F_LSA weighted_F_MSA weighted_F_SSA Weighted_PR 
     weighted_price_RAGU / stb vif collin;
	 run;

proc reg data=sp.PREGO_RAGU;
  Model lnsales= weighted_price weighted_D_MINOR  weighted_D_MAJOR weighted_F_RCR weighted_F_LSA weighted_F_MSA weighted_F_SSA Weighted_PR 
     weighted_price_RAGU intr0 intr1 intr2 intr4 intr5 intr9 intr10 intr11 intr12 / stb vif collin;
	test intr0;
	test intr1, intr2;
	test intr4,intr5;
	test intr9,intr10,intr11,intr12;
  run;




Data Sp.PREGO_PCA;
set sp.PREGO;
IF F='NONE' THEN ADS=0; ELSE ADS=1;
IF D=0 THEN DISP=0; ELSE DISP=1;
keep IRI_KEY DISP ADS PR total_sales price_per_unit;
run;


 proc corr data=sp.PREGO_PCA; 
 run;
 
 proc princomp data=sp.PREGO_PCA;
 run;


 proc means data= sp.PREGO_RAGU;
 var weighted_price;
 run;
 
 
 
 /*Panel Data Analysis*/


/*Merging the Panel data to one file*/

PROC SQL;
CREATE TABLE sp.Panel_Combined AS 
SELECT * from sp.PANEL_DR
UNION ALL
select * FROM sp.PANEL_GR
UNION ALL
select * from sp.PANEL_MA;
Quit;

/*Creating the Customer table with Quantity purchased and Dollar spent from panel_combined table
to understand the customer behaviour.  will be useful for survival analysis*/

PROC SQL ;
CREATE TABLE sp.Customer_Demo AS
SELECT * FROM sp.demo d 
LEFT JOIN (select distinct SUM(UNITS) as TOTAL_UNITS,sum(DOLLARS) as DOLLARS,PANID from sp.Panel_Combined GROUP BY PANID) sub 
on (d.PANID=sub.PANID)
GROUP BY d.PANID;
QUIT;


/*Clubbing all the Brands which share same name, taking top brands and renaming to Others*/

data sp.product;
Length BRAND $ 15.; 
set sp.product;
if L5='ALL RAGU PRODUCTS' OR
L5='RAGU' OR
L5='RAGU CARB OPTIONS' OR
L5='RAGU CHEESE CREATIONS' OR
L5='RAGU CHICKEN TONIGHT' OR
L5='RAGU CHUNKY GARDEN STYLE' OR
L5='RAGU FINO ITALIAN' OR
L5='RAGU HEARTY' OR
L5='RAGU LIGHT' OR
L5='RAGU OLD WORLD STYLE' OR
L5='RAGU RICH & MEATY' OR
L5='RAGU ROBUSTO' OR
L5='RAGU THICK & HEARTY' OR
L5='RAGU TODAYS RECIPE' THEN BRAND='RAGU';
else if
L5='HUNTS' OR
L5='HUNTS ANGELA MIA' OR
L5='HUNTS LIGHT' OR
L5='HUNTS OLD COUNTRY' OR
L5='HUNTS SUMMER SELECT' THEN BRAND='HUNTS';
else if

L5='PREGO'  OR 
L5='PREGO CHUNKY GARDEN' OR 
L5='PREGO PRIMORE' OR  
L5='PREGO HEARTY MEAT' OR
L5='PREGO EXTRA CHUNKY' THEN BRAND='PREGO';

ELSE IF 
L5='HEALTHY CHOICE' OR 
L5='HEALTHY CHOIC MEDITERRANN HAR' OR
L5='HEALTHY CHOICE GARLIC LOVERS' THEN BRAND='HEALTHY CHOICE';

ELSE IF 
L5='FRANCESCO RINALDI' THEN BRAND='FRANCESCO';
else if
L5='AUNT MILLIES' then BRAND='AUNT MILLIES';
ELSE IF
L5='CLASSICO' OR
L5='CLASSICO CREATIONS' OR
L5='CLASSICO HEARTY' THEN BRAND='CLASSICO';
else if 
L5='DEL MONTE' OR
L5='DEL MONTE D ITALIA' THEN BRAND='DEL MONTE';
else if
L5='RIENZI' then BRAND='RIENZI';
else if 
L5='FIVE BROTHERS' then BRAND='FIVE BROTHERS';
else if
L5='BARILLA' then BRAND='BARILLA';
else if L5='PRIVATE LABEL' THEN BRAND='PRIVATE LABEL';
ELSE BRAND='OTHERS';
RUN;


Data sp.Prod_TS;
set sp.product;
if BRAND ne 'OTHERS';
run;


/*Dropping unwanted columns from Product table*/

data sp.product;
set sp.product;
drop L1 L2 L4 L9 Level _STUBSPEC_1575RC PRODUCT_TYPE ADDITIVES;
run;

/*Creating a seperate product table with only three brands so that will be useful for Panel, RFM and Loyalty analysis*/

data sp.product_top3brand;
set sp.product;
if BRAND in('RAGU' 'PREGO' 'FRANCESCO');
run;

/*Sales Analysis based on Time in Panel Data*/

/*Checking for Top brands based on Dollar sales per year*/

PROC SQL outobs = 3;
select BRAND,sum(Dollars) as Sum from TimeSeries
Group by Brand
order by Sum desc;
quit;


/*Retaining only top 3 brands for simplicity of analysis*/
PROC SQL;
Create Table sp.TimeAnalysis AS 
Select Week, Outlet, Sum(Units) as Units, Sum(DOLLARS) as Dollars, p.BRAND
from sp.panel_combined pc
inner join sp.prod_TS p
on pc.colupc = p.colupc
where BRAND in ('RAGU', 'PREGO', 'FRANCESCO')
Group BY WEEK, p.BRAND, OUTLET
order by BRAND, WEEK;
QUIT;

/*Total Unit Sales analysis of Panel Data based on Store*/
ods graphics on / width=12in height=8in;
title 'Weekly Sales of GR';
proc sgplot data=sp.TimeAnalysis (WHERE=(OUTLET='GR')) noborder;
  vbar WEEK / response=UNITs
         group=BRAND groupdisplay=cluster
         dataskin=pressed 
         baselineattrs=(thickness=2)
		 filltype=gradient;
		 xaxis display=(nolabel noline noticks) 
         fitpolicy=rotate 
         valuesrotate=vertical;
  yaxis display=(noline) grid;
run;

ods graphics on / width=12in height=8in;
title 'Weekly Sales of DR';
proc sgplot data=sp.TimeAnalysis (WHERE=(OUTLET='DR')) noborder;
  vbar WEEK / response=UNITs
         group=BRAND groupdisplay=cluster
         dataskin=pressed 
         baselineattrs=(thickness=2)
		 filltype=gradient;
		 xaxis display=(nolabel noline noticks) 
         fitpolicy=rotate 
         valuesrotate=vertical;
  yaxis display=(noline) grid;
run;

ods graphics on / width=12in height=8in;
title 'Weekly Sales of MA';
proc sgplot data=sp.TimeAnalysis (WHERE=(OUTLET='MA')) noborder;
  vbar WEEK / response=UNITs
         group=BRAND groupdisplay=cluster
         dataskin=pressed 
         baselineattrs=(thickness=2)
		 filltype=gradient;
		 xaxis display=(nolabel noline noticks) 
         fitpolicy=rotate 
         valuesrotate=vertical;
  yaxis display=(noline) grid;
run;

/*Adding demographies to Existing dataset*/

proc sql;
select * from sp.demo;
quit;

/*Removing unwanted demographies based on economic theory and more no of missing columns*/

Data sp.demo_panel;
set sp.demo;
drop HISP_CAT HISP_FLAG ZIPCODE FIPSCODE IRI_Geography_Number market_based_upon_zipcode SY GE VEND EXT_FACT HH_Head_Race__RACE2_ MALE_SMOKE Language Year County FEM_SMOKE HH_RACE ;
run;

proc contents data = sp.demo_panel;
run;

data sp.demo_panel;
set sp.demo_panel;

proc sql;
create table Panel_combined1 as 
select * from sp.Panel_combined p
inner join sp.product_top3brand pt
on p.colupc = pt.colupc;
quit;

data Panel_combined1;
set Panel_combined1;
drop L5;
run;

data Panel_combined1;
set panel_combined1;
if BRAND = 'RAGU' then RAGU = 1; else RAGU = 0;
if BRAND = 'PREGO' then PREGO = 1; else PREGO = 0;
if BRAND = 'FRANCESCO' then FRANCESCO = 1; else FRANCESCO = 0;
run;


proc sql;
	create table sp.combined as 
	select * from Panel_combined1 p
	inner join sp.demo_panel d 
	on d.PANID = p.PANID;
quit;


proc sql;
 select count(*) from sp.combined;
 quit;


data sp.combined;
set sp.combined;
if Combined_Pre_Tax_Income_of_HH=0 then inc0=1;else inc0=0;
if Combined_Pre_Tax_Income_of_HH=1 then inc1=1;else inc1=0;
if Combined_Pre_Tax_Income_of_HH=2 then inc2=1;else inc2=0;
if Combined_Pre_Tax_Income_of_HH=3 then inc3=1;else inc3=0;
if Combined_Pre_Tax_Income_of_HH=4 then inc4=1;else inc4=0;
if Combined_Pre_Tax_Income_of_HH=5 then inc5=1;else inc5=0;
if Combined_Pre_Tax_Income_of_HH=6 then inc6=1;else inc6=0;
if Combined_Pre_Tax_Income_of_HH=7 then inc7=1;else inc7=0;
if Combined_Pre_Tax_Income_of_HH=8 then inc8=1;else inc8=0;
if Combined_Pre_Tax_Income_of_HH=9 then inc9=1;else inc9=0;
if Combined_Pre_Tax_Income_of_HH=10 then inc10=1;else inc10=0;
if Combined_Pre_Tax_Income_of_HH=11 then inc11=1;else inc11=0;
if Combined_Pre_Tax_Income_of_HH=12 then inc12=1;else inc12=0;
run;


data sp.combined;
set sp.combined;
if Family_Size=0 then FS0=1;else FS0=0;
if Family_Size=1 then FS1=1;else FS1=0;
if Family_Size=2 then FS2=1;else FS2=0;
if Family_Size=3 then FS3=1;else FS3=0;
if Family_Size=4 then FS4=1;else FS4=0;
if Family_Size=5 then FS5=1;else FS5=0;
if Family_Size=6 then FS6=1;else FS6=0;
run;

data sp.combined;
set sp.combined;
if Marital_Status=0 then Marital_Status0=1;else Marital_Status0=0;
if Marital_Status=1 then Marital_Status1=1;else Marital_Status1=0;
if Marital_Status=2 then Marital_Status2=1;else Marital_Status2=0;
if Marital_Status=3 then Marital_Status3=1;else Marital_Status3=0;
if Marital_Status=4 then Marital_Status4=1;else Marital_Status4=0;
if Marital_Status=5 then Marital_Status5=1;else Marital_Status5=0;
run;


data sp.combined;
set sp.combined;
if HH_HEAD_RACE_RACE3=0 then ETHNICITY0=1;else ETHNICITY0=0;
if HH_HEAD_RACE_RACE3=1 then ETHNICITY1=1;else ETHNICITY1=0;
if HH_HEAD_RACE_RACE3=2 then ETHNICITY2=1;else ETHNICITY2=0;
if HH_HEAD_RACE_RACE3=3 then ETHNICITY3=1;else ETHNICITY3=0;
if HH_HEAD_RACE_RACE3=4 then ETHNICITY4=1;else ETHNICITY4=0;
if HH_HEAD_RACE_RACE3=5 then ETHNICITY5=1;else ETHNICITY5=0;
if HH_HEAD_RACE_RACE3=6 then ETHNICITY6=1;else ETHNICITY6=0;
if HH_HEAD_RACE_RACE3=7 then ETHNICITY7=1;else ETHNICITY7=0;
run;


data sp.combined;
set sp.combined;
if Children_Group_Code=0 then Child_NA=1;else Child_NA=0;
if Children_Group_Code=1 then Child_0_5=1;else Child_0_5=0;
if Children_Group_Code=2 then Child_6_11=1;else Child_6_11=0;
if Children_Group_Code=3 then Child_12_17=1;else Child_12_17=0;
if Children_Group_Code=4 then Child_05_611=1;else Child_05_611=0;
if Children_Group_Code=5 then Child_05_1217=1;else Child_05_1217=0;
if Children_Group_Code=6 then Child_611_1217=1;else Child_611_1217=0;
if Children_Group_Code=7 then Child_05_611_1217=1;else Child_05_611_1217=0;
if Children_Group_Code=8 then No_Child=1;else No_Child=0;
run;

/*RFM Analysis*/
*RFM*;

/*Using the RFM library from SAS Library*/
/*We are performing RFM only for the Panel_GR data Drug store data is very minimal and has no impact.*/

%aaRFM;
%EM_RFM_CONTROL
(
   Mode = T,              
   InData = sp.panel_gr,            
   CustomerID = PANID,        
   N_R_Grp = 5,         
   N_F_Grp = 5,         
   N_M_Grp = 5,         
   BinMethod = I,          
   PurchaseDate = week,      
   PurchaseAmt = dollars,       
   SetMiss = Y,                                                         
   SummaryFunc = SUM,      
   MostRecentDate = ,    
   NPurchase = ,         
   TotPurchaseAmt = ,    
   MonetizationMap = Y, 
   BinChart = Y,        
   BinTable = Y,        
   OutData = sp.RFM_OUT,           
   Recency_Score = recency_score,     
   Frequency_Score = frequency_score,   
   Monetary_Score = monetary_score,    
   RFM_Score = rfm_score           
);


proc sql outobs = 50;
	select * from sp.RFM_OUT;
quit;

/*Checking for the correlation between RFM*/

proc corr data=sp.RFM_OUT;
var recency_score frequency_score monetary_score; 
run;

/*From the output of the Correlation, we could see the Frequency and the Monetary and highly correlated.
Hence, we are neglecting the Frequency over Monetary as money is important factor*/

/*Sorting the dataset based on RFM score*/

Proc sort data = sp.RFM_OUT;
by descending rfm_score;
run;

/*Finding the Loyal Customers*/

/*Now, since we are not including the F part in RFM, we are neglecting F and creating a RM score by adding both 
factors to categorize the loyal customer*/

data sp.RFM_OUT;
set sp.RFM_OUT;
rm_score = recency_score + monetary_score;
run;

PROC freq data = sp.RFM_OUT;
table rm_score;
run;

/*Merging the customers with Panel_GR data to do further analysis on Loyal customers*/

proc sort data = sp.RFM_OUT;
by panid;
proc sort data = sp.panel_gr;
by panid;
data sp.panel_rfm;
merge sp.panel_gr (in=inpanel_gr) sp.RFM_OUT (in=inRFM_out);
by panid;
if inpanel_gr & inRFM_out;
run;


proc sql outobs = 10;
select * from sp.panel_rfm;
quit;

/*We are considering RM > 8 and if R>4, M>4, then customer is Loyal else Not loyal*/

data sp.panel_rfm;
set sp.panel_rfm;
if (rm_score >7) and (recency_score > 4 and monetary_score > 4) then Loyal = 1; else Loyal = 0;
run;

/*Merging with product and demographics to analyze how the customer Household characteristics impacts their loyalty level*/
/*Also, we are concentrating only on the top 3 brands in the Panel_GR dataset which is Ragu, Prego and FRANCESCO'.*/

proc sql;
select * from sp.product_top3brand;
quit;

proc sql;
Create Table sp.panel_rfm AS 
Select *
from sp.panel_rfm pr
inner join sp.product_top3brand p
on pr.colupc = p.colupc
Group BY WEEK, p.BRAND, OUTLET
order by BRAND, WEEK;
QUIT;

proc sql;
	create table sp.loyal_dist_3brands as
	select distinct PANID, rm_score, recency_score, monetary_score, frequency_score, BRAND from sp.panel_rfm;
quit;

/*Finding the loyal custmer frequency*/
PROC freq data = sp.loyal_dist_3brands;
table rm_score;
run;

/*Frequency and Monetary score comparison by Brand*/

proc freq data=sp.loyal_dist_3brands;
table brand*monetary_score / out=monetarycomparison (keep= brand monetary_score count) nopercent nocum;
run;

title1 'Break-down of Money spending Customers by Brand';
proc sgplot data=monetarycomparison;
   vbar brand / group=monetary_score response=count groupdisplay=cluster seglabel seglabelattrs=(size=8);
   xaxis display=(nolabel noticks);
   yaxis label='Count of number of Monetary Customers';
   keylegend / title='Monetary Rank';
run;

/*Recency score comparison by Brand*/

proc freq data=sp.loyal_dist_3brands;
table brand*recency_score / out=frequencycomparison (keep= brand recency_score count) nopercent nocum;
run;

title1 'Break-down of Recency of Customers buying a Brand';
proc sgplot data=frequencycomparison;
   vbar brand / group=recency_score response=count groupdisplay=cluster seglabel seglabelattrs=(size=8);
   xaxis display=(nolabel noticks);
   yaxis label='Frequency of Customers by Brand';
   keylegend / title='Recency Rank';
run;

/*Brand Loyalty Comparison*/
proc freq data = sp.panel_rfm;
table BRAND*Loyal;
run;

/*Number of times customer buying a brand*/

proc freq data = sp.panel_rfm;
table brand*panid;
run;

/*Merging the Demographics data to this to run the logistic regression and find how 
house hold characterstics affects the loyalty of the customer*/


proc sql;
create table sp.panel_rfm as 
select * from sp.panel_rfm p
inner join sp.demo_panel d
on d.panid = p.panid;
quit;



proc contents data = sp.panel_rfm1;
run;
/* Renaming the demographies to avoid truncation in the results  */

data sp.panel_rfm1;
set sp.panel_rfm (rename = ( 	Age_Group_Applied_to_Female_HH = Age_Female_HH
								Age_Group_Applied_to_Male_HH = Age_Male_HH
								Children_Group_Code = Children
								Combined_Pre_Tax_Income_of_HH = Com_Tax
								Education_Level_Reached_by_Femal = Edu_Female
								Education_Level_Reached_by_Male = Edu_Male
								Family_Size = Family_Size
								Female_Working_Hour_Code = Work_Code_Female
								HH_AGE = HH_AGE
								HH_EDU = HH_EDU
								HH_Head_Race__RACE3_ = HH_Head_Race
								HH_OCC = HH_OCC
								Loyal = Loyal
								Male_Working_Hour_Code = Work_Code_Male
								Marital_Status = Marital_Status
								Microwave_Owned_by_HH = MicroOven
								Number_of_Cats = No_Cats
								Number_of_Dogs = No_Dogs
								Number_of_TVs_Hooked_to_Cable = No_TV_Cable
								Number_of_TVs_Used_by_HH = No_TV
								Occupation_Code_of_Female_HH = OCC_Female
								Occupation_Code_of_Male_HH = OCC_Male
								Panelist_Type = Panelist_Type
								Type_of_Residential_Possession = Home_Owner
));
run;


data sp.panel_rfm;
set sp.panel_rfm1;
run;


data sp.panel_rfm12;
set sp.panel_rfm;
costperunit = dollars/units;
run;

proc ttest data = sp.panel_rfm12; var costperunit; class loyal; run;


/*Logistic Regression with all possible demographies which we obtained after removing few redundant and irrelavant demograpies*/

proc logistic data=sp.panel_rfm outmodel=log_out desc;
	class Age_Female_HH Age_Male_HH Children Com_Tax Edu_Female Edu_Male Family_Size Work_Code_Female HH_AGE HH_EDU HH_Head_Race
HH_OCC Work_Code_Male Marital_Status MicroOven No_Cats No_Dogs No_TV_Cable No_TV OCC_Female OCC_Male Panelist_Type Home_Owner
			 / param=ref;
	model loyal = Age_Female_HH Age_Male_HH Children Com_Tax Edu_Female Edu_Male Family_Size Work_Code_Female HH_AGE HH_EDU HH_Head_Race
HH_OCC Work_Code_Male Marital_Status MicroOven No_Cats No_Dogs No_TV_Cable No_TV OCC_Female OCC_Male Panelist_Type Home_Owner
 / selection=stepwise slentry= 0.3 slstay=0.2 expb;
    output out=preds predprobs=individual;
run;


proc logistic data=sp.panel_rfm outmodel=log_out desc;
	class Age_Female_HH Age_Male_HH Children Com_Tax Edu_Male Family_Size Work_Code_Male Marital_Status MicroOven No_Cats  Panelist_Type Home_Owner
			 / param=ref;
	model loyal = Age_Female_HH Age_Male_HH Children Com_Tax Edu_Male Family_Size Work_Code_Male Marital_Status MicroOven No_Cats  Panelist_Type Home_Owner
 / expb;
    output out=preds predprobs=individual;
run;


data sp.panel_rfm_prego;
set sp.panel_rfm;
where (brand = 'PREGO');
run;


proc logistic data=sp.panel_rfm_prego outmodel=log_out desc;
	class Age_Female_HH Age_Male_HH Children Com_Tax Edu_Female Edu_Male Family_Size Work_Code_Female HH_AGE HH_EDU HH_Head_Race
HH_OCC Work_Code_Male Marital_Status MicroOven No_Cats No_Dogs No_TV_Cable No_TV OCC_Female OCC_Male Panelist_Type Home_Owner
			 / param=ref;
	model loyal = Age_Female_HH Age_Male_HH Children Com_Tax Edu_Female Edu_Male Family_Size Work_Code_Female HH_AGE HH_EDU HH_Head_Race
HH_OCC Work_Code_Male Marital_Status MicroOven No_Cats No_Dogs No_TV_Cable No_TV OCC_Female OCC_Male Panelist_Type Home_Owner
 / selection=stepwise slentry= 0.3 slstay=0.2 expb;
    output out=preds predprobs=individual;
run;

proc logistic data=sp.panel_rfm outmodel=log_out desc;
	class Age_Female_HH Age_Male_HH Children Com_Tax Edu_Male Family_Size HH_OCC 
			 / param=ref;
	model loyal = Age_Female_HH Age_Male_HH Children Com_Tax Edu_Male Family_Size HH_OCC
 / expb;
    output out=preds predprobs=individual;
run;



/*Survival Analysis*/

/*Finding Tenure for the Survival analysis*/

PROC SQL;
create table sp.min_week as
select distinct WEEK, PANID from sp.PANEL_GR 
group by PANID 
having WEEK = min(WEEK); 
quit;

PROC SQL;
create table sp.max_week as
select distinct WEEK, PANID from sp.PANEL_GR 
group by PANID 
having WEEK = max(WEEK); 
quit;


proc sql;
create table sp.sales_count as 
select count(units) as Frequency, PANID from sp.PANEL_GR 
group by PANID; 
quit;

proc sql;
create table sp.customer_dollars as 
select sum(dollars) as Monetary, PANID from sp.PANEL_GR 
group by PANID; 
quit;


PROC SQL;
	create table sp.survival as 
	select mi.WEEK as START_WEEK, ma.WEEK AS END_WEEK, mi.PANID AS Customer_ID , (ma.week - mi.WEEK) as Tenure
	FROM sp.min_week mi 
	INNER JOIN sp.max_week ma 
	ON (mi.PANID = ma.PANID) 
	GROUP BY mi.PANID
	order by Tenure;
quit;

proc sql;
	create table sp.survival as
	select S.Customer_id, s.START_WEEK, s.END_WEEK, S.Tenure, sc.Frequency, c.Monetary, (1165-s.END_WEEK) as Recency from sp.survival s
	inner join sp.sales_count sc on s.Customer_ID = sc.PANID
	inner join sp.customer_dollars c on s.Customer_ID = c.PANID
	GROUP by s.Customer_ID;
quit;

proc sql outobs = 10;
	select * from sp.survival;
quit;

data sp.survival1;
set sp.survival;
if END_WEEK >= 1165 then churn=0;
else churn=1;
run;

data sp.survival1;
set sp.survival1;
if Tenure > 0;
run;


proc sql;
create table sp.survival1 as
select Customer_ID, START_WEEK, END_WEEK, Tenure, Frequency, Monetary, Recency, churn, p.Marital_Status, p.Family_Size, p.Age_Group_Applied_to_Male_HH as Male_Age,
p.Education_Level_Reached_by_Femal as Edu_Fem, p.Microwave_Owned_by_HH as Micro, p.Combined_Pre_Tax_Income_of_HH as com_tax
from sp.survival1 s
inner join sp.demo p 
on p.PANID = s.Customer_id;
Quit; 


/*Survival Function*/
proc lifetest data=sp.survival1 plots=(s)atrisk graphics outsurv=a;
time tenure*churn(0);
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;

/*Survival Function with respect to Family size*/
ods graphics on / width=12in height=8in;
proc lifetest data=sp.survival1 plots=(s) atrisk graphics outsurv=a;
time tenure*churn(0);
strata Marital_Status;
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;


/*Survival for Prego*/

PROC SQL;
create table sp.min_week as
select distinct WEEK, PANID from sp.panel_GR gr
inner join sp.product p
on p.colupc = gr.colupc
where BRAND = 'PREGO'
group by PANID 
having WEEK = min(WEEK); 
quit;

PROC SQL;
create table sp.max_week as
select distinct WEEK, PANID from sp.panel_GR gr
inner join sp.product p
on p.colupc = gr.colupc
where BRAND = 'PREGO'
group by PANID 
having WEEK = max(WEEK); 
quit;


proc sql;
create table sp.sales_count as 
select count(units) as Frequency, PANID from sp.PANEL_GR gr
inner join sp.product p
on p.colupc = gr.colupc
where BRAND = 'PREGO'
group by PANID; 
quit;

proc sql;
create table sp.customer_dollars as 
select sum(dollars) as Monetary, PANID from sp.PANEL_GR gr
inner join sp.product p
on p.colupc = gr.colupc
where BRAND = 'PREGO'
group by PANID; 
quit;


PROC SQL;
	create table sp.survival as 
	select mi.WEEK as START_WEEK, ma.WEEK AS END_WEEK, mi.PANID AS Customer_ID , (ma.week - mi.WEEK) as Tenure
	FROM sp.min_week mi 
	INNER JOIN sp.max_week ma 
	ON (mi.PANID = ma.PANID) 
	GROUP BY mi.PANID
	order by Tenure;
quit;

proc sql;
	create table sp.survival as
	select S.Customer_id, s.START_WEEK, s.END_WEEK, S.Tenure, sc.Frequency, c.Monetary, (1165-s.END_WEEK) as Recency from sp.survival s
	inner join sp.sales_count sc on s.Customer_ID = sc.PANID
	inner join sp.customer_dollars c on s.Customer_ID = c.PANID
	GROUP by s.Customer_ID;
quit;


proc sql outobs = 10;
	select * from sp.survival1;
quit;

data sp.survival1;
set sp.survival;
if END_WEEK>=1165 then churn=0;
else churn=1;
run;

data sp.survival1;
set sp.survival1;
if Tenure > 0;
run;



proc contents data = sp.survival1;
run;

proc sql;
create table sp.survival1 as
select Customer_ID, START_WEEK, END_WEEK, Tenure, Frequency, Monetary, Recency, churn, p.Marital_Status, p.Family_Size, p.Age_Group_Applied_to_Male_HH as Male_Age,
p.Education_Level_Reached_by_Femal as Edu_Fem, p.Microwave_Owned_by_HH as Micro, p.Combined_Pre_Tax_Income_of_HH as com_tax
from sp.survival1 s
inner join sp.demo p 
on p.PANID = s.Customer_id;
Quit; 

/*Survival Function*/
proc lifetest data=sp.survival1 plots=(s)atrisk graphics outsurv=a;
time tenure*churn(0);
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;

/*Survival Function with respect to Family size*/
ods graphics on / width=12in height=8in;
proc lifetest data=sp.survival1 plots=(s) atrisk graphics outsurv=a;
time tenure*churn(0);
strata Marital_Status;
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;


proc sql;
select * from sp.survival1 where tenure = 0;
quit;

 
 
 
 