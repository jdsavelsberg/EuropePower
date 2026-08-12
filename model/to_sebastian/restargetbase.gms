$ontext
restargets scenario
$offtext

*###############################################################################
*                             POLICY OPTIONS
*###############################################################################

penalty(c) = 10000;

* ets targets and split
$setglobal target_ets1 0.51
$setglobal target_ets2 0.34

*asigning sectors to ets
Set
sector_ets1(sector)
/'CoalExtraction','Electricity','EnergieIntensive','GasExtraction','Refineries'/
sector_ets2(sector)
/'Agriculture', 'IndustryServices', 'PrivateHeat', 'PrivateTransport', 'Transport'/
;

*asigning sectors to ets
map_ets(sector,c,ets)=no;
map_ets(sector_ets1,eu,'ets1') = yes;
map_ets(sector_ets2,eu,'ets2') = yes;
map_ets(sector_ets1,'NO','ets1') = yes;
map_ets(sector_ets2,'NO','ets2') = yes;

p_carb(eu)=0;
p_carb('NO')=0;

$gdxin ../scenarios/base/results/baseLP.gdx
$loaddc baselineemissions = r_emissions
emi0(c,'Electricity') = sum(tech,baselineemissions(tech,c)) * 10**6;

reduction_target("ets1") = %target_ets1%;
reduction_target("ets2") = %target_ets2%;

min_sh_renewables(q) = 0;

