$ontext
Transport module for EU electricity dispatch model

$offtext


*------------------------------------------------------------
*@@                      Private Transport
*------------------------------------------------------------
mkt_transport(c)..
    sum(transport_tech, S_TRANSPORT(c, transport_tech))
            =G= transport_stock(c);

def_load_transport(c,t)..
    LOAD_TRANSPORT(c,t)
            =E= S_TRANSPORT(c,'EV') * transport_ev_load(c) * beta(c,t);

def_abatement_privatetransport(c,'PrivateTransport')..
    ABATEMENT(c,'PrivateTransport')
            =E= (S_TRANSPORT(c,'EV') * (transport_carb_coef(c,'ICE')))
;

def_ev_share..
    sum(c, S_TRANSPORT(c, 'EV'))
            =G= sum(c, min_sh_ev(c) * transport_stock(c));