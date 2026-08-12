*If loaded, this module changes conventional capacities, NTCs and demand to TYNDP values

*###############################################################################
*                             REDEFINE PARAMETERS
*###############################################################################

$include dataload_tyndp_2020.gms

$if not set tyndpscenario $setglobal tyndpscenario "GlobalAmbition"
$if not set climateyear $setglobal climateyear "2007"
$if not set runyear $setglobal runyear "2030"

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
demand('FR','t0559') = demand('FR','t0559')*0.99;
demand('FR','t0560') = demand('FR','t0559')*0.99;

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

* And we fix hydro storage values for first hour to value from ntc on run
$if %ntc_off% == "ntc_off" S_LEV.fx(s,c,t)$(ord(t) eq 1) = tyndp_s_lev_ntc_on(s,c,t);
