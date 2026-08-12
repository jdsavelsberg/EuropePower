$ontext
Reporting of base calibration parameters and derived quantities for daily comparison

JSA 20.10.2020
$offtext

set
   t                             periods
   d                             days
   tfirst(t)                     first period
   c                             countries in simulation
   f                             fuels
   tech                          technologies
   i(tech)                       conventional technologies
   ra(tech)                      all renewable sources
   ro(ra)                        old = conventional renewable sources
   r(ra)                         new renewables
   s(tech)                       storage facilities

*  mappings
   mapTF(tech,f)                 mapping technology to fuel
   map_fuel_price_as(c,c,f)      mapping to fill fuel prices
   map_om_cost_as(c,c,tech)      mapping to fill O&M costs
   map_t_d(t,d)                  mapping of periods to days
;
alias(t,tt), (c, cc), (r,rr),  (tech, techtech), (i, ii), (ra, rra), (ro,rro);

parameter

r_generation(tech,c,t)           report hourly generation (accounted with duration)[MWh]
r_price(c,t)                     report hourly price [Euro per MWh]
TRADE(c,cc,t)                    report hourly trade [MWh]
r_demand(c,t)                    report hourly demand [MWh]

rd_generation(tech,c,d)          report daily generation (accounted with duration)[MWh]
rd_price_avg(c,d)                report daily price [Euro per MWh]
rd_trade(c,cc,d)                 report daily trade [MWh]
rd_demand(c,d)                   report daily demand [MWh]
;

* load data
$gdxin ..\data\data_EU_2017_all_calibration.gdx
$loaddc t d c tech i ra ro r s map_t_d
$loaddc r_generation r_price TRADE r_demand

* daily generation from conventionals, storage, and renewables
rd_generation(tech,c,d)  = sum(map_t_d(t,d), r_generation(tech,c,t)) + eps;

* daily trade from region c to region cc in TWh
rd_trade(c,cc,d)         = sum(map_t_d(t,d),  TRADE(c,cc,t))/10**6 + eps;

* daily average electricity price
rd_price_avg(c,d)$(sum(map_t_d(t,d), r_demand(c,t)) gt 0)
                         = sum(map_t_d(t,d), r_demand(c,t)*r_price(c,t))/sum(map_t_d(t,d), r_demand(c,t));

* daily demand
rd_demand(c,d)           = sum(map_t_d(t,d),  r_demand(c,t)) + eps;

execute_unload "..\data\calibration_EU_2017_all_daily.gdx ";
