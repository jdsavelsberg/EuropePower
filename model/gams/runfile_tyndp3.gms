$ontext
Runfile for European Electricity Market Model
$offtext

$setglobal basicparams "--baseData=data_EU_2017_all_tyndp --scenario=tyndp --DSM_switch=on"

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=2007 --runyear=2030"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=2007 --runyear=2040"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=2007 --runyear=2030 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=2007 --runyear=2040 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1982 --runyear=2030"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1982 --runyear=2040"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1982 --runyear=2030 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1982 --runyear=2040 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1984 --runyear=2030"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1984 --runyear=2040"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1984 --runyear=2030 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams "--tyndpscenario=DistributedEnergy --climateyear=1984 --runyear=2040 --ntc_off=ntc_off"
$call =gams main.gms %basicparams% %scenarioparams%
