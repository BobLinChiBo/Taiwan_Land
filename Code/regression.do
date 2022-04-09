use "./Data_Modified/organized_data.dta", clear
xtset region_code

cap program drop crops_reg
program define crops_reg
collect clear 
if "`1'" == "crop"{
	local crop_types common_crop_value special_crop_value horticultural_crop_value
	foreach crop_type in `crop_types' {
		*** Whole
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
			xtreg `crop_type' after_reform tenant_area_change, fe robust
		*** 1952 V.S. 1953
		preserve
		drop if year == 1956
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type'(1953)]): ///
			xtreg `crop_type' after_reform tenant_area_change, fe robust
		restore
		*** 1952 V.S. 1956
		preserve
		drop if year == 1953
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type'(1956)]): ///
			xtreg `crop_type' after_reform tenant_area_change, fe robust
		restore
	} 
}
if "`1'" == "ln_crop"{
	local crop_types common_crop_value special_crop_value horticultural_crop_value
	foreach crop_type in `crop_types' {
		*** Whole
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
			xtreg ln_`crop_type' after_reform tenant_area_change, fe robust
		*** 1952 V.S. 1953
		preserve
		drop if year == 1956
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type'(1953)]): ///
			xtreg ln_`crop_type' after_reform tenant_area_change, fe robust
		restore
		*** 1952 V.S. 1956
		preserve
		drop if year == 1953
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type'(1956)]): ///
			xtreg ln_`crop_type' after_reform tenant_area_change, fe robust
		restore
	} 
}
	
collect layout (colname#result) (model)
collect style showbase off
collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
collect style cell result[_r_se], sformat("(%s)")
collect style cell cell_type[item column-header], halign(center)
collect style header result, level(hide)
collect style column, extraspace(1)
collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
collect layout (colname[after_reform tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
collect style header result[has_panel r2 N], level(label)
collect style header colname, level(value)
collect style row stack, spacer delimiter(" x ")
collect label levels result ///
    has_panel "Regional fixed effects" ///
    N "N" ///
    r2 "R2" ///
    , modify
collect style cell result[N], nformat(%5.0f)
collect preview
collect export "./Output/Result_`1'.xlsx", as(xlsx) replace
end

crops_reg "crop"
crops_reg "ln_crop"


*** rice yield
xtreg rice_yield after_reform tenant_area_change, fe robust
xtreg rice_yield_per_ha after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg rice_yield after_reform tenant_area_change, fe robust
xtreg rice_yield_per_ha after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg rice_yield after_reform tenant_area_change, fe robust
xtreg rice_yield_per_ha after_reform tenant_area_change, fe robust
restore

*** ln rice yield
xtreg ln_rice_yield after_reform tenant_area_change, fe robust
xtreg ln_rice_yield_per_ha after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg ln_rice_yield after_reform tenant_area_change, fe robust
xtreg ln_rice_yield_per_ha after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg ln_rice_yield after_reform tenant_area_change, fe robust
xtreg ln_rice_yield_per_ha after_reform tenant_area_change, fe robust
restore




*** rice value
xtreg adjust_rice_value after_reform tenant_area_change, fe robust
xtreg rice_value after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg adjust_rice_value after_reform tenant_area_change, fe robust
xtreg rice_value after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg adjust_rice_value after_reform tenant_area_change, fe robust
xtreg rice_value after_reform tenant_area_change, fe robust
restore




*** common_ex_rice value
xtreg adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg common_ex_rice_value after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg common_ex_rice_value after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg common_ex_rice_value after_reform tenant_area_change, fe robust
restore


*** ln common_ex_rice value
xtreg ln_adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg ln_common_ex_rice_value after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg ln_adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg ln_common_ex_rice_value after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg ln_adjust_common_ex_rice_value after_reform tenant_area_change, fe robust
xtreg ln_common_ex_rice_value after_reform tenant_area_change, fe robust
restore


*** special_crop value 
xtreg adjust_special_value after_reform tenant_area_change, fe robust
xtreg special_crop_value after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg adjust_special_value after_reform tenant_area_change, fe robust
xtreg special_crop_value after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg adjust_special_value after_reform tenant_area_change, fe robust
xtreg special_crop_value after_reform tenant_area_change, fe robust
restore

*** ln_special_crop value 
xtreg ln_adjust_special_value after_reform tenant_area_change, fe robust
xtreg ln_special_crop_value after_reform tenant_area_change, fe robust
preserve
drop if year == 1956
xtreg ln_adjust_special_value after_reform tenant_area_change, fe robust
xtreg ln_special_crop_value after_reform tenant_area_change, fe robust
restore
preserve
drop if year == 1953
xtreg ln_adjust_special_value after_reform tenant_area_change, fe robust
xtreg ln_special_crop_value after_reform tenant_area_change, fe robust
restore







xtreg adjust_horticultural_crop_value after_reform tenant_area_change, fe robust
xtreg horticultural_crop_value after_reform tenant_area_change, fe robust


xtreg common_ex_rice_value after_reform tenant_area_change, fe robust