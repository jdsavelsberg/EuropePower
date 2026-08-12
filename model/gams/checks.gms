
* renewable target feasibility
parameter
check_res_target
check_res_potential
check_res_excess
;
check_res_target(q) = min_sh_renewables(q)*sum(c$(sum(tech$map_q(tech,c,q), 1) > 0),
                         sum(t, dur_d(t)*demand(c,t))

);

check_res_potential(q) = sum(map_q(r,c,q),pot_ren_mwh(r,c))
                         + sum(map_q(s,c,q), sum(t, s_level_init(s,c,t)$(ord(t) eq 1) + inflow(s,c,t)))
                         + sum(map_q("RunOfRiver",c,q), sum(t, cap("RunOfRiver",c) * avail("RunOfRiver",c,t)))
                         + sum(map_q("Biomass",c,q), sum(t, cap("Biomass",c) * avail("Biomass",c,t)))
;


check_res_excess(q) = 0.95*check_res_potential(q)-check_res_target(q);

abort$(sum(q$(check_res_excess(q)<0), 1)) 'Target in q set too high', check_res_excess;
