export read_instance

"""
Returns a dictionary contains the infromation of the targeting instance.

- Number of nodes
- Time window/Price for each node
- Matrix of distance (cost matrix)
"""
function read_instance(path)
    result = Dict()
 
    @info("Read $path")
    open(path, "r") do f
        lines = [strip(line) for line in readlines(f)]
        N = parse(Int, lines[begin])
        dict_tw = Dict{Int, Tuple{Int, Int}}()
        dict_price = Dict{Int, Int}()
        node_count = 1
        for line in lines[2:2+N-1]
            line = strip(line)
            ab, p = split(line)
            p = parse(Int, p)
            a, b = parse.(Int, split(ab, ','))
            dict_tw[node_count] = (a, b)
            dict_price[node_count] = p
            node_count += 1
        end
        
        m = zeros(Float64, N, N)
        for (k, line) in enumerate(lines[2+N:end])
            m[k, :] = parse.(Float64, split(line))
        end

        # save
        result["name"] = splitext(basename(path))[1]
        result["N"] = N
        result["TW"] = dict_tw
        result["P"] = dict_price
        result["M"] = m
    end
    result
end