***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Merging DMSP and GDP with Analysis
* Original Date: February 27th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
clear all
set more off

**************************************************
******  MERGING GDP and DMSP DATASETS   **********
**************************************************

use "${final}\worldgdp_panel.dta",clear

// Merging
merge 1:1 country year using "${final}\dmsp_panel.dta"

// Dropping Unmatched
keep if _m==3
drop _m 


**************************************************
******           BASIC COMMANDS           ********
**************************************************

// Describing the Data
describe 

//Summarizing GDP Data
summarize gdp, detail

// Frequency of Economies of Countries
tab economy

// Two way Tabulations of Economies and Continents
tab2 economy continent
tab2 economy continent, nofreq column

// Sorting data
sort country year

// Creating table of statistics
tabstat log_gdp pop_est , s(mean sd median)

// Creating a variable of the number of observations we have for each country
bysort country : gen count = _N
drop count
bysort country : gen count = _n

drop count
bysort economy year : gen count = _N

**************************************************
******           BASIC PLOTS              ********
**************************************************
	
// Histogram	
	hist log_gdp , scheme(s1color) bin(50) fcolor(green)  ///
	graphregion(color(white)) lcolor(dkgreen) subtitle(, fcolor(white)) fract ///
	xtitle("GDP")

// Scatter Plots and Line Plots

* Want to Plot Average World GDP over time
   scatter log_gdp year

* Collapse the data and also preserve the data, so that you can restore it!

preserve
collapse (mean) log_gdp log_luminosity, by(year)
scatter log_gdp year 

graph twoway line log_gdp year
graph twoway line log_gdp log_luminosity year
graph twoway connected log_gdp log_luminosity year

restore

* Want to do it by Economy Type
preserve
collapse (mean) log_gdp pop_est, by(year economy)
scatter log_gdp year , by(economy)
restore

// Bar Graphs
gen luminosity = exp(log_luminosity)
graph bar log_gdp luminosity, over(economy) 

graph hbar log_gdp luminosity, over(economy) 

**************************************************
******           REGRESSIONS              ********
**************************************************

// Creating group variable and takin
egen id =group(country)

// Setting Panel Data
xtset id year 

// Regressing
reghdfe log_gdp ln_lum ,absorb(country_fe = id time_fe = year) vce(robust)

