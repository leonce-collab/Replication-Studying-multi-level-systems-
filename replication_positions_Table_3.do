
* Create year variable

gen year = substr(string(date), 1, 4)
gen yearn = real(year)
drop year
gen year = yearn 
drop yearn
order year, first

* Avoid duplicates by year for merging

* Sort data by year and party
bysort year party: gen dup = _N > 1

* Replace year with year + 1 for duplicates
replace year = year + 1 if dup == 1

* Drop the duplicate indicator variable
drop dup

* ### * Cultural Dimension * ### *

*##* Cultural dimension


		*rename per* p*

		/*
		per108 // EU +
		per110 // EU -
		per201 // Political Freedom
		per406 // protectionism +
		per503 // Equality/ Antidicrimination
		per601 // National way of life +
		per602 // National way of life -
		per603 // Traditional Morality +
		per604 // Traditional Morality -
		per605_2 //  Law and order -
		per607 // Multicultuturalism +
		per608 // Multiculturlaism -
		
		*/ // out per107  per109 per305 per407 per605 per706 per705   
		
		*A* - Aggregation of issue categories
		gen agg705=per705+per7061+per7062
		replace per705=agg705 

		
	
		*C* - Replication-code of every estimated party position with the authors selection of indicators

	* Treat Issues as pure positional
	
	*C.1* contruct count data of issue emphasis
		* Calculate counted emphasis variables (0 vs >0) of issues. This would be the most simple relation of emphasis to position
		foreach var in   per108 per110 per201  per406  per503 per601 per602 per603 per604  per605_2 per607 per608   { 
		sum `var'
		gen `var'c = 1 if `var'>0
		}
						
		foreach var in   per108c per110c per201c  per406c  per503c per601c per602c per603c per604c  per605_2c     {
		replace `var'=0 if `var'==.
		}
				
	*C.2* Create abs. saliency
		* Calculate "real" absolute values by multiplying with the total of coded sentences
		foreach var in   per108 per110 per201  per406  per503 per601 per602 per603 per604  per605_2 per607 per608   { 
		summarize `var'
		gen `var'_abs = (`var')*(total)/100
		}
		
		* add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in   per108_abs per110_abs per201_abs  per406_abs  per503_abs per601_abs per602_abs per603_abs per604_abs  per605_2_abs per607_abs per608_abs   { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
		
	*C.3* logarithm of the abs. issue saliency 
		foreach var in   per108_abs_1 per110_abs_1 per201_abs_1  per406_abs_1  per503_abs_1 per601_abs_1 per602_abs_1 per603_abs_1 per604_abs_1  per605_2_abs_1 per607_abs_1 per608_abs_1   { 
		summarize `var'
		gen `var'l = log(`var')
		}  
		
		
		drop *_1
		* logarithm of the document based issue salience 
		* add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in   per108 per110 per201  per406  per503 per601 per602 per603 per604  per605_2 per607 per608   { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
		
	*C.4* logarithm of ep issues rel. saliency (manifesto based)
		foreach var in   per108_1 per110_1 per201_1  per406_1  per503_1 per601_1 per602_1 per603_1 per604_1  per605_2_1 per607_1 per608_1   { 
		summarize `var'
		gen `var'l = log(`var')
		}    
		
		

		
	*C.5* Sum of dimension based salience
		egen rel_author=rowtotal(  per108 per110 per201  per406  per503 per601 per602 per603 per604  per605_2 per607 per608  ), missing
		
		* Dimension based salience
		foreach var in   per108 per110 per201  per406  per503 per601 per602 per603 per604  per605_2 per607 per608   {
		summarize `var'
		gen `var'rel_author = ((`var'/rel_author)*100)
		}
		 *add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in   per108rel_author per110rel_author per201rel_author  per406rel_author  per503rel_author per601rel_author per602rel_author per603rel_author per604rel_author  per605_2rel_author per607rel_author per608rel_author   { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
					
	*C.B.3* logarithm of the rel. issue saliency  (selection based)
		foreach var in   per108rel_author_1 per110rel_author_1 per201rel_author_1  per406rel_author_1  per503rel_author_1 per601rel_author_1 per602rel_author_1 per603rel_author_1 per604rel_author_1  per605_2rel_author_1 per607rel_author_1 per608rel_author_1   { 
		summarize `var'
		gen `var'l = log(`var')
		}  

		
		* Check distribution of issues
		
		
		hist per503rel_author_1l
		hist per201rel_author_1l
		hist per108rel_author_1l
		hist per406rel_author_1l
		hist per602rel_author_1l
		hist per604rel_author_1l
		
		* IRT Model *
		
		
		gsem (Cultural_Diversity -> per503rel_author_1l) (Cultural_Diversity -> per201rel_author_1l, ) ///
		(Cultural_Diversity -> per108rel_author_1l, ) (Cultural_Diversity -> per406rel_author_1l, ) (Cultural_Diversity -> per602rel_author_1l, ) ///
		(Cultural_Diversity -> per604rel_author_1l, ) (Cultural_Diversity -> per605_2rel_author_1l, ) (Cultural_Diversity -> per607rel_author_1l, )  ///
		(Cultural_Diversity -> per608rel_author_1l, )  (Cultural_Diversity -> per603rel_author_1l, ) ///
		(Cultural_Diversity -> per601rel_author_1l, )   (Cultural_Diversity -> per110rel_author_1l, ),    iterate(30) latent(Cultural_Diversity) 

		predict dc1_sem, latent(Cultural_Diversity)		

		rename  dc1_sem culture 
		
		
		gsem (Cultural_Diversity -> per503rel_author_1l, poisson) (Cultural_Diversity -> per201rel_author_1l, poisson) ///
		(Cultural_Diversity -> per108rel_author_1l, poisson) (Cultural_Diversity -> per406rel_author_1l, poisson) (Cultural_Diversity -> per602rel_author_1l, poisson) ///
		(Cultural_Diversity -> per604rel_author_1l, poisson) (Cultural_Diversity -> per605_2rel_author_1l, poisson) (Cultural_Diversity -> per607rel_author_1l, poisson)  ///
		(Cultural_Diversity -> per608rel_author_1l, poisson)  (Cultural_Diversity -> per603rel_author_1l, poisson) ///
		(Cultural_Diversity -> per601rel_author_1l, poisson)   (Cultural_Diversity -> per110rel_author_1l, poisson),  listwise  iterate(30) latent(Cultural_Diversity ) 
		
		predict dc_sem, latent(Cultural_Diversity)		

		rename dc_sem culture_p
		
		cor culture culture_p
		
		
		
		* ### * Economic Dimension * ### *
		
		
		
		rename per* p*
		
		gen agg401=p401+p4011+p4012+p4013+p4014
		gen agg412=p412+p4121+p4122
		gen agg413=p413+p4131+p4132+p4123+p4124
		gen agg503=p503
		gen agg505=p505+p5041+p5031
		gen agg507=p507+p5061
		*gen agg404=per404+per405
		
		replace p401=agg401
		replace p412=agg412
		replace p413=agg413
		replace p503=agg503
		replace p505=agg505
		replace p507=agg507 
		*replace per404=agg404
		
		

		* Selection p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701
	

		
		
	
*C* - Replication-code of every estimated party position with the authors selection of indicators

	* Treat Issues as pure positional
	
	*C.1* contruct count data of issue emphasis
		* Calculate counted emphasis variables (0 vs >0) of issues. This would be the most simple relation of emphasis to position
		foreach var in p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701 { 
		sum `var'
		gen `var'c = 1 if `var'>0
		}
						
		foreach var in p401c p414c p402c p403c p412c p413c p504c p415c p303c p505c p404c p409c p501c  p701c {
		replace `var'=0 if `var'==.
		}
				
	*C.2* Create abs. saliency
		* Calculate "real" absolute values by multiplying with the total of coded sentences
		foreach var in p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701 { 
		summarize `var'
		gen `var'_abs = (`var')*(total)/100
		}
		
		* add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in p401_abs p414_abs p402_abs p403_abs p412_abs p413_abs p504_abs p415_abs p303_abs p505_abs p404_abs p409_abs p501_abs  p701_abs { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
		
	*C.3* logarithm of the abs. issue saliency 
		foreach var in p401_abs_1 p414_abs_1 p402_abs_1 p403_abs_1 p412_abs_1 p413_abs_1 p504_abs_1 p415_abs_1 p303_abs_1 p505_abs_1 p404_abs_1 p409_abs_1 p501_abs_1  p701_abs_1 { 
		summarize `var'
		gen `var'l = log(`var')
		}  
		
		
		drop *_1
		* logarithm of the document based issue salience 
		* add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701 { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
		
	*C.4* logarithm of ep issues rel. saliency (manifesto based)
		foreach var in p401_1 p414_1 p402_1 p403_1 p412_1 p413_1 p504_1 p415_1 p303_1 p505_1 p404_1 p409_1 p501_1  p701_1 { 
		summarize `var'
		gen `var'l = log(`var')
		}    
		
		
	*C.5* Sum of dimension based salience
		drop rel_author
		egen rel_author=rowtotal(p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701), missing
		
		* Dimension based salience
		foreach var in p401 p414 p402 p403 p412 p413 p504 p415 p303 p505 p404 p409 p501  p701 {
		summarize `var'
		gen `var'rel_author = ((`var'/rel_author)*100)
		}
		 *add +1 to every issue for logarithmic transformations later (other authers use 0.5 which is not advisable here, due to the negative values of logaritmized values <1)
		foreach var in p401rel_author p414rel_author p402rel_author p403rel_author p412rel_author p413rel_author p504rel_author p415rel_author p303rel_author p505rel_author p404rel_author p409rel_author p501rel_author  p701rel_author { 
		summarize `var'
		gen `var'_1 = `var'+1
		}
					
	*C.B.3* logarithm of the rel. issue saliency  (selection based)
		foreach var in p401rel_author_1 p414rel_author_1 p402rel_author_1 p403rel_author_1 p412rel_author_1 p413rel_author_1 p504rel_author_1 p415rel_author_1 p303rel_author_1 p505rel_author_1 p404rel_author_1 p409rel_author_1 p501rel_author_1  p701rel_author_1 { 
		summarize `var'
		gen `var'l = log(`var')
		}  


		
						* Additive model with log. dimension based salience 
		sum p401rel_author_1l p414rel_author_1l p402rel_author_1l p403rel_author_1l p412rel_author_1l p413rel_author_1l p504rel_author_1l p415rel_author_1l p303rel_author_1l p505rel_author_1l p404rel_author_1l p409rel_author_1l p501rel_author_1l p503rel_author_1l p701rel_author_1l
		gsem (Market_Liberalism -> p401rel_author_1l) (Market_Liberalism -> p414rel_author_1l) (Market_Liberalism -> p402rel_author_1l) ///
		(Market_Liberalism -> p403rel_author_1l) (Market_Liberalism -> p412rel_author_1l) (Market_Liberalism -> p413rel_author_1l) ///
		(Market_Liberalism -> p504rel_author_1l) (Market_Liberalism -> p415rel_author_1l) (Market_Liberalism -> p303rel_author_1l) (Market_Liberalism -> p505rel_author_1l) ///
		(Market_Liberalism -> p404rel_author_1l) (Market_Liberalism -> p409rel_author_1l) (Market_Liberalism -> p501rel_author_1l) (Market_Liberalism -> p503rel_author_1l) ///
		(Market_Liberalism -> p701rel_author_1l),   iterate(30) latent(Market_Liberalism ) 
		predict de1_sem, latent(Market_Liberalism)		

		rename de1_sem market


		* Family Link Specification without coarsened values
		
		gsem (Market_Liberalism -> p401rel_author_1l@1, family(gaussian, lcensored(0)) link(identity)) (Market_Liberalism -> p414rel_author_1l) (Market_Liberalism -> p402rel_author_1l) ///
		(Market_Liberalism -> p403rel_author_1l) (Market_Liberalism -> p412rel_author_1l, poisson) (Market_Liberalism -> p413rel_author_1l, nbreg) ///
		(Market_Liberalism -> p504rel_author_1l) (Market_Liberalism -> p415rel_author_1l, nbreg) (Market_Liberalism -> p303rel_author_1l) (Market_Liberalism -> p505rel_author_1l, nbreg) ///
		(Market_Liberalism -> p404rel_author_1l, poisson) (Market_Liberalism -> p409rel_author_1l, nbreg) (Market_Liberalism -> p501rel_author_1l) ///
		(Market_Liberalism -> p503rel_author_1l) (Market_Liberalism -> p701rel_author_1l), vce(cluster country) listwise iterate(20) latent(Market_Liberalism)  
		*drop d1i_sem
		predict d1i_sem, latent(Market_Liberalism)	

		rename d1i_sem market_p
		
		cor market market_p


		
* ### * Validation




* Define custom function to find closest match
gen year_match = .
replace year_match = 1999 if year == 1995 | year  == 1996 | year == 1997 | year == 1998 | year == 1999 | year == 2000
replace year_match = 2002 if year == 2001 | year  == 2002 | year == 2003 | year == 2004 
replace year_match = 2006 if year == 2005 | year  == 2006 | year == 2007 | year == 2008 
replace year_match = 2010 if year == 2009 | year  == 2010 | year == 2011 | year == 2012
replace year_match = 2014 if year == 2013 | year  == 2014 | year == 2015 | year == 2016
replace year_match = 2019 if year == 2017 | year  == 2018 | year == 2019 | year == 2020 | year == 2021   

order country year year_match, first


merge m:m year_match party using C:/chess.dta

replace culture = culture*(-1) + 1
replace culture_p = culture_p*(-1) + 1

cor galtan culture culture_p 
cor lrecon market market_p 

drop lrroeth
gen lrroeth = culture + market

			foreach var in 	 culture culture_p market market_p markeco galtan lrecon lrgen rile lrroeth   {
	summarize `var'
	gen `var'stand = (`var'-r(min))/(r(max)-r(min))
	}

	sum culturestand marketstand markecostand galtanstand lreconstand lrgenstand rilestand lrroethstand


cor galtanstand culturestand culture_pstand
cor lreconstand marketstand market_pstand markecostand
cor lrgenstand lrroeth rilestand

cor galtanstand culturestand culture_pstand if year == year_match
cor lreconstand marketstand market_pstand markecostand if year == year_match
cor lrgenstand lrroeth rilestand if year == year_match


* ### * add Morgan survey data


merge m:m year party using C:/benchmark.dta
replace benchmark = benchmark / 10

sum benchmark
cor benchmark markeco marketstand lrroeth

drop benchecon
gen benchecon = benchmark
replace benchecon = lreconstand if benchecon == .
sum benchecon

drop benchlr
gen benchlr = benchmark
replace benchlr = galtanstand if benchlr == .
sum benchlr

cor galtanstand culturestand culture_pstand
cor lrecon  marketstand market_pstand markecostand
cor lrgen  lrroeth rilestand
