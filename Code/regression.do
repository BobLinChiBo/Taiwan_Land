use "./Data_Modified/organized_data.dta", clear
xtset region_code
label define years 1950 "1950" 1951 "1951" 1952 "1952" 1953 "1953" 1954 "1954" 1955 "1955" 1956 "1956" 
label values year years
fvset base 1952 year

preserve
drop if year == 1953 // Treatment year
drop if region_code == 9 // Penghu_prefecture
local crop_list rice_total sweet_potato soybean sugarcane tea cutton
foreach crop in `crop_list' {
*** Pool
	collect clear
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 1"]): ///
	xtreg `crop'_yield_per_ha after_reform after_share_tenant_area_change, fe robust
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 2"]): ///
	xtreg `crop'_yield_per_ha total_farmer_number after_reform after_share_tenant_area_change, fe robust
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 3"]): ///
	xtreg `crop'_yield_per_ha total_farmer_number irrigation after_reform after_share_tenant_area_change, fe robust
	collect layout (colname#result) (model)
	collect style showbase off
	collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
	collect style cell result[_r_se], sformat("(%s)")
	collect style cell cell_type[item column-header], halign(center)
	collect style header result, level(hide)
	collect style column, extraspace(1)
	collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
	collect layout (colname[after_share_tenant_area_change after_reform total_farmer_number irrigation]#result[_r_b _r_se] result[has_panel r2 N]) (model)
	collect style header result[has_panel r2 N], level(label)
	collect style header colname, level(label)
	collect style row stack, spacer delimiter(" x ")
	collect label levels colname ///
		after_share_tenant_area_change "After 1953 x Percentage Decrease in Tenant Area in 1953" ///
		total_farmer_number "Number of Farmers in the District" ///
		irrigation "Irrigated Area in the District" ///
		after_reform "After 1953 (Treatment Year)" ///
		, replace
	collect label levels result ///
		has_panel "Regional fixed effects" ///
		N "N" ///
		r2 "R2" ///
		, modify
	collect style cell result[N], nformat(%4.0f)
	collect export "./Output/`crop'_pool_result.xlsx", as(xlsx) replace
	
*** By Year
	collect clear
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 1"]): ///
	xtreg `crop'_yield_per_ha i.year##c.share_tenant_area_change_in_1953, fe robust
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 2"]): ///
	xtreg `crop'_yield_per_ha total_farmer_number i.year##c.share_tenant_area_change_in_1953, fe robust
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 3"]): ///
	xtreg `crop'_yield_per_ha total_farmer_number irrigation i.year##c.share_tenant_area_change_in_1953, fe robust

	collect layout (colname#result) (model)
	collect style showbase off
	collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
	collect style cell result[_r_se], sformat("(%s)")
	collect style cell cell_type[item column-header], halign(center)
	collect style header result, level(hide)
	collect style column, extraspace(1)
	collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
	collect layout (colname[after_reform total_farmer_number irrigation i.year#c.share_tenant_area_change_in_1953]#result[_r_b _r_se] result[has_panel has_year_fe r2 N]) (model)
	collect style header result[has_panel has_year_fe r2 N], level(label)
	collect style header colname, level(label)
	collect style row stack, spacer delimiter(" x ")
	collect label levels colname ///
		total_farmer_number "Number of Farmers in the District" ///
		irrigation "Irrigated Area in the District" ///
		share_tenant_area_change_in_1953 "Percentage Decrease in Tenant Area in 1953" ///
		, replace
	collect label levels result ///
		has_panel "Regional Fixed Effects" ///
		has_year_fe "Year Fixed Effects" ///
		N "N" ///
		r2 "R2" ///
		, modify
	collect style cell result[N], nformat(%4.0f)
	collect export "./Output/`crop'_year_result.xlsx", as(xlsx) replace
} 
restore

preserve
drop if year == 1953 // Treatment year
drop if region_code == 9 // Penghu_prefecture
*** Pool
	collect clear
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 1"]): ///
	xtreg sugarcane_yield_per_ha after_reform after_share_dry_area_change, fe robust
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 2"]): ///
	xtreg sugarcane_yield_per_ha total_farmer_number after_reform after_share_dry_area_change, fe robust
	collect _r_b _r_se has_panel="YES", tag(model["`crop' 3"]): ///
	xtreg sugarcane_yield_per_ha total_farmer_number irrigation after_reform after_share_dry_area_change, fe robust
	collect layout (colname#result) (model)
	collect style showbase off
	collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
	collect style cell result[_r_se], sformat("(%s)")
	collect style cell cell_type[item column-header], halign(center)
	collect style header result, level(hide)
	collect style column, extraspace(1)
	collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
	collect layout (colname[after_share_dry_area_change after_reform total_farmer_number irrigation]#result[_r_b _r_se] result[has_panel r2 N]) (model)
	collect style header result[has_panel r2 N], level(label)
	collect style header colname, level(label)
	collect style row stack, spacer delimiter(" x ")
	collect label levels colname ///
		after_share_dry_area_change "After 1953 x Percentage Decrease in Dry Tenant Area in 1953" ///
		total_farmer_number "Number of Farmers in the District" ///
		irrigation "Irrigated Area in the District" ///
		after_reform "After 1953 (Treatment Year)" ///
		, replace
	collect label levels result ///
		has_panel "Regional fixed effects" ///
		N "N" ///
		r2 "R2" ///
		, modify
	collect style cell result[N], nformat(%4.0f)
	collect export "./Output/sugarcane_pool_dry_result.xlsx", as(xlsx) replace
	
*** By Year
	collect clear
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 1"]): ///
	xtreg sugarcane_yield_per_ha i.year##c.share_dry_area_change_in_1953, fe robust
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 2"]): ///
	xtreg sugarcane_yield_per_ha total_farmer_number i.year##c.share_dry_area_change_in_1953, fe robust
	collect _r_b _r_se has_panel="YES" has_year_fe="YES", tag(model["`crop' (year) 3"]): ///
	xtreg sugarcane_yield_per_ha total_farmer_number irrigation i.year##c.share_dry_area_change_in_1953, fe robust

	collect layout (colname#result) (model)
	collect style showbase off
	collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
	collect style cell result[_r_se], sformat("(%s)")
	collect style cell cell_type[item column-header], halign(center)
	collect style header result, level(hide)
	collect style column, extraspace(1)
	collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
	collect layout (colname[after_reform total_farmer_number irrigation i.year#c.share_dry_area_change_in_1953]#result[_r_b _r_se] result[has_panel has_year_fe r2 N]) (model)
	collect style header result[has_panel has_year_fe r2 N], level(label)
	collect style header colname, level(label)
	collect style row stack, spacer delimiter(" x ")
	collect label levels colname ///
		total_farmer_number "Number of Farmers in the District" ///
		irrigation "Irrigated Area in the District" ///
		share_dry_area_change_in_1953 "Percentage Decrease in Dry Tenant Area in 1953" ///
		, replace
	collect label levels result ///
		has_panel "Regional Fixed Effects" ///
		has_year_fe "Year Fixed Effects" ///
		N "N" ///
		r2 "R2" ///
		, modify
	collect style cell result[N], nformat(%4.0f)
	collect export "./Output/sugarcane_year_dry_result.xlsx", as(xlsx) replace
restore







/*








cap program drop did_crops
program did_crops
	local crop_list `1' 
	local timing `2'
	local treatment `3'
	local type `4'
	di `crop_list'
end


xtreg rice_total_value rice_total_area_ha total_farmer_number irrigation  i.year##c.paddy_area_change_in_1953, fe robust
xtreg rice_total_value rice_total_area_ha total_farmer_number irrigation  i.year##c.portion_paddy_change_in_1953, fe robust
		xtreg `crop' `crop'_area_ha total_farmer_number irrigation i.year##c.share_paddy_area_change_in_1953, fe robust
local crop_types total_value rice_total_value common_crop_ex_rice_value special_crop_value horticultural_crop_value sericulture_value livestock_value
did_crops "`crop_types'" after_reform after_share_tenant_area_change
local crop_types total_value rice_total_value common_crop_ex_rice_value special_crop_value horticultural_crop_value sericulture_value livestock_value
did_crops "`crop_types'" after_reform after_share_paddy_area_change

scatter tenant_area_bought tenant_area_change_in_1953

gen rice_total_yield_per_ha = rice_total_yield_kg / rice_total_area_ha
gen sugarcane_yield_per_ha = sugarcane_yield_kg / sugarcane_area_ha


xtreg rice_total_yield_per_ha after_reform after_share_tenant_area_change, fe robust
xtreg rice_total_yield_per_ha total_farmer_number after_reform after_share_tenant_area_change, fe robust
xtreg rice_total_yield_per_ha total_farmer_number irrigation after_reform after_share_tenant_area_change, fe robust

xtreg rice_total_yield_per_ha i.year##c.share_tenant_area_change_in_1953, fe robust
xtreg rice_total_yield_per_ha total_farmer_number i.year##c.share_tenant_area_change_in_1953, fe robust
xtreg rice_total_yield_per_ha total_farmer_number irrigation i.year##c.share_tenant_area_change_in_1953, fe robust
	
xtreg sugarcane_yield_per_ha after_reform after_share_tenant_area_change, fe robust
xtreg sugarcane_yield_per_ha total_farmer_number after_reform after_share_tenant_area_change, fe robust
xtreg sugarcane_yield_per_ha total_farmer_number irrigation after_reform after_share_tenant_area_change, fe robust

xtreg sugarcane_yield_per_ha i.year##c.share_tenant_area_change_in_1953, fe robust
xtreg sugarcane_yield_per_ha total_farmer_number i.year##c.share_tenant_area_change_in_1953, fe robust
xtreg sugarcane_yield_per_ha total_farmer_number irrigation i.year##c.share_tenant_area_change_in_1953, fe robust
	
	

	
	
	
	xtreg rice_total_yield_per_ha total_farmer_number irrigation i.year##c.portion_paddy_change_in_1953, fe robust
	xtreg rice_total_yield_per_ha total_farmer_number irrigation i.year##c.portion_paddy_change_in_1953, fe robust
	
	
	xtreg rice_total_value rice_total_area_ha total_farmer_number irrigation  i.year##c.paddy_area_change, fe robust
	xtreg rice_total_yield_kg rice_total_area_ha total_farmer_number irrigation i.year##c.paddy_area_change, fe robust
	
	xtreg sugarcane_area_ha rice_second_area_ha total_farmer_number irrigation fertilizer_value  i.year, fe robust

local crop_list sugarcane
foreach crop in `crop_list' {
	xtreg `crop'_value rice_total_area_ha `crop'_area_ha total_farmer_number irrigation  i.year##c.share_dry_area_change_in_1953 i.year##c.share_paddy_area_change_in_1953, fe robust
	xtreg `crop'_yield_kg rice_total_area_ha `crop'_area_ha total_farmer_number irrigation i.year##c.share_dry_area_change_in_1953 i.year##c.share_paddy_area_change_in_1953, fe robust
}



local crop_list rice_total sugarcane 
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number irrigation after_reform after_share_paddy_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number irrigation after_reform after_share_paddy_area_change, fe robust
}


local crop_list rice_total 
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number irrigation fertilizer_value  after_reform after_share_paddy_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number irrigation fertilizer_value  after_reform after_share_paddy_area_change, fe robust
}

local crop_list rice_total 
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number irrigation fertilizer_value fertilizer_quantity after_reform after_share_paddy_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number irrigation fertilizer_value fertilizer_quantity after_reform after_share_paddy_area_change, fe robust
}

local crop_list sugarcane 
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha rice_total_area_ha total_farmer_number irrigation after_reform after_share_paddy_area_change after_share_dry_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha rice_total_area_ha total_farmer_number irrigation after_reform after_share_paddy_area_change after_share_dry_area_change, fe robust
}


local crop_list rice_total sugarcane tea 
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha fertilizer_quantity fertilizer_value total_farmer_number irrigation  i.year##c.tenant_area_change_in_1953, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha fertilizer_quantity fertilizer_value total_farmer_number irrigation i.year##c.tenant_area_change_in_1953, fe robust
}

local crop_list rice_total sweet_potato soybean sugarcane tea cutton
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number irrigation  after_reform after_share_tenant_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number irrigation after_reform after_share_tenant_area_change, fe robust
}

local crop_list rice_total sweet_potato soybean sugarcane tea cutton
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number after_reform after_share_tenant_area_change, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number after_reform after_share_tenant_area_change, fe robust
}

local crop_list rice_total sweet_potato soybean sugarcane tea cutton
foreach crop in `crop_list' {
	xtreg `crop'_value `crop'_area_ha total_farmer_number  i.year##c.share_paddy_area_change_in_1953, fe robust
	xtreg `crop'_yield_kg `crop'_area_ha total_farmer_number  i.year##c.share_paddy_area_change_in_1953, fe robust
}	
	
	xtreg ln_`crop'_yield `crop'_area_ha total_farmer_number i.year##c.share_tenant_area_change_in_1953, fe robust
	
preserve
keep if year == 1952 | year == 1953
xtreg rice_total_value after_reform after_share_tenant_area_change, fe robust
restore

local compare_years 1953 1954 1955 1956
collect clear
foreach crop_type in `crop_types' {
	*** Pool
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg `crop_type' after_reform after_share_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1952 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg `crop_type' after_reform after_share_tenant_area_change, fe robust
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
collect layout (colname[after_reform after_share_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Share_Value_Result.xlsx", as(xlsx) replace



local crop_types total rice_total common_crop_ex_rice special_crop fruit vegetable livestock
foreach crop_type in `crop_types'{
	bysort year: egen total_`crop_type'_value = total(`crop_type'_value)
	bysort region_code (year): gen `crop_type'_price_index = 100 * (total_`crop_type'_value / total_`crop_type'_value[2]) / `crop_type'_index[2] 
	gen adjust_`crop_type'_value = `crop_type'_value / `crop_type'_price_index
}

local crop_types adjust_total_value adjust_rice_total_value adjust_common_crop_ex_rice_value adjust_special_crop_value adjust_vegetable_value adjust_fruit_value adjust_livestock_value
local compare_years 1953 1954 1955 1956
collect clear
foreach crop_type in `crop_types' {
	*** Pool
	collect _r_b _r_se has_panel="YES", tag(model[adjust_`crop_type']): ///
		xtreg `crop_type' after_reform after_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1952 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[adjust_`crop_type' (`year')]): ///
			xtreg `crop_type' after_reform after_tenant_area_change, fe robust
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
collect layout (colname[after_reform after_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Adjust_Value_Result.xlsx", as(xlsx) replace




local crop_types total_value rice_total_value common_crop_ex_rice_value special_crop_value horticultural_crop_value sericulture_value livestock_value
local compare_years 1953 1954 1955 1956
collect clear
foreach crop_type in `crop_types' {
	gen ln_`crop_type' = log(`crop_type')
	*** Pool
	collect _r_b _r_se has_panel="YES", tag(model[ln_`crop_type']): ///
		xtreg ln_`crop_type' after_reform after_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1952 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[ln_`crop_type' (`year')]): ///
			xtreg ln_`crop_type' after_reform after_tenant_area_change, fe robust
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
collect layout (colname[after_reform after_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Ln_Value_Result.xlsx", as(xlsx) replace



*** Placebo Test
gen after_fake_reform_1952 = year >= 1952
gen after_fake_tenant_area_change = after_fake_reform_1952 * tenant_area_change
local crop_types total_value rice_total_value common_crop_ex_rice_value special_crop_value horticultural_crop_value sericulture_value livestock_value
local compare_years 1952 1953 1954 1955 1956
collect clear
foreach crop_type in `crop_types' {
	*** Pool
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg `crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1951 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg `crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
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
collect layout (colname[after_fake_reform_1952 after_fake_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Fake_Value_Result.xlsx", as(xlsx) replace



local crop_types total_value rice_total_value common_crop_ex_rice_value special_crop_value horticultural_crop_value sericulture_value livestock_value
local compare_years 1952 1953 1954 1955 1956
collect clear
foreach crop_type in `crop_types' {
	*** Pool
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg ln_`crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1951 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg ln_`crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
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
collect layout (colname[after_fake_reform_1952 after_fake_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Fake_Ln_Value_Result.xlsx", as(xlsx) replace




local compare_years 1953 1954 1955 1956
collect clear
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg rice_total_area_ha after_reform after_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		gen ln_rice_total_area_ha = log(rice_total_area_ha)
		keep if year == 1952 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg ln_rice_total_area_ha after_reform after_tenant_area_change, fe robust
		restore
	} 
collect layout (colname#result) (model)
collect style showbase off
collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
collect style cell result[_r_se], sformat("(%s)")
collect style cell cell_type[item column-header], halign(center)
collect style header result, level(hide)
collect style column, extraspace(1)
collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
collect layout (colname[after_reform after_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Rice_Result.xlsx", as(xlsx) replace


local compare_years 1953 1954 1955 1956
collect clear
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg rice_total_yield after_reform after_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		gen ln_rice_total_area_ha = log(rice_total_area_ha)
		keep if year == 1952 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg ln_rice_total_area_ha after_reform after_tenant_area_change, fe robust
		restore
	} 
collect layout (colname#result) (model)
collect style showbase off
collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
collect style cell result[_r_se], sformat("(%s)")
collect style cell cell_type[item column-header], halign(center)
collect style header result, level(hide)
collect style column, extraspace(1)
collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
collect layout (colname[after_reform after_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Rice_Result.xlsx", as(xlsx) replace



local compare_years 1953 1954 1955 1956
collect clear
	collect _r_b _r_se has_panel="YES", tag(model[`crop_type']): ///
		xtreg ln_`crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
	foreach year in `compare_years'{
		preserve
		keep if year == 1951 | year == `year'
		collect _r_b _r_se has_panel="YES", tag(model[`crop_type' (`year')]): ///
			xtreg ln_`crop_type' after_fake_reform_1952 after_fake_tenant_area_change, fe robust
		restore
	} 
collect layout (colname#result) (model)
collect style showbase off
collect style cell, border(right, pattern(nil)) //nformat(%5.2f) 
collect style cell result[_r_se], sformat("(%s)")
collect style cell cell_type[item column-header], halign(center)
collect style header result, level(hide)
collect style column, extraspace(1)
collect stars _r_p 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(_r_b) 
collect layout (colname[after_fake_reform_1952 after_fake_tenant_area_change]#result[_r_b _r_se] result[has_panel r2 N]) (model)
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
collect export "./Output/Fake_Ln_Value_Result.xlsx", as(xlsx) replace



/*





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