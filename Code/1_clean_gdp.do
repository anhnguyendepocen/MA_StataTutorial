***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Creating the Panel GDP datasets to merge with nightlights
* Original Date: January 9th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
clear all 
set more off

**************************************************
******  CREATING THE STATE GDP DATASETs **********
**************************************************

import delimited "${raw}\gdp_state_annual_longformat.csv", clear varnames(1)

// Dropping variables and observations
drop region subnational frequency source seriesremarks seriesid srcode ///
mnemonic functioninformation firstobsdate lastobsdate lastupdatetime ///
suggestions mean variance standarddeviation skewness kurtosis ///
coefficientvariation min max median noofobs v29-v41

// Renaming variables
* Year variables
forvalues i = 42 (1) 66 {
	local x = `i'+1952
	rename v`i' gdp`x'
}

rename v3 state
rename ïyear year


// Cleaning the GDP variable
forvalues i = 1994 (1) 2018 {
	replace gdp`i'="" if gdp`i'=="#N/A"
}

***********************************************
*****Generating Panel for the new series ******
***********************************************
preserve

// Creating dummy for new series
gen newseries_dummy =  strpos(state, "2011-12p") > 0

// Keeping the new series
keep if newseries_dummy>0 // Keeping the new series
drop gdp1994-gdp2011 status year comments newseries_dummy 

// Creating the state variable 
split state ,parse("2011-12p: ") 
drop state state1
rename state2 state

// Reshaping the data
reshape long gdp,i(state) j(year)

destring gdp,replace

// Setting as Panel Data
egen state_id=group(state)
xtset state_id year

gen gdp_growth=D.gdp/L.gdp // Traditional Formula

gen ln_gdp=ln(gdp) // Calculating Growth using log-approximation
gen ln_growth=D.ln_gdp

// Labeling Variables
label var state "State"
label var year "Year"
label var gdp "State GDP"
label var gdp_growth "Growth Rate of GDP"
label var ln_gdp "Log GDP"
label var ln_growth "Growth Rate of GDP (Log Approx)"

saveold "${final}\gdp_panel_newseries.dta",replace version(12)

restore

