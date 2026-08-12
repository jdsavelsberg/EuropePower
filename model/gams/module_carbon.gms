$ontext
Carbon module for EU electricity dispatch model
$offtext


*------------------------------------------------------------
*@@                      CARBON MARKET
*------------------------------------------------------------

mkt_carbon(ets)$(reduction_target(ets) and sum(map_ets(sector,c,ets), 1) > 0)..
         sum(map_ets(sector,c,ets), emi0(c,sector)) * (1 - reduction_target(ets))
                                 =G=  sum(map_ets(sector,c,ets), NET_EMISSIONS(c,sector))
;

def_netemissions(c,sector)..
         NET_EMISSIONS(c,sector)
                                 =E= emi0(c,sector) - ABATEMENT(c,sector)
;

def_abatement_ele(c,'Electricity')..
         ABATEMENT(c,'Electricity')
                                 =E= emi0(c,'Electricity')
                                     - sum((t,i),
                                         dur_d(t)*GEN(i,c,t)
                                         *(1/eta(i,c))
                                         * sum(f$mapTF(i,f), carb_coef(f))*(1-CCScapturerate(i))
                                     )
;
