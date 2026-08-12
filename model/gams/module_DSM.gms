$ontext
DSM module for EU electricity dispatch model
JSA 01/02/2021
$offtext

Parameter
         cap_dsm(c)      DSM capacity per country based on TYNDP data
         dsm_delay       DSM maximum delay time [h]
         dsm_eta         dsm efficiency loss
;

dsm_delay = 6;
dsm_eta = 1;

*based on Zerrahn and Schill:
*http://wolfpeterschill.de/wp-content/uploads/Zerrahn_Schill_2015_EGY.pdf
*also used in most recent version of DIETER

dsm_loadshift(c,t)..
         DSM_UP(c,t) * dsm_eta
                         =E= sum(tt$(
                                 ord(tt) ge ord(t) - dsm_delay and ord(tt) le ord(t) + dsm_delay
                                 ), DSM_DN(c,t,tt))
;

dsm_shift_max(c,t)..
         DSM_UP_DEMAND(c,t) + DSM_DN_DEMAND(c,t)
                         =L= cap_dsm(c)
;

dsm_upwards(c,t)..
         DSM_UP(c,t)     =E= DSM_UP_DEMAND(c,t)
;

dsm_downwards(c,t)..
         sum(tt$(
                 ord(tt) ge ord(t) - dsm_delay and ord(tt) le ord(t) + dsm_delay
                 ), DSM_DN(c,tt,t))
                         =E= DSM_DN_DEMAND(c,t)
;

dsm_shift_recovery(c,t)..
         sum(tt$(
                 ord(tt) ge ord(t) AND ord(tt) le ord(t) + dsm_delay
                 ), DSM_UP(c,tt))
                         =L= cap_dsm(c) * dsm_delay
;
