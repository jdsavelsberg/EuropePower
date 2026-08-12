Parameter
    r_emissions_sectoral(sector,c)       report total emissions per year per country and sector [Mt CO2]
    r_emissions_reduction(sector,c)      report relative emission reduction per sector compared to base case [%]
    r_emissions_reduction_ets(ets)       report relative emission reduction per ets system compared to base case [%]
    r_emissions_reduction_total          report relative emission reduction for all ets systems compared to base case [%]
    r_abatement(sector,c)                report total abatement per year per country and sector [Mt CO2]
    r_abatement_sectoral(sector)         report total abatement per year and sector [Mt CO2]
    r_abatement_cost(sector,c)           report total abatement cost per year per country and sector [mio Eur]
    r_abatement_cost_avg(sector,c)       report average abatement cost per ton of co2 per year per country and sector [Eur per t]
    r_mac(c,sector)                      marginal abatement cost per country and sector [Eur per t]
    r_carbonprice(ets)                   Carbon price per trading system [Eur per t]
    r_carbonprice_country(sector,c)      Carbon price per country and sector [Eur per t]
    r_carbon_revenues(sector,c)          revenues from carbon allowances per country and sector [10**6 Eur]
    r_carbon_cost_allowance(ets,c)       cost for allowances per country and ets [10**6 Eur]
    sh_revenues(ets,c)                   revenue share of ets revenues
;


$set dataItem ets_revenueshare
$call "csv2gdx ../data/%dataItem%.csv id=%dataItem% index=1..2 values=3 useHeader=y output=../data/%dataItem%.gdx "

$gdxin ../data/ets_revenueshare.gdx
$load sh_revenues=ets_revenueshare

$ondotl
r_emissions_sectoral(sector,c) = NET_EMISSIONS(c,sector) + eps;

r_emissions_reduction(sector,c)$(sum(map_ets(sector,c,ets), 1) > 0 and emi0(c,sector)>0) = 1-(NET_EMISSIONS(c,sector)/emi0(c,sector)) + eps;

r_emissions_reduction_ets(ets)$(sum(map_ets(sector,c,ets), 1) > 0 and sum(map_ets(sector,c,ets),emi0(c,sector))>0) = 1 - sum(map_ets(sector,c,ets), NET_EMISSIONS(c,sector))/sum(map_ets(sector,c,ets), emi0(c,sector)) + eps;
r_emissions_reduction_total$(sum(map_ets(sector,c,ets), 1) > 0 and sum(map_ets(sector,c,ets),emi0(c,sector))>0) = 1 - sum(map_ets(sector,c,ets), NET_EMISSIONS(c,sector))/sum(map_ets(sector,c,ets), emi0(c,sector)) + eps;

r_abatement(sector,c) = ABATEMENT(c,sector) + eps;
r_abatement_sectoral(sector) = sum(c,ABATEMENT(c,sector)) + eps;

r_abatement_cost(sector,c) = (sqr(ABATEMENT(c,sector)) * c_mac0(c,sector)/1e6)/1e6;
r_abatement_cost('Electricity',c) = 0;
r_abatement_cost('Electricity',c) = (sum(r, cinv_0(r,c)*RESGEN(r,c))
                                    + 1/2 * sum(r, cinv_1(r,c)*( sqr(RESGEN(r,c)
                                    + renTotal(r,c)) - sqr(renTotal(r,c))))
                                    ) / 1e6;

r_abatement_cost_avg(sector,c)$(ABATEMENT(c,sector)) = 1e6 * r_abatement_cost(sector,c) / ABATEMENT(c,sector);

r_mac(c,sector) = def_netemissions.M(c,sector);

r_carbonprice(ets) = - mkt_carbon.M(ets);

r_carbonprice_country(sector,c) = - sum(map_ets(sector,c,ets), -mkt_carbon.M(ets));

* ets based revenues and costs
r_carbon_revenues(sector,c) =  sum(map_ets(sector,c,ets), emi0(c,sector) * (1 - reduction_target(ets)) * (-mkt_carbon.M(ets)) * sh_revenues(ets,c))/1e6;

r_carbon_cost_allowance(ets,c) = sum(map_ets(sector,c,ets), NET_EMISSIONS(c,sector) * (-mkt_carbon.M(ets)))/1e6;

$offdotl
