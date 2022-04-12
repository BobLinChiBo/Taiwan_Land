import delimited "./Data_Raw/global_2020/gni_per_capita_usd_2020.csv", clear
save "./Data_Raw/global_2020/gni_per_capita_usd_2020.dta", replace
import delimited "./Data_Raw/global_2020/agriculture_percentage_2020.csv", clear
save "./Data_Raw/global_2020/agriculture_percentage_2020.dta", replace

use "./Data_Raw/global_2020/gni_per_capita_usd_2020.dta", clear
merge 1:1 countrycode using "./Data_Raw/global_2020/agriculture_percentage_2020.dta"

*** Reference  https://blogs.worldbank.org/opendata/new-world-bank-country-classifications-income-level-2020-2021
generate income_group = recode(gni_per_capita_usd, 1035, 4045, 12535, 99999) if gni_per_capita_usd != .
label define income_group 1035 "low_income" 4045 "lower-middle_income" 12535 "upper-middle_income" 99999 "high income"
label values income_group income_group
table income_group, statistic(mean agriculture_percentage)

gen income_group_string = ""
replace income_group_string = "low_income" if gni_per_capita_usd < 1036
replace income_group_string = "lower-middle_income" if gni_per_capita_usd >= 1036 & gni_per_capita_usd <= 4045
replace income_group_string = "upper-middle_income" if gni_per_capita_usd >= 4046 & gni_per_capita_usd <= 12535
replace income_group_string = "high income" if gni_per_capita_usd > 12535
encode income_group_string, gen(income_group)


tab mean agriculture_percentage by(low_income)
bysort low_income: egen mean_agriculture_percentage = mean(agriculture_percentage)
graph twoway (scatter agriculture_percentage gni_per_capita_usd if gni_per_capita_usd <= 4500) ///
			 (scatter agriculture_percentage gni_per_capita_usd if gni_per_capita_usd > 4500)