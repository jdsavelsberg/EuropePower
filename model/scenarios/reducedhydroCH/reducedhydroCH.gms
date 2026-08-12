$ontext
reduced hydro inflows CH scenario
$offtext

*###############################################################################
*                             POLICY OPTIONS
*###############################################################################
penalty(c) = 10000;

* no investment in RES

cinv_0(r,c) = 0;

*avail("Reservoir",c,t) = 1;

inflow(s,'CH',t) = inflow(s,'CH',t)*0.9;

* Switch non-linear generation cost off by setting c_vom_1 to zero:
* what to do with slope of mariginal cost of conventionals?
*c_vom_1(p_all) = 0.01;

* switch off chp
*chp_dem(i,c,t) = 0;

*###############################################################################
*                             SET POLICIES
*###############################################################################
