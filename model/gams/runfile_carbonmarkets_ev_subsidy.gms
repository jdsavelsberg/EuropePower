$ontext
Runfile for European Electricity Market Model
$offtext

$setglobal basicparams "--modeltype=QCP --baseData=data_EU_2017_all --scenario=carbon --combined_reduction_target=0.55 --privatetransport=on --renewable_investment=yes --targetshareets1=0.4 --resshare_q1=0.1 --evshare=0"

$setglobal scenarioparams '--subsidy_ev_load=0.1'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.2'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.3'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.4'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.5'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.6'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.7'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.8'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=0.9'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--subsidy_ev_load=1'
$call =gams main.gms %basicparams% %scenarioparams%
