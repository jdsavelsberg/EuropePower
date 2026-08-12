Set
    i /gen1, gen2, gen3/
    t /hour1*hour24/
;

Parameters
    demand(t) /hour1 200, hour2 300, hour3 240, hour4 360, hour5 400, hour6 340,
              hour7 300, hour8 320, hour9 280, hour10 360, hour11 400, hour12 300,
              hour13 500, hour14 600, hour15 700, hour16 600, hour17 550, hour18 600,
              hour19 500, hour20 300, hour21 300, hour22 300, hour23 300, hour24 360/
    ev_load(t)
    max_capacity(i) /gen1 200, gen2 300, gen3 250/
    mc(i) /gen1 50, gen2 70, gen3 60/
;

ev_load(t) = demand(t)*0.1;

Variable
    total_cost
;

Positive Variables
    generation(i, t)
    SLACK(t)
;

Equations
    energy_balance(t)
    capacity_constraint(i,t)
*    load_shifting_constraint(i, j, k)
    cost_objective
;

cost_objective..
total_cost =e= sum((i,t), mc(i) * generation(i, t))
                 + sum(t, SLACK(t)*10000)
;

energy_balance(t)..
sum(i, generation(i,t)) + SLACK(t) =g= demand(t) + ev_load(t)
;

capacity_constraint(i,t)..
generation(i,t) =l= max_capacity(i)
;

*display max_capacity demand mc;
*$stop

*load_shifting_constraint(i, j, k).. dispatch(i, j) + shift_dispatch(i, k) =l= sum(m$(ord(m)-1)*2+1 <= ord(j) and ord(j) <= ord(m)*2, dispatch(i, m));

Model dispatch_model
         / energy_balance
         capacity_constraint
         cost_objective
         /;

solve dispatch_model minimizing total_cost using lp;
