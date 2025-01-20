/*******************************************************************************
File: 01_stata.do
Purpose: Stata codes to recreate Daron Acemoglu's famous Economic Growth Graphs 
Author: Bishmay Barik
*******************************************************************************/

clear all

macro drop all

* Creating a global macro to set the directory

global dir "/Users/bishmaybarik/Library/CloudStorage/OneDrive-ShivNadarInstitutionofEminence/acemoglu_growth"

* Locating the sub-paths

global data "$dir/01_data"
global latex "$dir/03_latex"

* Loading the dataset

use "$data/pwt1001.dta", clear
export delimited "$data/pwt1001.csv", replace

* Keeping only the relevant variables to work with

cap keep countrycode country currency_unit year rgdpe rgdpo pop emp rconna

* Keeping only the years which we will be using for analysis

keep if year == 1960 | year == 1980 | year == 2000 | year == 2010 | year == 2019

* Generating GDP per capita variable

gen gdp_per_capita = rgdpo / pop

* Trimming some GDP per capita levels to stay consistent

keep if gdp_per_capita < 50000

/* Figure 1.1: Estimates of the distribution of countries according to PPP-adjusted 
GDP per capita in 1960, 1980 and 2000. */

// Kernel density estimation for each year
twoway (kdensity gdp_per_capita if year == 1960, lcolor(blue)) ///
       (kdensity gdp_per_capita if year == 1980, lcolor(red)) ///
       (kdensity gdp_per_capita if year == 2000, lcolor(green)) ///
       (kdensity gdp_per_capita if year == 2010, lcolor(orange)) ///
       (kdensity gdp_per_capita if year == 2019, lcolor(purple)) ///
       , ///
       ytitle("Density of countries") xtitle("GDP per capita") ///
       legend(order(1 "1960" 2 "1980" 3 "2000" 4 "2010" 5 "2019")) ///
       xscale(range(0 50000))
	   
graph export "$latex/01_graphs/fig_1.png", replace
	   
/* Figure 1.2: Estimates of the distribution of countries according to
log GDP per capita (PPP-adjusted) in 1960, 1980 and 2000. */

* Generating the log version of per capita gdp

gen log_gdp_per_capita = ln(gdp_per_capita)

// Kernel density estimation for each year (log version)
twoway (kdensity log_gdp_per_capita if year == 1960, lcolor(blue)) ///
       (kdensity log_gdp_per_capita if year == 1980, lcolor(red)) ///
       (kdensity log_gdp_per_capita if year == 2000, lcolor(green)) ///
       (kdensity log_gdp_per_capita if year == 2010, lcolor(orange)) ///
       (kdensity log_gdp_per_capita if year == 2019, lcolor(purple)) ///
       , ///
       ytitle("Density of countries") xtitle("GDP per capita") ///
       legend(order(1 "1960" 2 "1980" 3 "2000" 4 "2010" 5 "2019")) ///
       xscale(range(7 11))

graph export "$latex/01_graphs/fig_2.png", replace

/* Figure 1.3: Estimates of the distribution of countries according to pop weighted
log GDP per capita (PPP-adjusted) in 1960, 1980 and 2000. */
	
/* Figure 1.4: Estimates of the distribution of countries according to
log GDP per worker (PPP-adjusted) in 1960, 1980 and 2000 */

* Calculating GDP per worker

gen gdp_per_worker = rgdpo/emp

* Calculating it's log form

gen log_gdp_per_worker = ln(gdp_per_worker)

// Kernel density estimation for each year (log version)
twoway (kdensity log_gdp_per_worker if year == 1960, lcolor(blue)) ///
       (kdensity log_gdp_per_worker if year == 1980, lcolor(red)) ///
       (kdensity log_gdp_per_worker if year == 2000, lcolor(green)) ///
       (kdensity log_gdp_per_worker if year == 2010, lcolor(orange)) ///
       (kdensity log_gdp_per_worker if year == 2019, lcolor(purple)) ///
       , ///
       ytitle("Density of countries") xtitle("GDP per capita") ///
       legend(order(1 "1960" 2 "1980" 3 "2000" 4 "2010" 5 "2019")) ///
       xscale(range(7 11))

graph export "$latex/01_graphs/fig_4.png", replace

/* Figure 1.5: Estimates of the distribution of countries according to
log GDP per worker (PPP-adjusted) in 1960, 1980 and 2000 */

* Filter and create graph for year 2000
preserve
keep if year == 2000
gen log_consumption_per_capita = ln(rconna/pop)
scatter log_consumption_per_capita log_gdp_per_capita, mlab(countrycode) mlabpos(0) ///
    msymbol(i) || lfit log_consumption_per_capita log_gdp_per_capita, ///
    ytitle("log consumption per capita 2000") xtitle("log GDP per capita 2000") ///
    legend(off) lcolor(red)
graph save graph_2000.gph, replace
restore

* Filter and create graph for year 2010
preserve
keep if year == 2010
gen log_consumption_per_capita = ln(rconna/pop)
scatter log_consumption_per_capita log_gdp_per_capita, mlab(countrycode) mlabpos(0) ///
    msymbol(i) || lfit log_consumption_per_capita log_gdp_per_capita, ///
    ytitle("log consumption per capita 2010") xtitle("log GDP per capita 2010") ///
    legend(off) lcolor(red)
graph save graph_2010.gph, replace
restore

* Filter and create graph for year 2019
preserve
keep if year == 2019
gen log_consumption_per_capita = ln(rconna/pop)
scatter log_consumption_per_capita log_gdp_per_capita, mlab(countrycode) mlabpos(0) ///
    msymbol(i) || lfit log_consumption_per_capita log_gdp_per_capita, ///
    ytitle("log consumption per capita 2019") xtitle("log GDP per capita 2019") ///
    legend(off) lcolor(red)
graph save graph_2019.gph, replace
restore

* Combine the graphs into a 2x1 panel
graph combine graph_2000.gph graph_2010.gph graph_2019.gph, rows(2)

* Save the combined graph as PNG
graph export "$latex/01_graphs/fig_1.5.png", as(png) replace
