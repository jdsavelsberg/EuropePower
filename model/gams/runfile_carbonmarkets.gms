$ontext
Runfile for European Electricity Market Model
$offtext

$setglobal basicparams "--modeltype=QCP --baseData=data_EU_2017_all --scenario=carbon --combined_reduction_target=0.55 --privatetransport=on --renewable_investment=yes --targetshareets1=0.4"

$setglobal scenarioparams '--resshare_q1=0 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.3 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.4 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.5 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.6 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.7 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.8 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0.9 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=1 --evshare=0'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.1'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.2'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.3'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.4'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.5'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.6'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.7'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.8'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=0.9'
$call =gams main.gms %basicparams% %scenarioparams%

$setglobal scenarioparams '--resshare_q1=0 --evshare=1'
$call =gams main.gms %basicparams% %scenarioparams%


