using Combinatorics, LinearAlgebra

# ==========================
# convert asymmetric distance matrix to symmetric
# https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.946.6666&rep=rep1&type=pdf, page 4
"""
distmat = rand(1:10, 10, 10)

solve_tsp(distmat)
([1, 8, 9, 2, 6, 5, 4, 10, 3, 7], 17)

solve_tsp(distmat_assymetric_to_symmetric(distmat))
([1, 11, 8, 18, 9, 19, 2, 12, 6, 16, 5, 15, 4, 14, 10, 20, 3, 13, 7, 17], -9999983)
"""
# ==========================
function distmat_asymetric_to_symmetric(distmat)
  N = size(distmat)[1]
  MAX_VALUE = maximum(distmat)
  INFINITE_VALUE = 1e9

  if MAX_VALUE/INFINITE_VALUE * N*N > 1
    println("distmat_assymetric_to_symmetric error: the conversion of asymmetric to symmetric needs to be review: infinite value might be insufficient")
    return false
  end

  
  # double matrix size
  # -----------------------
  distmat_sym = fill(0, 2*N, 2*N);
  
  # each city is responsible for the distance *going to the city*
  # the dummy city is responsible for the distance *coming from the city*
  # -----------------------

  # 1:N for dummy cities, (N+1):2N for real cities
  # -----------------------

  # The original distances are used between the cities and the dummy cities
  # -----------------------
  # temp matrix for lower left corner
  temp = distmat[1:N,1:N]
  temp[diagind(temp)] .= -INFINITE_VALUE
  
  distmat_sym[(N+1):2N, 1:N] = temp[1:N,1:N]
  distmat_sym[1:N, (N+1):2N] = transpose(temp[1:N,1:N])
  
  distmat_sym[1:N,1:N] .= INFINITE_VALUE
  distmat_sym[(N+1):2N, (N+1):2N] .= INFINITE_VALUE
  distmat_sym[diagind(distmat_sym)] .= 0

  return distmat_sym
end


# ==========================
# fullpathcost
# returns the cost of path given a distance matrix, closing the loop with [end;start]
# ==========================
function fullpathcost(distmat::Matrix{T}, path::AbstractArray{S}, lb::Int = 1, ub::Int = length(path)) where {T<:Real, S<:Integer}
	cost = TravelingSalesmanHeuristics.pathcost(distmat, path) + distmat[path[end], path[1]]
	return cost
end
# ==========================

