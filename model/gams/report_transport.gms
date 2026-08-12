$ontext
Reporting of transport module parameters and derived quantities.

JSA 20.07.2021
$offtext

*#########################################################################
*@                   REPORT PARAMETERS
*#########################################################################
* this list includes LP and QCP report parameters so they do not have to be defined twice
parameter
* report parameters regarding generation
    r_transport_fuel_cost
    r_transport_fuel_cost_total
    r_cost_subsidy_ev_load
    r_cost_subsidy_ev_purchase
    r_cost_subsidy_ev_purchase_percar
;

$ondotl
*#########################################################################
*@                            Cost
*#########################################################################
r_transport_fuel_cost(c,'EV')
                         = sum(t, (r_price(c,t)-subsidy_ev_load(c))
                           * transport_ev_load(c)
                           * beta(c,t) * dur_d(t));

r_transport_fuel_cost(c,'ICE')
                         = transport_fuel_cost_per_vehicle(c);

r_transport_fuel_cost_total(c,transport_tech)
                         = r_transport_fuel_cost(c,transport_tech)
                           * S_TRANSPORT(c,transport_tech);

r_subsidy_ev(c) = def_ev_share.M;

*r_cost_subsidy_ev_load(c)
*                         = sum(t,
*                                 LOAD_TRANSPORT(c,t)
*                                 * dur_d(t)
*                           ) * subsidy_ev_load(c) / 10**6
*                           + eps;

*r_cost_subsidy_ev_purchase(c)
*                         = def_ev_share.M / 10**6 + eps;

*r_cost_subsidy_ev_purchase_percar(c)$(S_TRANSPORT(c,'EV'))
*                         = def_ev_share.M / S_TRANSPORT(c,'EV') + eps;

*r_abatement_cost('PrivateTransport',c)
*                         = 0;
*r_abatement_cost('PrivateTransport',c)
*                         = (sum(c_transport, S_TRANSPORT(c_transport,'EV') * transport_c_ev)
*                           + sum(t, (mkt_G_QCP.M(c,t)/dur_d(t)*(-1/scale_obj)) * LOAD_TRANSPORT(c,t))
*                           - sum(c_transport, S_TRANSPORT(c_transport,'EV') * transport_fuel_cost_per_vehicle(c_transport))
*                           )/1e6;
*
*r_abatement_cost_avg('PrivateTransport',c) = 0 ;
*r_abatement_cost_avg('PrivateTransport',c)$(S_Transport(c,'EV')>=1) = 1e6 * r_abatement_cost('PrivateTransport',c) / ABATEMENT(c,'PrivateTransport');


$offdotl
