***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Cleaning VIIRS data
* Original Date: February 4th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close


**************************************************
******      CREATING VIIRS DATASET      **********
**************************************************

import delimited "${raw}\India_States_VIIRS.csv", clear varnames(1)

// Dropping Irrelevant variables
drop gid_0 name_0 gid_1 varname_1 nl_name_1 cc_1 hasc_1 engtype_1 

// Renaming the variables since STATA doesn't read numberic variable names
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("v_`lbl'")
    rename `v' `lbl'
}

rename v_NAME_1 state 
rename v_TYPE_1 category

label variable state "State"
label variable category "Category"


// Replacing negative values with 0

local negative v_12_04mean v_12_05mean v_12_06mean v_12_07mean ///
v_12_08mean v_12_09mean v_12_10mean v_12_11mean v_12_12mean ///
v_13_01mean v_13_02mean v_13_03mean v_13_04mean v_13_05mean ///
v_13_06mean v_13_07mean v_13_08mean v_13_09mean v_13_10mean ///
v_13_11mean v_13_12mean v_14_01mean v_14_02mean v_14_03mean ///
v_14_04mean v_14_05mean v_14_06mean v_14_07mean v_14_08mean ///
v_14_09mean v_14_10mean v_14_11mean v_14_12mean v_15_01mean ///
v_15_02mean v_15_03mean v_15_04mean v_15_05mean v_15_06mean ///
v_15_07mean v_15_08mean v_15_09mean v_15_10mean v_15_11mean ///
v_15_12mean v_16_01mean v_16_02mean v_16_03mean v_16_04mean ///
v_16_05mean v_16_06mean v_16_07mean v_16_08mean v_16_09mean ///
v_16_10mean v_16_11mean v_16_12mean v_17_01mean v_17_02mean ///
v_17_03mean v_17_04mean v_17_05mean v_17_06mean v_17_07mean ///
v_17_08mean v_17_09mean v_17_10mean v_17_11mean v_17_12mean ///
v_18_01mean v_18_02mean v_18_03mean v_18_04mean v_18_05mean ///
v_18_08mean v_18_09mean v_18_10mean v_18_11mean

foreach var of local negative{
	replace `var'=. if `var'<0
}

// Finding Average Luminosity for the year from VIIRS data
forvalues i = 12 (1) 18 {
	local j = 2000+`i'
	egen avg_luminosity`j' = rowmean(v_`i'*mean)
	egen total_luminosity`j' = rowtotal(v_`i'*sum)
}

// Dropping Irrelevant Variables
drop v_*

// Reshaping the data to long format
reshape long avg_luminosity total_luminosity ,i(state) j(year)

// Making State Names Comparable with GDP data
replace state = "Andaman and Nicobar Islands" if state=="Andaman and Nicobar"
replace state = "Delhi" if state=="NCT of Delhi"

// Setting as Panel Data
egen state_id=group(state)
xtset state_id year

gen luminosity_growth=D.avg_luminosity/L.avg_luminosity // Traditional Formula

gen ln_luminosity=ln(avg_luminosity) // Calculating Growth using log-approximation
gen ln_luminosity_growth=D.ln_luminosity

// Labeling Variables
label var state "State"
label var year "Year"
label var luminosity_growth "Growth Rate of Luminosity"
label var ln_luminosity "Log Luminosity"
label var ln_luminosity_growth "Growth Rate of Luminosity (Log Approx)"

saveold "${final}\viirs_panel.dta",replace version(12)
