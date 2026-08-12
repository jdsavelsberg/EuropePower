$ontext
Defines all variables, equations and models
$offtext

*############################################################
*                VARIABLE AND EQUATION DEFINITION
*############################################################
Free Variable
    COST                total system cost - objective LP
    CSURP               consumer surplus
;

Positive Variable
*   conventional and res generation
    GEN(i,c,t)          generation
    RESGEN(r,c)         generation from renewable sources
    CURT(r,c,t)         curtailment of renewable r  in region c in period t

*   storage plants
    S_LEV(s,c,t)        storage level
    S_GEN(s,c,t)        storage generation
    S_WIT(s,c,t)        storage withdrawal
    S_SPILL(s,c,t)      storage spilling (newly introduced)
    S_MAGIC(s,c,t)      magial storage water filling at high cost

*   other
    TRADE(c,cc,t)       trade from country c to cc
    DEM(c)              demand country c period t
    SLACK               feasibility slack variable
    SLACK2

*   dsm variables
    DSM_UP(c,t)          upwards demand side management [MWh]
    DSM_DN(c,t,tt)       downwards demand side management [MWh]
    DSM_UP_DEMAND(c,t)
    DSM_DN_DEMAND(c,t)

*   transport sector
    S_TRANSPORT(c,transport_tech)
    LOAD_TRANSPORT(c,t)

*   sectoral abatement
    ABATEMENT(c,sector)  Abatement per sector [t]
    NET_EMISSIONS(c,sector) Net emissions per sector [t]
;

equation
    obj_QCP             QCP objective definition - linear demand
    def_COST            LP objective definition and QCP total cost definition

*   market clearing
    mkt_G_LP             market clearing generation - exogenous demand version
    mkt_G_QCP            market clearing generation - endogenous demand version
    mkt_cap              maximum cpacity restriction
    mkt_ntc              restriction on net transfer capacity
    mkt_chp              market clearing for chp generation

*   storage facilities
    mkt_S_GEN            storage generation restriction
    mkt_S_WIT            storage withdrawal restriction
    mkt_S_LEV            storage level restriction
    lom_S_LEV            law of motion storage level

*   renewable
    res_Curt             restriction to ensure feasible curtailment
    res_pot_ren          restriction renewable potential

*   policy constraints
    res_quota            restriction for renewable quota system: absolute target
    res_quota_supply     restriction for renewable quota system: relative supply share

*   dsm
    dsm_loadshift
    dsm_shift_max
    dsm_upwards
    dsm_downwards
    dsm_shift_recovery

*   carbon market
    mkt_carbon
    def_netemissions
    def_abatement_ele
*   transport sector
    mkt_transport
    def_load_transport
    def_abatement_privatetransport
    def_ev_share
;

*############################################################
*                    EQUATION DECLARATIONS
*############################################################

*------------------------------------------------------------
*                      OBJECTIVES
*------------------------------------------------------------
* QCP objective: welfare
obj_QCP..
    CSURP                   =E=   + scale_obj* [
$if %elastic_demand%=="on"        sum(c, (  (DEM(c)/(2*dem_b(c))) -  dem_a(c)/dem_b(c))*DEM(c))
                                  - COST
                                  - 1/2 * sum((r,c), cinv_1(r,c)*( sqr(RESGEN(r,c) + renTotal(r,c)) - sqr(renTotal(r,c))) )
$if %module_carbon%=="on"         - sum((c,sector), sqr(ABATEMENT(c,sector)) * c_mac0(c,sector)/1e6)
                                   ]
;


* Total system cost (with quadratic total investment cost for QCP) / LP objective:
def_COST..
    COST                    =E= scale_obj*[
                                sum((t,i,c),
                                         dur_d(t)*GEN(i,c,t)*(1/eta(i,c))
                                         *sum(f$mapTF(i,f),
                                                 pf(f,c) + carb_coef(f)*p_carb(c)*(1-CCScapturerate(i))
                                         )
                                )
                                + sum((t,i,c),dur_d(t)*GEN(i,c,t)*c_vom(i,c))
                                + sum((c,t), dur_d(t)*penalty(c)*SLACK(c,t))
                                + sum((r,c,t), dur_d(t)*curtPenalty(c)*CURT(r,c,t))
                                + sum((r,c), cinv_0(r,c)*RESGEN(r,c))
$if %module_DSM% == "on"        + 0.5 * sum((c,t), (DSM_UP_DEMAND(c,t) + DSM_DN_DEMAND(c,t)))
$if %module_transport%=="on"    + sum(c_transport, S_TRANSPORT(c_transport,'EV') * transport_c_ev)
$if %module_transport%=="on"    + sum(c_transport, S_TRANSPORT(c_transport,'ICE') * transport_fuel_cost_per_vehicle(c_transport))
$if %module_transport%=="on"    - sum(c_transport, sum(t,LOAD_TRANSPORT(c_transport,t) * dur_d(t)) * subsidy_ev_load(c_transport))
                                ]
;

*------------------------------------------------------------
*@@                      MARKET CLEARING
*------------------------------------------------------------
* LP version:
mkt_G_LP(c,t)..
    sum(i, GEN(i,c,t))
    + sum(s, S_GEN(s,c,t) - S_WIT(s,c,t))
    + sum(cc, (1 - line_loss(cc,c))*TRADE(cc,c,t) - TRADE(c,cc,t))
    + SLACK(c,t)
    + sum(r, betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c))  - CURT(r,c,t))
                            =E=    demand(c,t)
$if %module_DSM% == "on"           + DSM_UP_DEMAND(c,t) - DSM_DN_DEMAND(c,t)
$if %module_transport% == "on"     + LOAD_TRANSPORT(c,t)
;

* QCP version: market clearing electricity
mkt_G_QCP(c,t)..
    sum(i, GEN(i,c,t))
    + sum(s, S_GEN(s,c,t) - S_WIT(s,c,t))
    + sum(cc, (1 - line_loss(cc,c))*TRADE(cc,c,t) - TRADE(c,cc,t))
    + SLACK(c,t)
    + sum(r, betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c)) - CURT(r,c,t))
                            =E=
$if %elastic_demand%=="on"         beta(c,t)*DEM(c)
$if %elastic_demand%=="off"        demand(c,t)
$if %module_DSM% == "on"           + DSM_UP_DEMAND(c,t) - DSM_DN_DEMAND(c,t)
$if %module_transport% == "on"     + LOAD_TRANSPORT(c,t)
;

* cross-border trade capacities
mkt_NTC(c,cc,t)..
    ntc(c,cc,t)             =G=   TRADE(c,cc,t)
;

*------------------------------------------------------------
*@@               RESTRICTIONS THERMAL PLANTS
*------------------------------------------------------------
* generation installed capacity
mkt_cap(i,c,t)$(avail(i,c,t)*cap(i,c))..
    cap(i,c)*avail(i,c,t)   =G=    GEN(i,c,t)
;

* chp constraint
mkt_chp(i,c,t)$chp_dem(i,c,t)..
    GEN(i,c,t)              =G=    chp_dem(i,c,t)
;

*------------------------------------------------------------
*@@               RESTRICTIONS STORAGE FACILITIES
*------------------------------------------------------------
* storage turbine capacity
mkt_S_GEN(s,c,t)$cap(s,c)..
    cap(s,c)                =G=   S_GEN(s,c,t)
;

* storage pump capacity
mkt_S_WIT(s,c,t)$cap_P(s,c)..
    cap_P(s,c)              =G=   S_WIT(s,c,t)
;

* storage level
mkt_S_LEV(s,c,t)$cap_L(s,c)..
    cap_L(s,c)              =G=   S_LEV(s,c,t)
;

* law of motion for storage
lom_S_LEV(s,c,t)..
    S_LEV(s,c,t--1) + S_WIT(s,c,t)*eta(s,c) - S_GEN(s,c,t)
*    + s_level_init(s,c,t)$(ord(t) eq 1)
    + inflow(s,c,t)
    - S_SPILL(s,c,t)
*    + S_MAGIC(s,c,t)

                            =E=   S_LEV(s,c,t)
;

*------------------------------------------------------------
*@@             RESTRICTIONS RENEWABLES
*------------------------------------------------------------
* Ensure curtailment to be less or equal renewable supply
res_Curt(r,c,t)..
    betaRen(r,c,t)*(renTotal(r,c) + RESGEN(r,c))
                            =G=   CURT(r,c,t)
;

res_pot_ren(r,c)..
    pot_ren_mwh(r,c)        =G=   renTotal(r,c) + RESGEN(r,c)
;

*------------------------------------------------------------
*@@            RES POLICY RELATED RESTRICTIONS
*------------------------------------------------------------
res_quota(q)$(ren_target(q) and sum(map_q(r,c,q), 1) > 0)..
     sum((r,c)$map_q(r,c,q),
         renTotal(r,c) + RESGEN(r,c) - sum(t,CURT(r,c,t)))
     + sum((i,c,t)$map_q(i,c,q), GEN(i,c,t))
     + sum((s,c,t)$map_q(s,c,q), S_GEN(s,c,t))
                            =G= ren_target(q)
;

res_quota_supply(q)$(min_sh_renewables(q) and sum(map_q(r,c,q), 1) > 0)..
     sum((r,c)$map_q(r,c,q),
         renTotal(r,c) + RESGEN(r,c) - sum(t, CURT(r,c,t)))
     + sum((i,c,t)$map_q(i,c,q), dur_d(t)*GEN(i,c,t))
     + sum((s,c,t)$map_q(s,c,q), dur_d(t)*S_GEN(s,c,t))
                            =G= min_sh_renewables(q)*
                                sum(c$(sum(tech$map_q(tech,c,q), 1) > 0),
$if %res_target_base%=="on"    dem_res_base(c)
$if %res_target_base%=="on" $goto skipowndemand
$if %elastic_demand%=="off"     sum(t, dur_d(t)*demand(c,t))
$if %elastic_demand%=="on"      DEM(c)
$label skipowndemand
* or share in national generation:
*                                    sum(r, renTotal(r,c) + RESGEN(r,c) - sum(t, CURT(r,c,t)))
*                                    + sum((i,t), dur_d(t)*GEN(i,c,t))
*                                    + sum((s,t), dur_d(t)*S_GEN(s,c,t))
                                )
;

*####################################################################
*@                      MODEL DEFINITIONS
*####################################################################
model cepeem_LP
    /
   def_COST
$if %module_carbon%=="on"    mkt_carbon
$if %module_carbon%=="on"    def_netemissions
$if %module_carbon%=="on"    def_abatement_ele
$if %module_transport%=="on" mkt_transport
$if %module_transport%=="on" def_load_transport
$if %module_transport%=="on" def_abatement_privatetransport
$if %module_transport%=="on" def_ev_share
   mkt_G_LP
   mkt_cap
   mkt_S_GEN
   mkt_S_WIT
   mkt_S_LEV
   lom_S_LEV
   mkt_NTC
   res_Curt
   res_quota
   res_quota_supply
   mkt_chp
$if %module_DSM% == "on"    dsm_loadshift
$if %module_DSM% == "on"    dsm_shift_max
$if %module_DSM% == "on"    dsm_upwards
$if %module_DSM% == "on"    dsm_downwards
$if %module_DSM% == "on"    dsm_shift_recovery
/;

model cepeem_QCP
    /
   obj_QCP
   def_COST
$if %module_carbon%=="on"    mkt_carbon
$if %module_carbon%=="on"    def_netemissions
$if %module_carbon%=="on"    def_abatement_ele
$if %module_transport%=="on" mkt_transport
$if %module_transport%=="on" def_load_transport
$if %module_transport%=="on" def_abatement_privatetransport
$if %module_transport%=="on" def_ev_share
   mkt_G_QCP
   mkt_cap
   mkt_S_GEN
   mkt_S_WIT
   mkt_S_LEV
   lom_S_LEV
   mkt_NTC
   res_Curt
   res_quota
   res_quota_supply
   mkt_chp
/;

cepeem_LP.optfile = 1 ;
cepeem_LP.holdfixed=1 ;
cepeem_QCP.optfile = 1 ;
cepeem_QCP.holdfixed=1 ;

option QCP=CPLEX;
option LP=CPLEX;

