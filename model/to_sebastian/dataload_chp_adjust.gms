* ensure hourly feasibility. In infeasible hours set demand to 50% for available capacity
chp_adjustments(i,c,t)$(chp_dem(i,c,t) > cap(i,c)*avail(i,c,t)) = chp_dem(i,c,t) - cap(i,c)*avail(i,c,t);
chp_dem(i,c,t)$(chp_adjustments(i,c,t) > 0) = cap(i,c)*avail(i,c,t)*0.5;

* for some countries, CHP demand is extremly high (above 50%): PL, CZ
* we restrict chp demand to be maximum 30 percent of total demand
* that affects chp demand in PL, CZ, and DK
parameter
    adjust_chp_scale(c)   scaling of chp demand to not exceed 30 percent of demand
;
adjust_chp_scale(c) = sum((i,t), chp_dem(i,c,t))/sum(t, demand(c,t));
adjust_chp_scale(c)$(adjust_chp_scale(c) > 0.3) = 0.3/adjust_chp_scale(c);
adjust_chp_scale(c)$(adjust_chp_scale(c) <= 0.3) = 1;
chp_dem(i,c,t) = chp_dem(i,c,t)*adjust_chp_scale(c);