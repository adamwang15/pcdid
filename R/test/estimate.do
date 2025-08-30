/* install pcdid stata module and perform estimation */
ssc install pcdid
help pcdid

use welfare,clear
xtset

/***************************************************************/
/* Table IV panel A */
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, alpha
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, tr(south==1) alpha
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, tr(south==0) alpha
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, tr(state=="WY") nw(3)

/***************************************************************/
/* Table IV panel B */
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, f(3)
gen T0p = (trend>T0+3)
pcdid lncase treated treated_post T0p afdcben unemp empratio mon_d*, f(4)

/***************************************************************/
/* plot Figure 1a as an example */
cap drop policy
gen policy = treated_post
pcdid lncase treated policy afdcben unemp empratio mon_d*, pd
pdd yhat
replace policy = 0
pdd yhat0
preserve
collapse lncase yhat yhat0, by(trend treated)
line lncase yhat yhat0 trend if treated==1 || line lncase trend if treated==0
restore

/***************************************************************/
/* plot Figure 1d as an example */
cap drop policy
gen policy = treated_post
pcdid lncase treated policy afdcben unemp empratio mon_d*, tr(state=="WY") nw(3) pd
pdd yhat
replace policy = 0
pdd yhat0
preserve
keep if state=="WY" | control==1
collapse lncase yhat yhat0, by(trend treated)
line lncase yhat yhat0 trend if treated==1 || line lncase trend if treated==0
restore

/***************************************************************/
/* plot factor proxy (Figure A3a) as an example */
pcdid lncase treated treated_post afdcben unemp empratio mon_d*, alpha
use fproxy,clear
gen time=_n
line fproxy1 fproxy2 time


/***************************************************************/
/* Table A8 panel A (first-differenced model) */
use welfare,clear
xtset
bysort statenum: gen dlncase = lncase[_n]- lncase[_n-1]
bysort statenum: gen dafdcben = afdcben[_n]- afdcben[_n-1]
bysort statenum: gen dunemp = unemp[_n]- unemp[_n-1]
bysort statenum: gen dempratio = empratio[_n]- empratio[_n-1]
replace trend = trend-1		/* FD model: adjust the time variable by 1 period */
keep if trend>0				/* FD model: delete initial obs */
keep if trend<=116
pcdid dlncase treated treated_post dafdcben dunemp dempratio mon_d*, alpha f(4)

/***************************************************************/
/* plot Figure A7 as an example */
cap drop policy
gen policy = treated_post
pcdid dlncase treated policy dafdcben dunemp dempratio mon_d*, f(4) pd
pdd yhat
replace policy = 0
pdd yhat0
preserve
collapse dlncase yhat yhat0, by(trend treated)
line dlncase yhat yhat0 trend if treated==1
restore

/***************************************************************/
/* plot factor proxy (Figure A8a) as an example */
use fproxy,clear
gen time=_n
line fproxy1 fproxy2 time
