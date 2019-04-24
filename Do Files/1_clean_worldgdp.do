***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Creating the World GDP dataset
* Original Date: February 4th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
clear all
set more off

**************************************************
******  CREATING THE STATE GDP DATASETs **********
**************************************************

import delimited "${raw}\world_gdp.csv", clear varnames(1)

// Dropping Irrelevant variables
drop v5-v36 v63 indicatorname indicatorcode

// Renaming the variables since STATA doesn't read numberic variable names
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("gdp`lbl'")
    rename `v' `lbl'
}

rename gdpï»¿Country_Name country
rename gdpCountry_Code country_code

// Reshaping the data
reshape long gdp, i(country) j(year)

// Creating Log GDP 
gen log_gdp=log(gdp)

saveold "${final}\worldgdp_panel.dta",replace version(12)
