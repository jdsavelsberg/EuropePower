$ontext
base scenario
$offtext

*###############################################################################
*                             REDEFINE PARAMETERS
*###############################################################################

$include dataload_tyndp_2020.gms

$if not set tyndpscenario $setglobal tyndpscenario "NationalTrends"
$if not set climateyear $setglobal climateyear "2007"
$if not set runyear $setglobal runyear "2040"

$if not set ntc_off $setglobal ntc_off

$if not set ntc_off_start $setglobal ntc_off_start t0001
$if not set ntc_off_end $setglobal ntc_off_end t1416

$if %baseData% == "data_EU_2017_15_tyndp" $set ntc_off_end t0012

Set t_ntc_off(t) /%ntc_off_start%*%ntc_off_end%/;

*set cost of lost load to 10 000 euro per MWh
penalty(c) = 10000;

* hourly profile renewables
renTotal(r,c)$gen_annual(c,r)
                 = sum(t, dur_d(t) * tyndp_renS("%climateyear%",c,r,t) * tyndp_gen_annual("%tyndpscenario%","%runyear%","%climateyear%",c,r));
betaRen(r,c,t)$renTotal(r,c)
                 = tyndp_renS("%climateyear%",c,r,t);

*resetting calibration factors for availabilities
avail('HardCoal','DE',t) = avail('HardCoal','DE',t) / 0.4;
avail('HardCoal','FR',t) = avail('HardCoal','FR',t) / 0.85;
avail('HardCoal','IT',t) = avail('HardCoal','IT',t) / 0.4;
avail('HardCoal','ES',t) = avail('HardCoal','ES',t) / 0.5;
avail('HardCoal','PL',t) = avail('HardCoal','PL',t) / 0.7;
*avail('Other','RO',t) = avail('Other','RO',t) / 0.5;

avail('Biomass',c,t) = 1;
avail('Other',c,t) = 1;

* hourly ror profiles
avail("RunOfRiver",c,t)$(tyndp_ror("%climateyear%",c,t))
                 = tyndp_ror("%climateyear%",c,t);

* NTC values
ntc(c,cc,t)      = tyndp_ntc("%tyndpscenario%","%runyear%","%climateyear%",c,cc);
$if %ntc_off% == "ntc_off" ntc(c,cc,t_ntc_off) = 0;
ntc('DE','LU',t) = 10000;
ntc('LU','DE',t) = 10000;

* conventional capacities
cap(i,c)         = tyndp_cap("%tyndpscenario%","%runyear%","%climateyear%",c,i);
cap('RunOfRiver',c)
                 = 1;

* dsm capacities
$if %DSM_switch%=="on" cap_dsm(c) = tyndp_cap_dsm("%tyndpscenario%","%runyear%","%climateyear%",c);

* Battery settings
cap('Battery',c) = tyndp_cap("%tyndpscenario%","%runyear%","%climateyear%",c,'Battery');
cap_P('Battery',c)
                 = cap('Battery',c);
cap_L('Battery',c)
                 = cap('Battery',c);
eta('Battery',c) = 0.8;

* hourly demand
demand(c,t)      = tyndp_demand("%tyndpscenario%","%runyear%",c,t);

* chp demand
*        annual demand: if not capacity set demand to zero
tyndp_chp("%tyndpscenario%","%runyear%","%climateyear%",c,i)$(not cap(i,c))
                 = 0;

*        hourly chp demand
chp_dem(i,c,t)   = tyndp_chp("%tyndpscenario%","%runyear%","%climateyear%",c,i) * heat_dem_up(t);

*        ensure hourly feasibility. In infeasible hours set demand to 50% for available capacity
chp_adjustments(i,c,t)$(chp_dem(i,c,t) > cap(i,c)*avail(i,c,t))
                 = chp_dem(i,c,t) - cap(i,c)*avail(i,c,t);
chp_dem(i,c,t)$(chp_adjustments(i,c,t) > 0)
                 = cap(i,c)*avail(i,c,t)*0.5;

* We set carbon prices to tyndp values
p_carb(c) = tyndp_co2price("%tyndpscenario%","%runyear%");

* And we fix hydro storage values for first hour to value from ntc on run
$if %ntc_off% == "ntc_off" S_LEV.fx(s,c,t)$(ord(t) eq 1) = tyndp_s_lev_ntc_on(s,c,t);
