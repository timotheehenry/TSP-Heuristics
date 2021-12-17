# comparing the use of our implementation of k-opt and a simple heuristic to LKH

using DataFrames, Random, StatsBase, LKH, TravelingSalesmanHeuristics

include("./utils.jl")
include("./k_opt.jl")

Random.seed!(3)

# generate a symmetric matrix
A = rand(1:10, 10, 10)
distmat = A + transpose(A)

path = sample(1:10, 10, replace=false)
fullpathcost(distmat, path)
path3, cost3 = k_opt(distmat=distmat, path=path, k=3, nb_runs=1000)

MAX_DISTANCE = 30
results = DataFrame(seed=[0], NB_CITIES=[0], nn=[0], us=[0], lkh=[0], us_duration = [0.], lkh_duration = [0.])

for NB_CITIES in [50, 100]
  for i in 1:3
    
    println("--------------------")
    
    Random.seed!(i)
    A = rand(1:MAX_DISTANCE, NB_CITIES, NB_CITIES)
    distmat = A + transpose(A)

    # Our algo:
    # --------------
    start_time = time()
    pathnn, costnn = nearest_neighbor(distmat)
    # nn is not necessarily a good starting choice
    
    path2, cost2 = two_opt(distmat, pathnn)
    pathus, costus = k_opt(distmat=distmat, path=path2[1:NB_CITIES], k=7, nb_runs=5000)
    println("final cost for us: ", costus)
    finish_time = time()
    us_duration = finish_time - start_time
    
    
    # LKH benchmark:
    # --------------
    start_time = time()
    pathlkh, costlkh = LKH.solve_tsp(distmat)
    finish_time = time()
    lkh_duration = finish_time - start_time
    println("LKH score: ", costlkh)
    
    push!(results, [i, NB_CITIES, costnn, costus, costlkh, us_duration, lkh_duration])
  end
end

results = results[2:end,:]
results.gap = round.(results.us ./ results.lkh, digits=2) .- 1
results.us_duration = round.(results.us_duration, digits=2)
results.lkh_duration = round.(results.lkh_duration, digits=2)
results


#####################
# 6_opt, nb_runs=5000
#####################

# Row │ seed   NB_CITIES  nn     us     lkh    us_duration  lkh_duration  gap     
#     │ Int64  Int64      Int64  Int64  Int64  Float64      Float64       Float64 
#─────┼───────────────────────────────────────────────────────────────────────────
#   1 │     1         50    470    433    425       113.46          0.04     0.02
#   2 │     2         50    466    439    428       109.08          0.03     0.03
#   3 │     3         50    507    465    455       109.01          0.02     0.02
#   4 │     1        100    754    707    683       222.09          0.17     0.04
#   5 │     2        100    776    713    683       270.03          0.21     0.04
#   6 │     3        100    763    713    662       172.6           0.08     0.08

#####################
# 5_opt, nb_runs=5000
#####################

# Row │ seed   NB_CITIES  nn     us     lkh    us_duration  lkh_duration  gap     
#     │ Int64  Int64      Int64  Int64  Int64  Float64      Float64       Float64 
#─────┼───────────────────────────────────────────────────────────────────────────
#   1 │     1         50    470    437    425        14.74          0.05     0.03
#   2 │     2         50    466    445    428        15.28          0.03     0.04
#   3 │     3         50    507    463    455        15.54          0.02     0.02
#   4 │     1        100    754    713    683        28.97          0.18     0.04
#   5 │     2        100    776    730    683        24.05          0.21     0.07
#   6 │     3        100    763    693    662        19.74          0.07     0.05

