$ontext
Main file for European Electricity Market Model
$offtext

*############################################################
*@                OPTIONS
*############################################################
* You can either run the LP or QCP model
* If you want to run the QCP, you have to run the LP first
* in order to get prices. Also set base price create equal to
* yes
* the file with prices for calibration will be located in data
* directory

* set modeltype here, not in scenario file
$if not set modeltype $set modeltype LP

* switch for selecting if calibration factors should be used (yes / no)
$if not set calibrated $set calibrated no

* set scenario (e.g. base for base case)
$if not set scenario $set scenario base
*base

*Tyndp settings if used
$if not set tyndpscenario $setglobal tyndpscenario "GlobalAmbition"
$if not set climateyear $setglobal climateyear "1984"
$if not set runyear $setglobal runyear "2030"

* switch for (de)activating modules (off or on)
$if not set elastic_demand $set elastic_demand off
$if not set module_carbon $set module_carbon off
$if not set module_tyndp $set module_tyndp off

$if not set module_transport $set module_transport off
$if not set module_DSM $set module_DSM off

* switch for activating renewable investments (yes or no)
$if not set renewable_investment $set renewable_investment yes

* subsidy and res policy definition
$if not set map_q1_r_eu $set map_q1_r_eu 1
$if not set resshare_q1 $set resshare_q1 0

* ets policy definition
*$if not set combined_reduction_target $set combined_reduction_target 0.05
*$if not set targetshareets1 $set targetshareets1 0.4

* set runno here, if running qcp multiple times
$if not set runno $set runno

* datafile to use (here short version with 15 days)
$if not set baseData $setglobal baseData "data_EU_2024_all"
$if %baseData%=="data_EU_2017_15" $setglobal suffix "_15"
$if not set suffix $set suffix
$if %module_tyndp%=="on" $set suffix "_%tyndpscenario%_%runyear%_%climateyear%"

* datafile with scaled cost coefficients for investment cost
* missing file will skip cost scaling
$if not set costData $setglobal costData "cost_parameters"


*@@ ------------------- PATH SETTINGS -----------------------
$if not set datadir $setglobal datadir "..\data\"
$if not set scendir $setglobal scendir "..\scenarios\%scenario%\"
$if not set reportdir $setglobal reportdir "%scendir%\results\"

*@@ -------- FILE TO OWERWRITE REFERENCE PRICES -------------
* file to overwrite reference prices
* the baseprice gdx file has to
*    - to be provided with full path
*    - contain a parameter r_price
*      which is used to overwrite existing references prices
* Only set the option, if reference prices should be updated
* if not set, prices will not be updated
* for testing could, e.g., use:
$if %modeltype%=="QCP" $if not set baseprices $set baseprices ..\scenarios\base\results\baseLP

* flag to also adjust demand
* only active if baseprice is set
* by default deactivated, only use to calibrate qcp model
* to replicate to a given point, i.e., previous qcp run
$if not set adjustDemand $set adjustDemand no

*@@ ------------------- FILE SETTINGS ------------------------
$set scenfile "%scendir%%scenario%.gms"
$set reportfile "%reportdir%%scenario%%modeltype%%runno%%suffix%.gdx"
$if %scenario%=="carbon" $set reportfile "%reportdir%%scenario%%modeltype%%runno%%suffix%%suffix_scenario%.gdx"
*@@ ------------------ MODEL OPTIONS ------------------------
* scaling of objective function
$setglobal scale_obj 1

* assumption on line losses
$if not set linelosses $setglobal linelosses 0.001
*used to be 0.03

*@@ ------------------ OPTIONS CHECK ------------------------
$ifthen not %modeltype% == LP
$  if not %modeltype% == QCP $abort "#### INVALID MODELTYPE SPECIFIED; VALID ARE: LP OR QCP ####"
$endif

$ifthen %modeltype% == LP
$  if %module_carbon% == on $abort "#### Carbon module only works with QCP ####"
$endif

$ifthen not %scenario% == tyndp
$ifthen not %module_tyndp% == on
$  if %module_DSM% == on $abort "#### DSM module only works with tyndp scenario data ####"
$endif
$endif

$ifthen %module_transport% == "on"
$if %modeltype% == "LP" $abort "#### Transport module only works with QCP ####"
$if %module_carbon% == "off" $abort "#### Transport module only works with carbon_module ####"
$endif

*############################################################
*@                 DATA UPLOAD AND CALIBRATION
*############################################################
$include dataload.gms

$if %calibrated%=="yes" $include calibration.gms

$if %module_transport%=="on" $include dataload_transport.gms

$if %module_tyndp%=="on"         $include module_tyndp

$include policies.gms

*############################################################
*@                         MODELS
*############################################################
$include models_simple.gms
$if %module_carbon%=="on"        $include module_carbon
$if %module_transport%=="on"     $include module_transport
$if %module_DSM%=="on"           $include module_DSM

*############################################################
*@                  SCENARIO SETTINGS
*############################################################
* include scenario file
$include %scenfile%
$if %scenario%=="tyndp" $set reportfile "%reportdir%%scenario%%modeltype%%runno%%suffix%%tyndpscenario%%climateyear%%runyear%%ntc_off%.gdx"

*############################################################
*@                  Checks and adjustments
*############################################################

$include checks.gms

$include dataload_chp_adjust

*############################################################
*@                      MODEL SOLVE
*############################################################
$if defined solvestatsBU $exit
parameter
    solvestatsBU   report of solution statistics
;

$include init.gms

option resLim = 10000;
$iftheni %modelType% == LP
solve cepeem_LP  using LP minimizing COST;
* modeltype 0 as indicator for LP
solvestatsBU("modeltype") = 0;
$else
solve cepeem_QCP using QCP maximizing CSURP;
* modeltype 1 as indicator for QCP
solvestatsBU("modeltype") = 1;
$endif

* report solution statistics
solvestatsBU("solve") = cepeem_%modeltype%.solvestat;
solvestatsBU("model") = cepeem_%modeltype%.modelstat;



*############################################################
*@                    REPORTING AND EXPORTING
*############################################################
$include report_base.gms
$include report_%modeltype%.gms

$if %module_carbon%=="on" $include report_carbon.gms
$if %module_transport%=="on" $include report_transport.gms

*Dump everything to gdx
execute_unload "%reportfile%";
