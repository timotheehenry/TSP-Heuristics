# TSP-Heuristics
Traveling Salesman Heuristics in Julia

The repository contains mostly an implementation of the k-opt function which can be used to solve TSPs (Traveling Salesman Problems).
A script performs a benchmark of our use of the k_opt against LKH, the best performing TSP solver.

Right now our heuristic is slow because of its simplistic approach, but the results show that, after a while, we come closer to LKH achieved distance.

In the tables below:
- nn = nearest neigbour achieved distance (lower is better)
- us = achieved distance by our implementation
- lkh = achieved distance by the LKH package
- us_duration = time it took our implementation, in seconds
- lkh_duration = time it took the LKH package, in seconds


#####################
6_opt, nb_runs=5000
#####################
 Row │ seed   NB_CITIES  nn     us     lkh    us_duration  lkh_duration  gap     
     │ Int64  Int64      Int64  Int64  Int64  Float64      Float64       Float64 
─────┼───────────────────────────────────────────────────────────────────────────
   1 │     1         50    470    433    425       113.46          0.04     0.02
   2 │     2         50    466    439    428       109.08          0.03     0.03
   3 │     3         50    507    465    455       109.01          0.02     0.02
   4 │     1        100    754    707    683       222.09          0.17     0.04
   5 │     2        100    776    713    683       270.03          0.21     0.04
   6 │     3        100    763    713    662       172.6           0.08     0.08

#####################
5_opt, nb_runs=5000
#####################
 Row │ seed   NB_CITIES  nn     us     lkh    us_duration  lkh_duration  gap     
     │ Int64  Int64      Int64  Int64  Int64  Float64      Float64       Float64 
─────┼───────────────────────────────────────────────────────────────────────────
   1 │     1         50    470    437    425        14.74          0.05     0.03
   2 │     2         50    466    445    428        15.28          0.03     0.04
   3 │     3         50    507    463    455        15.54          0.02     0.02
   4 │     1        100    754    713    683        28.97          0.18     0.04
   5 │     2        100    776    730    683        24.05          0.21     0.07
   6 │     3        100    763    693    662        19.74          0.07     0.05




