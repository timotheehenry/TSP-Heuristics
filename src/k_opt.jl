using StatsBase

# ==========================
# function that returns the best places to cut a path for a k_opt
"""
N = 50
A = rand(1:N, N, N)
distmat = A + transpose(A)
path = sample(1:N, N, replace=false)
k = 3
findBestCuttingPoints(distmat, path, k)

"""
# ==========================
function findBestCuttingPoints(distmat, path, k)
  # careful: all element in idx to be returned must be >= 2
  
  N = length(path)
  
  # calculate distance between each points in path
  path_dist = [distmat[path[i], path[i+1]] for i in 3:(N-1)]
  
  # find the indexes for the top k distance
  dist_threshold = sort(path_dist, rev=true)[k]
  
  idx = findall(path_dist .>= dist_threshold)[1:k] .+ 3
  # println("idx: ", idx)
  return idx
end


# ==========================
# k_opt
# ==========================
"""
# Example of use

N = 20
A = rand(1:10, N, N)
distmat = A + transpose(A)
k = 3
path=[]
idx = [2;5;8]
path = sample(1:N, N, replace=false)
fullpathcost(distmat, path)

# one run
newpath = k_opt_one_run(distmat, path, k, idx)
fullpathcost(distmat, newpath)

# several runs
newpath = k_opt(; distmat, path, k, nb_runs = 100)
fullpathcost(distmat, newpath)

"""
# ==========================
# idx: gives the positions where we cut the path.
# we will get k positions, and we will re-arrange the (k-1) middle segments
# segments indexes are: [1:(idx[1]-1)], [idx[1]:(idx[2]-1)], etc
# ==========================
function k_opt_one_run(distmat, path, k, idx)
  # -------------------------------
  # error handling
  # -------------------------------
  if k < 3
    println("k_opt: k must be >= 3")
    return false
  end
  if length(idx) != k
    println("k_opt: an index if length k must be passed")
    return false
  end
  
  # -------------------------------
  # https://stackoverflow.com/questions/70366851/generate-all-permutations-of-the-combination-of-two-arrays#70367346
  # generate all possible tours
  # -------------------------------
  segments = collect(1:(k-1))
  directions = ["same","reversed"]
  x1 = permutations(segments);
  x2 = Iterators.product(fill(directions, k-1)...);
  all_tours = [vcat.(v...) for v in Iterators.product(x1, x2)];
  length(all_tours)
  
  # k = 3 => length(all_tours) = 8
  # k = 4 => length(all_tours) = 48
  # k = 5 => length(all_tours) = 384
  # k = 6 => length(all_tours) = 3840
  # k = 7 => length(all_tours) = 46080
  # k = 8 => length(all_tours) = 645120
  
  # -------------------------------
  # loop over each tour and calculate the alternative cost,
  # ie to connect the segments in the new order
  # -------------------------------
  NB_TOURS = length(all_tours)
  tour_cost = fill(0, NB_TOURS)
  
  
  # start_segment=path[1:(idx[1]-1)]; segment_1 = path[idx[1]:(idx[2]-1)]; segment_2 = path[idx[2]:(idx[3]-1)]; end_segment=path[idx[3]:end]
  # [start_segment; segment_1; segment_2; end_segment] == path
  # alternative cuts are:
  # [start_segment; reverse(segment_1); segment_2; end_segment]
  # [start_segment; reverse(segment_1); reverse(segment_2); end_segment]
  # etc
  
  # the following will not change for all alternative tours we will look at:
  start_segment = path[1:(idx[1]-1)]
  end_segment   = path[idx[k]:end]

  for i in 1:NB_TOURS
    tour = all_tours[i]
    
    segment_at_position = [tour[i][1] for i in 1:(k-1)]
    segment_direction = [tour[i][2] for i in 1:(k-1)]

    # ---------------------------
    # segments ends identification
    # ---------------------------
    # segments have the following starts and ends:
    # if not reversed
    # segment[j] start = idx[segment_at_position[j]]
    # segment[j] end   = idx[segment_at_position[j] + 1] - 1
    
    # if reversed
    # segment[j] start = idx[segment_at_position[j] + 1] - 1
    # segment[j] end   = idx[segment_at_position[j]]
    # ---------------------------
    
    tour_segment_starts = fill(0, k-1)
    tour_segment_ends   = fill(0, k-1)
    
    # j is the segment counter
    # but the order of segments is changed in tour, so we need to use segment_at_position[j]

    for j in 1:(k-1)
      if segment_direction[j]=="same"
        tour_segment_starts[j] = idx[segment_at_position[j]]
        tour_segment_ends[j]   = idx[segment_at_position[j] + 1] - 1
      end
      
      if segment_direction[j]=="reversed"
        tour_segment_starts[j] = idx[segment_at_position[j] + 1] - 1
        tour_segment_ends[j]   = idx[segment_at_position[j]]
      end
      
    end


    
    # ---------------------------
    # calculate sum of distances between each segments end at next segment start points
    # ---------------------------
    y = fill(0, k)

    # first point is fixed
    # points in the middle depend on the tour
    # last point is fixed

    y[1] = distmat[ path[idx[1]-1], path[tour_segment_starts[1]] ]

    for j in 2:(k-1)
      y[j] = distmat[ path[tour_segment_ends[j-1]], path[tour_segment_starts[j]] ]
    end

    y[k] = distmat[ path[tour_segment_ends[k-1]], path[idx[k]] ]
    
    tour_cost[i] = sum(y)
    
  end
  
  # -------------------------------
  # choose lowest distance tour from all_tours and return the new path (ie tour chosen)
  # -------------------------------
  bestCost, best_tour_idx = findmin(tour_cost)

  # -------------------------------
  # return best tour
  # -------------------------------
  if best_tour_idx == 1
    # no change
    improvement = 0
    return path, improvement
  end
  
  if best_tour_idx > 1
    # we re-run the same code this time with the chosen tour (i = best_tour_idx)
    i = best_tour_idx
    tour = all_tours[i]
    
    segment_at_position = [tour[i][1] for i in 1:(k-1)]
    segment_direction = [tour[i][2] for i in 1:(k-1)]
    
    # ---------------------------
    # segments ends identification
    # ---------------------------
    # segments have the following starts and ends:
    # if not reversed
    # segment[j] start = idx[segment_at_position[j]]
    # segment[j] end   = idx[segment_at_position[j] + 1] - 1
    
    # if reversed
    # segment[j] start = idx[segment_at_position[j] + 1] - 1
    # segment[j] end   = idx[segment_at_position[j]]
    # ---------------------------

    tour_segment_starts = fill(0, k-1)
    tour_segment_ends   = fill(0, k-1)
    
    # j is the segment counter
    # but the order of segments is changed in tour, so we need to use segment_at_position[j]

    for j in 1:(k-1)
      if segment_direction[j]=="same"
        tour_segment_starts[j] = idx[segment_at_position[j]]
        tour_segment_ends[j]   = idx[segment_at_position[j] + 1] - 1
      end
      
      if segment_direction[j]=="reversed"
        tour_segment_starts[j] = idx[segment_at_position[j] + 1] - 1
        tour_segment_ends[j]   = idx[segment_at_position[j]]
      end
      
    end
    
    # build newpath
    # ----------------------------
    newpath = start_segment
    
    for j in 1:(k-1)
      if segment_direction[j]=="same"
        segment_start = tour_segment_starts[j]
        segment_end   = tour_segment_ends[j]
        
        segment_j     = path[segment_start:segment_end]
      end
      
      if segment_direction[j]=="reversed"
        segment_start = tour_segment_starts[j]
        segment_end   = tour_segment_ends[j]
        
        segment_j     = reverse(path[segment_end:segment_start])
      end
      
      newpath = [newpath; segment_j]
    end
    
    newpath = [newpath; end_segment]
    
    # verify cost
    # fullpathcost(distmat, newpath)
    improvement_int = tour_cost[1] - tour_cost[best_tour_idx]
    
    return newpath, improvement_int
  end  

end

# ==========================
# k_opt
# look for optimization until none can be found
# ==========================
function k_opt(; distmat, path, k, nb_runs = 100)
  N = size(distmat)[1]
  
  improvement_bool = true
  while(improvement_bool==true)
    # start a batch of nb_runs k-opt
    # if no improvement after nb_runs k-opt we will stop and return the best path found
    
    improvement_bool = false
    
    for i in 1:nb_runs
    
      # circular shift of path to avoid having sub-optimal choice of start and end of the path
      path = circshift(path, sample(1:N))
      
      # create a random idx of k elements among 2:N, in order starting from the lowest; for example (2, 5, 18) if k=3
      if i % 5 == 0
        idx = findBestCuttingPoints(distmat, path, k)
      else
        idx = sample(2:N, k, replace=false)
        idx = sort(idx)
      end
      
      newpath, improvement_int = k_opt_one_run(distmat, path, k, idx)
      
      if improvement_int > 0
        # we verify the improvement
        curCost = fullpathcost(distmat, path)
        newCost = fullpathcost(distmat, newpath)
        
        if newCost < curCost
          improvement_bool = true
          println("path cost improved from ", curCost, " to ", newCost)
          path = newpath;
        end
        
        if newCost >= curCost
          println("there is faulty logic somewhere: we expected an improvement out of k_opt_one_run, but did not get the improvement")
        end
        
      end
      
    end
    
  end
  return path, fullpathcost(distmat, path)
  
end
