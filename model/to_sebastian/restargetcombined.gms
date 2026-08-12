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


parameter
         RES_targets
         min_sh_renewables_temp
;

$set dataItem RES_targets
$call "csv2gdx ../data/%dataItem%.csv id=%dataItem% index=1..2 values=3 useHeader=y output=../data/%dataItem%.gdx "

$gdxin ../data/RES_targets.gdx
$load RES_targets

map_q(ra,c,q) = RES_targets(c,q);

min_sh_renewables_temp(q) = sum(c,RES_targets(c,q))/100;

$gdxin ../scenarios/restargetbase/results/restargetbaseQCP%suffix%.gdx
$load dem_res_base=DEM.L

$ifthen %newtarget%==0.8
min_sh_renewables("q1") = %newtarget%;
$else
min_sh_renewables("q1") = sum(q,min_sh_renewables_temp(q)*sum(c$(sum(tech$map_q(tech,c,q), 1) > 0),dem_res_base(c))) / sum(q,sum(c$(sum(tech$map_q(tech,c,q), 1) > 0), dem_res_base(c)));
$endif

map_q(ra,c,q) = no;
map_q(ra,c,"q1") = sum(q, RES_targets(c,q));


