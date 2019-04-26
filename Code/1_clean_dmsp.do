***************************************************************************
* Project: India GDP and Night Lights 
* Purpose: Cleaning DMSP data
* Original Date: February 4th 2019
* Original Author: Vinayak Iyer
***************************************************************************

set logtype text
cap log close
clear all
set more off

**************************************************
******      CREATING VIIRS DATASET      **********
**************************************************

import delimited "${raw}\world_dmsp.csv", clear varnames(1)

// Dropping Irrelevant Variables
rename name_en english_name

drop featurecla sov_a3 level scalerank labelrank adm0_dif ///
su_a3 postal type adm0_a3 pop_rank gdp_md_est pop_year ///
 lastcensus gdp_year wikipedia fips_10_ iso_a2 iso_a3 ///
 iso_a3_eh iso_n3 un_a3 wb_a2 wb_a3 woe_id woe_id_eh woe_note ///
 adm0_a3_is adm0_a3_us adm0_a3_un adm0_a3_wb long_len abbrev_len /// 
 tiny homepart min_zoom min_label max_label ne_id wikidataid ///
geou_dif gu_a3 su_dif brk_diff brk_a3 brk_name abbrev ///
brk_group formal_fr note_adm0 note_brk name_alt mapcolor7 ///
mapcolor8 mapcolor9 mapcolor13 name_*

drop *count *sum


// Creating Logs

local vars "s10_92mean s10_93mean s10_94mean s12_94mean s12_95mean s12_96mean s12_97mean s12_98mean s12_99mean s14_97mean s14_98mean s14_99mean s14_00mean s14_01mean s14_02mean s14_03mean s15_00mean s15_01mean s15_02mean s15_03mean s15_04mean s15_05mean s15_06mean s15_07mean s16_04mean s16_05mean s16_06mean s16_07mean s16_08mean s16_09mean s18_10mean s18_11mean s18_12mean s18_13mean"

foreach var of local vars{
	replace `var' = ln(`var')
}

// Creating Averages within satellite/years 
local years "93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13"
foreach year of local years {
	egen avg_`year' = rowmean(*`year'mean)
}

// Renaming Variables to Reshape
forvalues i = 93 (1) 99 {
	local j = `i' + 1900
	rename avg_`i' avg_`j'

}

rename avg_00 avg_2000
rename avg_01 avg_2001
rename avg_02 avg_2002
rename avg_03 avg_2003
rename avg_04 avg_2004
rename avg_05 avg_2005
rename avg_06 avg_2006
rename avg_07 avg_2007
rename avg_08 avg_2008
rename avg_09 avg_2009
rename avg_10 avg_2010
rename avg_11 avg_2011
rename avg_12 avg_2012
rename avg_13 avg_2013

drop *mean

// Creating an ID variable

egen country_id = group(english_name)

reshape long avg_,i(country_id) j(year)
rename avg_ log_luminosity

// Renaming Country Variable to match
rename name country

// Dropping More Variables
drop sovereignt admin geounit formal_en

saveold "${final}\dmsp_panel.dta",replace version(12)
