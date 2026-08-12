$ontext
Runfile for European Electricity Market Model
$offtext

$setglobal basicparams "--baseData=data_EU_2017_15_tyndp --scenario=tyndp --DSM_switch=on"

$setglobal scenarioparams "--tyndpscenario=NationalTrends --climateyear=1984 --runyear=2040"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=NationalTrends --climateyear=1984 --runyear=2040 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%


