$ontext
carbon scenario
$offtext

*###############################################################################
*                             POLICY OPTIONS
*###############################################################################

penalty(c) = 10000;

* By default no ets system
$if %module_carbon%=="on" map_ets(sector,c,ets) = no;
$if %module_carbon%=="on" reduction_target(ets) = 0;


$gdxin ../scenarios/base/results/baseLP%suffix%.gdx
$loaddc baselineemissions = r_emissions
emi0(c,'Electricity') = sum(tech,baselineemissions(tech,c)) * 10**6;

map_ets(sector,c,ets) = no;

Set
combined_sector(sector)
;

combined_sector(sector) = yes;


Parameter
combined_emissions
combined_target
;
combined_emissions = sum(map_ets(combined_sector,c,ets), emi0(c,combined_sector));

combined_target = combined_emissions * %combined_reduction_target%;

reduction_target("ets1")$(sum(map_ets(combined_sector,c,"ets1"),1)>0) = combined_target * %targetshareets1% / sum(map_ets(combined_sector,c,"ets1"), emi0(c,combined_sector));
reduction_target("ets2")$(sum(map_ets(combined_sector,c,"ets2"),1)>0) = combined_target * (1-%targetshareets1%) / sum(map_ets(combined_sector,c,"ets2"), emi0(c,combined_sector));

p_carb(c)=0;


* investment in RES
$if not set renewable_investment $set renewable_investment yes

$if not set elastic_demand $set elastic_demand on
$if not set module_carbon $set module_carbon on
*$if not set map_q1_r_eu $set map_q1_r_eu 1

map_q(r,c,"q1") = 1;
min_sh_renewables("q1") = %resshare_q1%;

map_ets('CoalExtraction',c,'ets1') = yes;
map_ets('Electricity',c,'ets1') = yes;
map_ets('EnergieIntensive',c,'ets1') = yes;
map_ets('GasExtraction',c,'ets1') = yes;
map_ets('Refineries',c,'ets1') = yes;

map_ets('Agriculture',c,'ets2') = yes;
map_ets('IndustryServices',c,'ets2') = yes;
map_ets('PrivateHeat',c,'ets2') = yes;
map_ets('PrivateTransport',c,'ets2') = yes;
map_ets('Transport',c,'ets2') = yes;

Set
combined_sector(sector)
;

combined_sector(sector) = yes;


Parameter
combined_emissions
combined_target
;
combined_emissions = sum(map_ets(combined_sector,c,ets), emi0(c,combined_sector));

combined_target = combined_emissions * %combined_reduction_target%;

reduction_target("ets1")$(sum(map_ets(combined_sector,c,"ets1"),1)>0) = combined_target * %targetshareets1% / sum(map_ets(combined_sector,c,"ets1"), emi0(c,combined_sector));
reduction_target("ets2")$(sum(map_ets(combined_sector,c,"ets2"),1)>0) = combined_target * (1-%targetshareets1%) / sum(map_ets(combined_sector,c,"ets2"), emi0(c,combined_sector));

p_carb(c)=0;


