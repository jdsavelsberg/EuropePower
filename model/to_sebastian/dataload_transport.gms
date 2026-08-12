
*load data on passenger vehicles for electrification project

$set dataItem passengervehicles_Eurostat
$call "csv2gdx ../data/%dataItem%.csv id=%dataItem% index=1 values=2..lastCol useHeader=y output=../data/%dataItem%.gdx "

$set dataItem passengervehicles_fuel_prices
$call "csv2gdx ../data/%dataItem%.csv id=%dataItem% index=1 values=2..lastCol useHeader=y output=../data/%dataItem%.gdx "

Parameter
subsidy_ev_load                  subsidy on ev load [Euro per MWh]
min_sh_ev(c)                     target share of EV in vehicle stock [%]

passengervehicles_Eurostat
passengervehicles_fuel_prices


d_km0                            demand for transport per country [million km]

transport_stock                  number of passenger vehicles
transport_emissions              emissions by passenger vehicles [g per km]
transport_km_per_vehicle         km travelled by passenger vehicles [million km]

transport_carb_coef              emissions per car and year [t]

* Underlying assumptions:
* https://www.mckinsey.com/industries/automotive-and-assembly/our-insights/making-electric-vehicles-profitable#
* according to McKinsey, incremental cost of BEV compared to ICE is EUR 10,000 (USD 12,000)
* assume that we pay 1/10 every year
* include discounting?
transport_c_ev                   incremental cost of adding one more EV to the vehicle stock
                                 /1000/

* Underlying assumptions:
* https://ev-database.org/cheatsheet/energy-consumption-electric-car
transport_ev_load_input          consumption of electricity by EV [MWh per million km]
                                 / 195 /
*                                  228 for ID4

transport_ev_load                consumption of electricity by on EV per year [MWh]

* Underlying assumptions:
*https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle
* CO2 Emissions from a gallon of gasoline: 8,887 grams CO2/ gallon
* CO2 Emissions from a gallon of diesel: 10,180 grams CO2/ gallon
* CO2 Emissions from 1000L of gasoline: 2.34769701938374 g CO2/ l
* CO2 Emissions from 1000L of gasoline: 2.68927148163908 g CO2/ l

* we take the average from both, could add share of diesel and gasoline vehicles later on
transport_fuel_emissions         emissions from fuel [g per liter]
                                 / 2.518484251 /

transport_fuel_consumption       fuel consumption by ICE vehicles [litres per km]
transport_fuel_cost_per_vehicle  cost for fuel per ICE vehicle
;

$gdxin ../data/passengervehicles_Eurostat.gdx
$load passengervehicles_Eurostat

$gdxin ../data/passengervehicles_fuel_prices.gdx
$load passengervehicles_fuel_prices

c_transport(c) = no;
c_transport(c)$(emi0(c,"PrivateTransport") and passengervehicles_Eurostat(c,'gperkm')) = yes;

transport_stock(c_transport) = passengervehicles_Eurostat(c_transport,'cars_total');

transport_emissions(c_transport) = passengervehicles_Eurostat(c_transport,'gperkm');

transport_fuel_consumption(c_transport) = transport_emissions(c_transport) / (transport_fuel_emissions*1000);

*annual carbon emissions per vehicle
transport_carb_coef(c_transport,'ICE')
         = emi0(c_transport,"PrivateTransport") / transport_stock(c_transport)
;

*calculation of electricity demand by EV
transport_km_per_vehicle(c_transport)
         = transport_carb_coef(c_transport,'ICE') / transport_emissions(c_transport)
;

transport_ev_load(c_transport)
         = transport_km_per_vehicle(c_transport) * transport_ev_load_input
;

transport_fuel_cost_per_vehicle(c_transport)
                                  = transport_fuel_consumption(c_transport)
                                     * transport_km_per_vehicle(c_transport)
                                     * passengervehicles_fuel_prices(c_transport,"Mean") * 1000
                                     ;

subsidy_ev_load(c_transport) = %subsidy_ev_load%;
min_sh_ev(c_transport) = %evshare%;

c_mac0(c_transport,"PrivateTransport") = 0;


