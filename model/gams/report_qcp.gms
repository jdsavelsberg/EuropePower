$ontext
Reporting of QCP specific model parameters and derived quantities.

JSA 14.10.2020
$offtext

*#########################################################################
*                   REPORT PARAMETERS
*#########################################################################
*parameter definitions in report_base

*#########################################################################
*                                Model status
*#########################################################################
r_modelstatistics('solvestat') = cepeem_QCP.solvestat;
r_modelstatistics('modelstat') = cepeem_QCP.modelstat;
*r_modelstatistics('SolverTime') = cepeem_LP.SolverTime;
r_modelstatistics('objval') = cepeem_QCP.objval;

$ondotl


*#########################################################################
*                                Prices QCP
*#########################################################################
* hourly electricity prices
r_price(c,t) = mkt_G_QCP.M(c,t)/dur_d(t)*(-1/scale_obj);

* yearly average electricity price
r_price_avg(c) = sum(t,
$if %elastic_demand%=="on"  beta(c,t) * DEM(c) * r_price(c,t) * dur_d(t)) / (sum(t, beta(c,t) * DEM(c) * dur_d(t))
$if %elastic_demand%=="off" demand(c,t) * r_price(c,t) * dur_d(t)) / (sum(t, demand(c,t) * dur_d(t))
);

* alternative calculation for yearly average electricity price
$if %elastic_demand%=="on" r_price_avgII(c) = (DEM(c) - dem_a(c))/(dem_b(c));

* daily average electricity price
$if %elastic_demand%=="on" rd_price_avg(c,d) = sum(map_t_d(t,d), beta(c,t)*DEM(c) * mkt_G_QCP.M(c,t) / dur_d(t) *(-1/scale_obj))/(sum(map_t_d(t,d), beta(c,t)*DEM(c)));
$if %elastic_demand%=="off" rd_price_avg(c,d) = sum(map_t_d(t,d), demand(c,t) * mkt_G_QCP.M(c,t) / dur_d(t) *(-1/scale_obj))/(sum(map_t_d(t,d), demand(c,t)));

* total consumer cost per country
$if %elastic_demand%=="off" r_cost_consumer(c)         = sum(t, -mkt_G_QCP.M(c,t) * demand(c,t))/10**6;
$if %elastic_demand%=="on"  r_cost_consumer(c)         = sum(t, -mkt_G_QCP.M(c,t) *  beta(c,t) * DEM(c))/10**6;

* investment cost per country for renewable technologies
r_investment_cost(r,c)     = (cinv_0(r,c)*RESGEN(r,c)
                             + 1/2 * (cinv_1(r,c)*( sqr(RESGEN(r,c) + renTotal(r,c)) - sqr(renTotal(r,c))))
                             )/10**6 + eps;
* total cost per country
r_cost(c)                  = sum(i, r_cost_tech(i,c)) + sum(t, penalty(c) * SLACK(c,t) * dur_d(t))/10**6
                              + sum((r,t), curtPenalty(c) * CURT(r,c,t) * dur_d(t))/10**6
                              + sum(r, r_investment_cost(r,c))
$if %module_carbon%=="on"     + sum(sector, sqr(ABATEMENT(c,sector)) * c_mac0(c,sector)/1e6)/10**6
                              + eps;


*#########################################################################
*                               Demand QCP
*#########################################################################
* total yearly demand for each country
r_demand_total(c)   = (
$if %elastic_demand%=="on"  DEM(c)
$if %elastic_demand%=="off" sum(t, demand(c,t))
                         )/10**6;

* hourly demand for each country
r_demand(c,t)  =
$if %elastic_demand%=="on" beta(c,t) * DEM(c)
$if %elastic_demand%=="off" demand(c,t)
;
r_all("demand",c,t) = -r_demand(c,t);

* daily demand for each country
rd_demand(c,d)  = sum(map_t_d(t,d),
$if %elastic_demand%=="on" beta(c,t) * DEM(c)
$if %elastic_demand%=="off" demand(c,t)
);

*#########################################################################
*                          Transmission QCP specific
*#########################################################################

* hourly shadow price of net transfer capacity
r_ntc_price(c,cc,t) = mkt_ntc.M(c,cc,t) / dur_d(t) * (1/scale_obj);

* average shadow price of net transfer capacity (trade weighted)
r_ntc_price_avg(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t) * dur_d(t))/sum(t, TRADE(c,cc,t) * dur_d(t));
r_ntc_price_avgII(c,cc)$(sum(t, r_ntc_price(c,cc,t)) gt 0.0001) = sum(t, r_ntc_price(c,cc,t));

* income from renting out scarce net transfer capacity
r_congestionRent(c,cc) =  round(sum(t, TRADE(c,cc,t) * r_ntc_price(c,cc,t)  * dur_d(t)), 8);

* total yearly net export revenues (pexp*exp - pimp*imp) for region c net of line losses [EUR]
r_netTradeRevenue(c)        = sum((t,cc), (r_price(c,t) * TRADE(c,cc,t) - (1 - line_loss(cc,c)) * r_price(cc,t) * TRADE(cc,c,t)) * dur_d(t))/10**6;

* daily shadow price of net transfer capacity
rd_ntc_price(c,cc,d) = sum(map_t_d(t,d), mkt_ntc.M(c,cc,t)*(1/scale_obj)) / 24;

*#########################################################################
*                          Welfare QCP specific
*#########################################################################

* consumer surplus
$if %elastic_demand%=="on" r_cSurplus(c)  =  1/(2*dem_b(c)) * sqr(DEM(c)) - dem_a(c)/dem_b(c)*DEM(c) - r_price_avg(c)*DEM(c);

* producer surplus
r_pSurplus(c)  = sum{t,
*                   income
                    dur_d(t) * r_price(c,t) * (
                                     sum(i, GEN(i,c,t))
                                   + sum(s, S_GEN(s,c,t) - S_WIT(s,c,t))
                                   + sum(r, betaRen(r,c,t) * (renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t)) )
                   }/10**6
*                   Cost conventional fuel and startup
                    - sum(i, r_cost_tech(i,c))
*                   Investment cost RES
                    - sum(r, r_investment_cost(r,c))
;

* total surplus, sum of consumer surplus and producer surplus
$if %elastic_demand%=="on" r_surplus(c)   = (1/(2*dem_b(c)) * (DEM(c))**2 - dem_a(c)/dem_b(c) * DEM(c))/10**6;

* welfare
$if %elastic_demand%=="on" r_welfare(c)   = r_surplus(c) - r_cost(c);

*#########################################################################
*                     REPORT FOR CGE COUPLING
*#########################################################################
r_val_dem(c)  = sum(t, pRef(c,t)*r_demand(c,t)*dur_d(t))/10**6;

* OLD COMMENT: as we only pass change in trade balance to TD more, we pass values, i.e., use the actual price
* DONT GET IT NEED TO REVISE LINKING HERE
r_val_nettrade(c,cc) = sum(t, dur_d(t)*(r_price(cc,t)*TRADE.L(c,cc,t) -  r_price(c,t)*TRADE.L(cc,c,t)))/10**6;
r_val_trade(c,cc) = sum(t, dur_d(t)*r_price(cc,t)*TRADE.L(c,cc,t))/10**6;

$offdotl
