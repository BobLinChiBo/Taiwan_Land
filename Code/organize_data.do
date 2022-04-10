*import excel "./Data_Raw/total_land_area1951.xlsx", sheet("Sheet1") firstrow clear
*save "./Data_Modified/total_land_area1951.dta", replace

cap program drop load_sheets
program define load_sheets
	local path `1'
	local sheet_names `2'
	local col_names `3'
	local i `4'
	local j `5'
	local name `6'
	foreach sheet_name in `sheet_names' {
		import excel `path', sheet(`sheet_name') firstrow clear
		foreach col_name in `col_names'{
		    rename `col_name' `col_name'`sheet_name'
		}
		save "./Data_Modified/`name'`sheet_name'.dta", replace
	}
	foreach sheet_name in `sheet_names' {
		merge 1:1 `i' using "./Data_Modified/`name'`sheet_name'.dta", nogenerate  
	}
	di "`col_names'"
	reshape long `col_names', i(`i') j(`j')
	save "./Data_Modified/`name'.dta", replace
end

*** general value
local years 1950 1951 1952 1953 1954 1955 1956
local main_types total_value common_crop_value special_crop_value horticultural_crop_value sericulture_value livestock_value
load_sheets "./Data_Raw/general/general_value.xlsx" "`years'" "`main_types'" "region" "year" "general_value"   


*** Rice
local years 1950 1951 1952 1953 1954 1955 1956
foreach year in `years' {
	import excel "./Data_Raw/common_crop/rice/rice.xlsx", sheet("`year'") firstrow clear
	replace region = usubstr(region, 1, ustrpos(region, "_first") - 1) if ustrpos(region,"_first") != 0
	replace region = usubstr(region, 1, ustrpos(region, "_second") - 1) if ustrpos(region,"_second") != 0
	collapse (sum) area_ha yield_kg value ,by(region)
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


*** each agriculture product
local years 1950 1951 1952 1953 1954 1955 1956
local main_vars area_ha yield_kg value
local common_crops ........
foreach crop in `common_crops' {
	load_sheets "./Data_Raw/common_crop/common_exclude_rice/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
}
local special_crops .......
foreach crop in `special_crops' {
	load_sheets "./Data_Raw/common_crop/special_crop/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
}
local vegetables .......
foreach crop in `vegetables' {
	load_sheets "./Data_Raw/common_crop/horticultural_crop/vegetable/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
}
local fruits .......
foreach crop in `fruits' {
	load_sheets "./Data_Raw/common_crop/horticultural_crop/fruit/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
}

*** tenant cultivated area
local years 1952 1953 1956
foreach year in `years' {
	import excel "./Data_Raw/land/tenant_contract.xlsx", sheet("`year'") firstrow clear
	keep tenant_number total_area paddy_field dry_land
	rename tenant_number tenant_number`year'
	rename total_area tenant_area`year'
	rename paddy_field paddy_field_tenant_area`year'
	rename dry_land dry_land_tenant_area`year'
	save "./Data_Modified/tenant_area`year'.dta", replace
}
foreach year in `years' {
	merge 1:1 region using "./Data_Modified/tenant_area`year'.dta", nogenerate  
}
reshape long tenant_number tenant_area paddy_field_tenant_area dry_land_tenant_area, i(region) j(year)
bysort region year: gen tenant_area_1952 = tenant_area[1]
bysort region year: gen paddy_field_tenant_area_1952 = paddy_field_tenant_area[1]
bysort region year: gen dry_land_tenant_area_1952 = dry_land_tenant_area[1]
gen tenant_area_change = tenant_area - tenant_area_1952
gen paddy_field_tenant_area_change = paddy_field_tenant_area - paddy_field_tenant_area_1952
gen dry_land_tenant_area_change = dry_land_tenant_area - dry_land_tenant_area_1952
save "./Data_Modified/tenant.dta", replace


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

gen ln_rice_yield = ln(rice_yield)
gen ln_rice_yield_per_ha = ln(rice_yield_per_ha)

gen total_rice_value1951 = 1507784105
bysort year: egen total_rice_value = total(rice_value)
gen rice_price_index = 100* (total_rice_value/total_rice_value1951)/105.8 if year == 1952
replace rice_price_index = 100* (total_rice_value/total_rice_value1951)/110.6 if year == 1953
replace rice_price_index = 100* (total_rice_value/total_rice_value1951)/120.5 if year == 1956

gen total_common_value1951 =  3773765053 
gen total_common_ex_rice_value1951 =  total_common_value1951 - total_rice_value1951
bysort year: egen total_common_value = total(common_crop_value)
gen common_ex_rice_value = common_crop_value - rice_value
gen total_common_ex_rice_value = total_common_value - total_rice_value
gen common_ex_rice_price_index = 100* (total_common_ex_rice_value/total_common_ex_rice_value1951)/101.8 if year == 1952
replace common_ex_rice_price_index = 100* (total_common_ex_rice_value/total_common_ex_rice_value1951)/113.2 if year == 1953
replace common_ex_rice_price_index = 100* (total_common_ex_rice_value/total_common_ex_rice_value1951)/137.1 if year == 1956

gen total_special_value1951 = 748338763 
bysort year: egen total_special_value = total(special_crop_value)
gen special_price_index = 100* (total_special_value/total_special_value1951)/125 if year == 1952
replace special_price_index = 100* (total_special_value/total_special_value1951)/169.1 if year == 1953
replace special_price_index = 100* (total_special_value/total_special_value1951)/157.0 if year == 1956

gen adjust_rice_value = rice_value / rice_price_index
gen adjust_common_ex_rice_value = common_ex_rice_value / common_ex_rice_price_index
gen adjust_special_value = special_crop_value / special_price_index
*gen adjust_horticultural_crop_value = horticultural_crop_value / wholesale_price_index
gen ln_rice_value = ln(rice_value)
gen ln_common_ex_rice_value = ln(common_ex_rice_value)
gen ln_adjust_rice_value = ln(adjust_rice_value)
gen ln_adjust_common_ex_rice_value = ln(adjust_common_ex_rice_value)
gen ln_adjust_special_value = ln(adjust_special_value)
*gen ln_adjust_horticultural_crop_value = ln(adjust_horticultural_crop_value)




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