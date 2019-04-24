***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Merging VIIRS and GDP with Analysis
* Original Date: February 4th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
set more off
clear all

**************************************************
******  MERGING GDP and VIIRS DATASETS  **********
**************************************************

use "${final}\gdp_panel_newseries.dta",clear

merge 1:1 state year using "${final}\viirs_panel.dta"

keep if _m==3
drop _m 

xtset state_id year 

gen state_dummy=1

replace state_dummy=0 if state=="Sikkim"  ///
| state=="Nagaland" | state=="Mizoram" | state=="Manipur" | ///
state=="Meghalaya" | state=="Goa" | state=="Andaman and Nicobar Islands" | ///
 state=="Himachal Pradesh"


gen year2016 = (year == 2016)

// saveold "${final}\merged_viirs_gdp.dta",replace version(12)
save "${final}\merged_viirs_gdp.dta", replace

xtreg ln_gdp ln_luminosity, fe vce(robust)

*xtreg ln_growth ln_luminosity_growth if (state_dummy == 1), vce(robust)
*reg ln_gdp ln_luminosity i.state_id i.year if year>2013 & state_dummy==1,  vce(robust)
