# ==========================================================================================
# checking with DANTZIG42 is a set of 42 cities, from TSPLIB. The minimal tour has length 699.
# https://people.sc.fsu.edu/~jburkardt/datasets/tsp/tsp.html
# ==========================================================================================
using CSV, DelimitedFiles
using Random, StatsBase, TravelingSalesmanHeuristics

include("./src/utils.jl")
include("./src/k_opt.jl")

distmat = readdlm(download("https://people.sc.fsu.edu/~jburkardt/datasets/tsp/dantzig42_d.txt"))
N = size(distmat)[1]

# starting from a random path
# ---------------------------
Random.seed!(3)
path = sample(1:N, N, replace=false)

# running k-opt with k=5
# ---------------------------
path3, cost3 = k_opt(distmat=distmat, path=path, k=5, nb_runs=5000)
# ([15, 16, 17, 18, 19, 20, 21, 22, 23, 24  …  5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 699.0)

# We find the optimal distance of 699 in about 10 seconds


