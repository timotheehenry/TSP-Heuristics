# TSP-Heuristics
Traveling Salesman Heuristics in Julia

The repository contains mostly an implementation of the k-opt function which can be used to solve TSPs (Traveling Salesman Problems).
A script performs a benchmark of our use of the k_opt against LKH, the best performing TSP solver.

Right now our heuristic is slow because of its simplistic approach, but the results show that, after a while, we come closer to LKH achieved distance.

The heuristic implemented at the moment:
- start with a random path, or nearest neighbour path
- loop and operate a k-optimization of the path, at k indexes in the path. The indexes are either (80% of the time) random, or (20% of the time) at chosen places where the distances from previous city are the highest. This last bit needs a lot of improvement. I am following ideas from the original LKH papers when time I have time available.

LKH papers used as inspiration:
- 1973, S. Lin & B. W. Kernighan, “An Effective Heuristic Algorithm for the Traveling-Salesman Problem”
- 1998, K. Helsgaun, "An Effective Implementation of the Lin-Kernighan Traveling Salesman Heuristic."


In the tables below:
- nn = nearest neigbour achieved distance (lower is better)
- us = achieved distance by our implementation
- lkh = achieved distance by the LKH package
- us_duration = time it took our implementation, in seconds
- lkh_duration = time it took the LKH package, in seconds
- gap: percentage gap between our distance and LKH distance


```
#####################
6_opt, nb_runs=5000
#####################
 Row │ seed   NB_CITIES  nn     us     lkh    us_duration  lkh_duration  gap     
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
─────┼───────────────────────────────────────────────────────────────────────────
   1 │     1         50    470    437    425        14.74          0.05     0.03
   2 │     2         50    466    445    428        15.28          0.03     0.04
   3 │     3         50    507    463    455        15.54          0.02     0.02
   4 │     1        100    754    713    683        28.97          0.18     0.04
   5 │     2        100    776    730    683        24.05          0.21     0.07
   6 │     3        100    763    693    662        19.74          0.07     0.05

```



