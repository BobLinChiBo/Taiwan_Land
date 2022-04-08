*import excel "./Data_Raw/total_land_area1951.xlsx", sheet("Sheet1") firstrow clear
*save "./Data_Modified/total_land_area1951.dta", replace

*** Rice
local years 1952 1953 1956
foreach year in `years' {
	import excel "C:\Users\boblin\Documents\GitHub\Taiwan_Land\Data_Raw\Rise.xlsx", sheet("`year'") firstrow clear
	replace A = usubstr(A,1, ustrpos(A,"_first") - 1) if ustrpos(A,"_first") != 0
	replace A = usubstr(A,1, ustrpos(A,"_second") - 1) if ustrpos(A,"_second") != 0
	rename A region
	quietly describe, varlist
	local vars `r(varlist)'
	local omit region
	local want : list vars - omit
	collapse (sum) `want' ,by(region)
	keep region area_ha yield_kg value
	rename area_ha area`year'
	rename yield_kg rice_yield`year'
	rename value rice_value`year'
	save "./Data_Modified/rice`year'.dta", replace
}

foreach year in `years' {
	merge 1:1 region using "./Data_Modified/rice`year'.dta", nogenerate  
}
reshape long rice_yield rice_value area, i(region) j(year)
gen rice_yield_per_ha = rice_yield / area  
save "./Data_Modified/rice.dta", replace

local crop_types common_crop_value special_crop_value horticultural_crop_value
foreach crop_type in `crop_types' {
	import excel "./Data_Raw/`crop_type'.xlsx", sheet("Sheet1") firstrow clear
	reshape long `crop_type', i(region) j(year)
	save "./Data_Modified/`crop_type'.dta", replace
}

import excel "./Data_Raw/tenant_area.xlsx", sheet("Sheet1") firstrow clear
reshape long tenant_area, i(region) j(year)
save "./Data_Modified/tenant_area.dta", replace

import excel "./Data_Raw/tenant_area_change.xlsx", sheet("Sheet1") firstrow clear
reshape long tenant_area_change, i(region) j(year)
save "./Data_Modified/tenant_area_change.dta", replace


**** Merge
use "./Data_Modified/tenant_area_change.dta", clear
merge 1:1 region year using "./Data_Modified/tenant_area.dta", nogenerate  

foreach crop_type in `crop_types' {
	merge 1:1 region year using "./Data_Modified/`crop_type'.dta", nogenerate  
	gen ln_`crop_type' = ln(`crop_type')
} 

merge 1:1 region year using "./Data_Modified/rice.dta", nogenerate  

replace area = 0 if area == .
replace rice_yield = 0 if rice_yield == .
replace rice_value = 0 if rice_value == .
replace rice_yield_per_ha = 0 if rice_yield_per_ha == .

gen after_reform = year >= 1953 
encode region, gen(region_code)
drop region
replace tenant_area_change = -tenant_area_change 
bysort region_code (year): gen tenant_area_1952 = tenant_area[1]
gen after_tenant_area_1952 = after_reform * tenant_area_1952

save "./Data_Modified/organized_data.dta", replace

local years 1952 1953 1956
foreach year in `years' {
	preserve
	keep if year == `year'
	outreg2 using "./Output/summary_`year'.rtf", word replace sum(log)
	restore
} 



/*
*merge m:1 region using "./Data_Modified/total_land_area1951.dta", nogenerate  

*rename total_land_area total_land_area1951
*replace region = "Taipei_prefecture" if region == "Yangmingshan"
*quietly describe, varlist
*local vars `r(varlist)'
*local omit region year
*local want : list vars - omit
*collapse (sum) `want' ,by(region year)
gen after_reform = year >= 1953 
encode region, gen(region_code)
replace tenant_area_change = -tenant_area_change 
*gen tenant_share = tenant_area/total_land_area1951
*bysort region_code (year): gen tenant_share_1952 = tenant_share[1]
*gen after_tenant_share_1952 = after_reform * tenant_share_1952
bysort region_code (year): gen tenant_area_1952 = tenant_area[1]
gen after_tenant_area_1952 = after_reform * tenant_area_1952

*** Whole Sample
*collect _r_b _r_se has_panel="YES", tag(model[common_crop(1952 area)]): ///
*    xtreg common_crop_value after_reform after_tenant_area_1952 , fe robust 
collect _r_b _r_se has_panel="YES", tag(model[common_crop]): ///
    xtreg common_crop_value after_reform tenant_area_change, fe robust
*collect _r_b _r_se has_panel="YES", tag(model[special_crop(1952 area)]): ///
*    xtreg special_crop_value after_reform after_tenant_area_1952 , fe robust
collect _r_b _r_se has_panel="YES", tag(model[special_crop]): ///
    xtreg special_crop_value after_reform tenant_area_change, fe robust
*collect _r_b _r_se has_panel="YES", tag(model[horticultural(1952 area)]): ///
*    xtreg horticultural_crop_value after_reform after_tenant_area_1952 , fe robust
collect _r_b _r_se has_panel="YES", tag(model[horticultural_crop]): ///
    xtreg horticultural_crop_value after_reform tenant_area_change, fe robust
*/