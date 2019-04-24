***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Merging DMSP and GDP with Analysis
* Original Date: February 27th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
set more off
clear all

**************************************************
******  MERGING GDP and DMSP DATASETS   **********
**************************************************

use "${final}\worldgdp_panel.dta",clear

merge 1:1 country year using "${final}\dmsp_panel.dta"

keep if _m==3
drop _m 

egen id =group(country)
gen ln_lum = avg_

// Setting Panel Data
xtset id year 

// Regressing and Saving Residuals
reghdfe log_gdp ln_lum ,absorb(country_fe = id time_fe = year,savefe) vce(robust)

predict yhat,xb
reg log_gdp ln_lum i.year i.id

qui summarize log_gdp
bysort year : egen mean_gdp = mean(log_gdp)
replace time_fe = time_fe - mean_gdp

// Getting Residuals From a Time Trend
*reg time_fe year,noconstant

predict year_fe,resid


*preserve
drop if country!="India"
keep country year_fe ln_lum log_gdp country_fe year time_fe yhat

gen pred_gdp =26.456+.36*ln_lum + country_fe + time_fe

scatter pred_gdp log_gdp

reg pred_gdp log_gdp
*restore
