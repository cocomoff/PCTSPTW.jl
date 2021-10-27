# Prize-Collecting TSPTW using JuMP and Cbc

- solver and examples


## how to use

- after activate this repository, run the folowing script.

```julia
using Revise
using PCTSPTW

dict = read_instance("./data/Langevin_Instances_new/N20ft204.dat")

# max collected prizes
solve(dict)

# min sum of travel time - coeff (e.g., 100) * collected prizes
solve(dict, withcost=true, penalty_coeff=-100)
```


# References

- instance files are from: https://github.com/pigna90/PCTSPTW