$set nr_items 100
$set nr_regions 10

set
    i items
    /i1*i%nr_items%/
    r regions
    /i1*i%nr_regions%/
;

parameter
    test_scalar    a test scalar /1/
    one_dim(i)     one dimensional test
    two_dim(i,r)   two dimensional test
;

one_dim(i) = uniform(0,100);
two_dim(i,r) = uniform(0,100);

execute_unload "test.gdx";
    



    