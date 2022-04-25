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
		missings dropobs, force 
		missings dropvars, force 
		foreach col_name in `col_names'{
		    rename `col_name' `col_name'`sheet_name'
		}
		save "./Data_Modified/`name'`sheet_name'.dta", replace
	}
	foreach sheet_name in `sheet_names' {
		merge 1:1 `i' using "./Data_Modified/`name'`sheet_name'.dta", nogenerate force
	}
	di "`col_names'"
	reshape long `col_names', i(`i') j(`j')
	save "./Data_Modified/`name'.dta", replace
end

*** agricultral population
local years 1950 1951 1952 1953 1954 1955 1956
local main_types total_farmer_number owner_cultivator_number part_owner_number tenant_number
load_sheets "./Data_Raw/general/population.xlsx" "`years'" "`main_types'" "region" "year" "population"   

*** general value
local years 1950 1951 1952 1953 1954 1955 1956
local main_types total_value common_crop_value special_crop_value horticultural_crop_value sericulture_value livestock_value
load_sheets "./Data_Raw/general/general_value.xlsx" "`years'" "`main_types'" "region" "year" "general_value"   
foreach type in `main_types'{
	gen ln_`type' = log(`type')
}
save "./Data_Modified/general_value.dta", replace

*** Rice
local years 1950 1951 1952 1953 1954 1955 1956
local varlist area_ha yield_kg value
foreach year in `years' {
	import excel "./Data_Raw/common_crop/rice/rice.xlsx", sheet("`year'") firstrow clear
	di `year'
	keep region `varlist'
	split region, parse("_")
	drop region1 region2
	replace region = usubstr(region, 1, ustrpos(region, "_first") - 1) if ustrpos(region,"_first") != 0
	replace region = usubstr(region, 1, ustrpos(region, "_second") - 1) if ustrpos(region,"_second") != 0
	foreach var in `varlist'{
		bysort region (region3): egen rice_total_`var'`year' = total(`var')
		bysort region (region3): gen rice_first_`var'`year' = `var'[1]
		bysort region (region3): gen rice_second_`var'`year' = `var'[2]
		drop `var'
	}
	drop region3
	duplicates drop
	save "./Data_Modified/rice`year'.dta", replace
}

foreach year in `years' {
	merge 1:1 region using "./Data_Modified/rice`year'.dta", nogenerate  
}
reshape long rice_total_yield_kg rice_first_yield_kg rice_second_yield_kg rice_total_value rice_first_value rice_second_value rice_total_area_ha rice_first_area_ha rice_second_area_ha, i(region) j(year)
*gen ln_rice_total_value =log(rice_total_value)
*gen ln_rice_total_yield_kg = log(rice_total_yield_kg)

gen rice_total_yield_per_ha = rice_total_yield_kg / rice_total_area_ha 
gen rice_first_yield_per_ha = rice_first_yield_kg / rice_first_area_ha 
gen rice_second_yield_per_ha = rice_second_yield_kg / rice_second_area_ha 
save "./Data_Modified/rice.dta", replace


*** each agriculture product
local years 1950 1951 1952 1953 1954 1955 1956
local main_vars area_ha yield_kg value
local common_crops sweet_potato soybean
foreach crop in `common_crops' {
	load_sheets "./Data_Raw/common_crop/common_exclude_rice/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
	keep region year `main_vars'
	foreach var in `main_vars'{
		rename `var' `crop'_`var'
	}
*	gen ln_`crop'_value = log(`crop'_value)
*	gen ln_`crop'_yield_kg = log(`crop'_yield_kg)
	gen `crop'_yield_per_ha = `crop'_yield_kg / `crop'_area_ha 
	save "./Data_Modified/`crop'.dta", replace
}
local special_crops sugarcane tea cutton
foreach crop in `special_crops' {
	load_sheets "./Data_Raw/special_crop/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"     
	keep region year `main_vars'
	foreach var in `main_vars'{
		rename `var' `crop'_`var'
	}
*	gen ln_`crop'_value = log(`crop'_value)
*	gen ln_`crop'_yield_kg = log(`crop'_yield_kg)
	gen `crop'_yield_per_ha = `crop'_yield_kg / `crop'_area_ha 
	save "./Data_Modified/`crop'.dta", replace
}
local vegetables vegetable
foreach crop in `vegetables' {
	load_sheets "./Data_Raw/horticultural_crop/vegetable/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"       
	keep region year `main_vars'
	foreach var in `main_vars'{
		rename `var' `crop'_`var'
	}
*	gen ln_`crop'_value = log(`crop'_value)
*	gen ln_`crop'_yield_kg = log(`crop'_yield_kg)
	gen `crop'_yield_per_ha = `crop'_yield_kg / `crop'_area_ha 
	save "./Data_Modified/`crop'.dta", replace
}
/*
local fruits .......
foreach crop in `fruits' {
	load_sheets "./Data_Raw/horticultural_crop/fruit/`crop'.xlsx" "`years'" "`main_vars'" "region" "year" "`crop'"   
}
*/

*** tenant cultivated area
local years 1952 1953 1956
local main_types tenant_number_contract total_area paddy_field dry_land
load_sheets "./Data_Raw/land/tenant_contract.xlsx" "`years'" "`main_types'" "region" "year" "tenant" 
rename total_area tenant_area
rename paddy_field paddy_field_tenant_area
rename dry_land dry_land_tenant_area
rename others other_tenant_area
drop if region == "Total"
save "./Data_Modified/tenant.dta", replace

*** others
import excel "./Data_Raw/land/tenant_area_bought.xlsx", sheet("Sheet1") firstrow clear
save "./Data_Modified/tenant_area_bought.dta", replace

local years 1950 1952 1953 1954 1955 1956
load_sheets "./Data_Raw/land/irrigation.xlsx" "`years'" "irrigation" "region" "year" "irrigation" 
save "./Data_Modified/irrigation.dta", replace

local main_types fertilizer_quantity fertilizer_value
local years 1950 1951 1952 1953 1954 1955 1956
load_sheets "./Data_Raw/land/fertilizer.xlsx" "`years'" "`main_types'" "region" "year" "fertilizer" 
save "./Data_Modified/fertilizer.dta", replace

local main_types total_cultivable_land	total_paddy_field double_cropping_field first_crop_field second_crop_field	dry_land
local years 1950 1951 1952 1953 1954 1955 1956
load_sheets "./Data_Raw/land/cultivated_area.xlsx" "`years'" "`main_types'" "region" "year" "fertilizer" 
save "./Data_Modified/cultivated_area.dta", replace


**** Merge
use "./Data_Modified/general_value.dta", clear
local crop_types rice soybean sweet_potato sugarcane tea cutton vegetable
foreach crop_type in `crop_types' {
	di "`crop_type'"
	merge 1:1 region year using "./Data_Modified/`crop_type'.dta", nogenerate  
} 
merge 1:1 region year using "./Data_Modified/tenant.dta", nogenerate    
merge 1:1 region year using "./Data_Modified/population.dta", nogenerate 
merge 1:1 region year using "./Data_Modified/irrigation.dta", nogenerate 
merge 1:1 region year using "./Data_Modified/fertilizer.dta", nogenerate 
merge 1:1 region year using "./Data_Modified/cultivated_area.dta", nogenerate 
merge m:1 region using "./Data_Modified/tenant_area_bought.dta", nogenerate  
bysort region (year): gen tenant_area_change_in_1953 = tenant_area[3] - tenant_area[4]
bysort region (year): gen share_tenant_area_change_in_1953 = tenant_area_change_in_1953 / tenant_area[3]
bysort region (year): gen portion_tenant_change_in_1953 = tenant_area_change_in_1953 / total_cultivable_land[3]
bysort region (year): gen paddy_area_change_in_1953 = paddy_field_tenant_area[3] - paddy_field_tenant_area[4]
bysort region (year): gen share_paddy_area_change_in_1953 = paddy_area_change_in_1953 / paddy_field_tenant_area[3]
replace share_paddy_area_change_in_1953  = 0 if share_paddy_area_change_in_1953 == . 
bysort region (year): gen portion_paddy_change_in_1953 = paddy_area_change_in_1953 / total_cultivable_land[3]
bysort region (year): gen dry_area_change_in_1953 = dry_land_tenant_area[3] - dry_land_tenant_area[4]
bysort region (year): gen share_dry_area_change_in_1953 = dry_area_change_in_1953 / dry_land_tenant_area[3]
bysort region (year): gen portion_dry_change_in_1953 = dry_area_change_in_1953 / total_cultivable_land[3]
gen after_reform = year >= 1953 
encode region, gen(region_code)
drop region
gen after_tenant_area_change = after_reform * tenant_area_change_in_1953
gen after_share_tenant_area_change = after_reform * share_tenant_area_change_in_1953
gen after_share_paddy_area_change = after_reform * share_paddy_area_change_in_1953
gen after_share_dry_area_change = after_reform * share_dry_area_change_in_1953
gen after_portion_tenant_area_change = after_reform * portion_tenant_change_in_1953
gen after_portion_paddy_area_change = after_reform * portion_paddy_change_in_1953
gen after_portion_dry_area_change = after_reform * portion_dry_change_in_1953
gen common_crop_ex_rice_value = common_crop_value - rice_total_value
gen fruit_value = horticultural_crop_value - vegetable_value



save "./Data_Modified/organized_data.dta", replace

/*
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





local years 1952 1953 1956
foreach year in `years' {
	preserve
	keep if year == `year'
	outreg2 using "./Output/summary_`year'.rtf", word replace sum(log)
	restore
} 

/*
foreach year in `years' {
	import excel "./Data_Raw/land/tenant_contract.xlsx", sheet("`year'") firstrow clear
	keep region tenant_number total_area paddy_field dry_land
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
*/

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



local crop_types total rice_total common_crop_ex_rice special_crop fruit vegetable livestock
foreach crop_type in `crop_types'{
	bysort year: egen total_`crop_type'_value = total(`crop_type'_value)
	bysort region_code (year): gen `crop_type'_price_index = 100 * (total_`crop_type'_value / total_`crop_type'_value[2]) / `crop_type'_index[2] 
	gen adjust_`crop_type'_value = `crop_type'_value / `crop_type'_price_index
}

import excel "./Data_Raw/general/production_index.xlsx", firstrow clear
rename rice rice_total_index
save "./Data_Modified/production_index.dta", replace
