use "./Data_Modified/organized_data.dta", clear

*** Figure 1: Private Tenure Land Area Over Time
preserve
collapse total_tenant_area ,by(year)
graph twoway line total_tenant_area year, xlabel(#7) xtitle("Year") ylabel(,format(%10.0fc)) ytitle("Area of Private Tenure Land") graphregion(color(white))
graph export "./Output/Area_of_Private_Tenure_Land.jpg", replace
restore

*** Figure 2: Decrease in Area of Private Tenure Land during 1953
preserve
collapse tenant_area_change_in_1953 ,by(region)
graph hbar tenant_area_change_in_1953, over(region, sort(tenant_area_change_in_1953) descending )  ytitle("Decrease in Area of Private Tenure Land during 1953") graphregion(color(white))
graph export "./Output/Decrease_in_Area_of_Private_Tenure_Land_in_1953.jpg", replace
restore
ylabel(,format(%10.0fc)) ytitle("Change of Area of Private Tenure Land") yaxis(1) graphregion(color(white))