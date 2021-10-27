export solve

"""
Build a JuMP model from `dict` instance and solve it
"""
function solve(dict; maxtime=120)
    name = dict["name"]
    N = dict["N"]
    P = dict["P"]
    TW = dict["TW"]
    M = dict["M"]
    @info("Solve $(name) by JuMP")

    # Consider N + 1 nodes
    # (1: start, 2,3,...,N: locations, N+1: goal=start)
    o, d = 1, N + 1
    nodes = collect(1:N+1)
    nodesP = collect(1:N)
    nodesN = collect(2:N)
    nodesD = collect(2:N+1)

    # augument data
    P[d] = P[o]
    TW[d] = TW[o]
    M = [M M[:, 1]; M[1:1, :] 0.0]

    # JuMP model
    model = Model(with_optimizer(Cbc.Optimizer, seconds=maxtime, log=0))

    @variable(model, x[i in nodesP, j in nodesD; i != j], Bin)
    @variable(model, y[i in nodes], Bin)
    @variable(model, T[i in nodes], Int)

    # たくさん価値を集める
    @objective(model, Max, sum(P[j] * y[j] for j in nodes))

    # 制約
    for n in nodesN
        @constraint(model, sum(x[n, m] for m in nodesD if n != m) == y[n])
    end
    for m in nodesN
        @constraint(model, sum(x[n, m] for n in nodesP if n != m) == y[m])
    end
    @constraint(model, sum(x[o, m] for m in nodesN) == 1)
    @constraint(model, sum(x[n, d] for n in nodesN) == 1)
    for n in nodesP, m in nodesD
        (n == m) && continue
        @constraint(model, x[(n, m)] >= 0)
        @constraint(model, T[n] + M[n, m] - T[m] <= max(TW[n][2] + M[n, m] - TW[m][1], 0) * (1 - x[(n, m)]))
    end
    for n in nodes
        @constraint(model, T[n] >= TW[n][1])
        @constraint(model, T[n] <= TW[n][2])
    end

    # 解く
    optimize!(model)

    # 解の出力
    obj_value = getobjectivevalue(model)

    # Y
    selected = [j for j in nodes if value(y[j]) > 0.05]

    # X
    xpos = Set{Tuple{Int, Int}}()
    for n in nodesP, m in nodesD
        (n == m) && continue
        v = value(x[n, m])
        (v < 0.05) && continue

        # edge
        if m != d
            # println("x[$n $m] $(v)")
            push!(xpos, (n, m))
        else
            # println("x[$n $o] $(v)")
            push!(xpos, (n, o))
        end
    end

    println(obj_value)
    println(xpos)
    println(selected)
end