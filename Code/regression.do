use "./Data_Modified/organized_data.dta", clear
xtset region_code
collect clear

program define
if `1' == "crop"{
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
	} 
}
if `1' == "ln_crop"{
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
	} 
}
	
collect layout (colname#result) (model)
collect style showbase off
collect style cell, border(right, pattern(nil))
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
collect export "./Output/Result1_ln.docx", as(docx) replace
end

xtreg rice_yield after_reform tenant_area_change, fe robust
xtreg rice_yield_per_ha after_reform tenant_area_change, fe robust
xtreg rice_value after_reform tenant_area_change, fe robust
xtreg area after_reform tenant_area_change, fe robust

