@testset "BouncingBall" begin

bbloc = joinpath(@__DIR__, "..", "deps", "fmu", "BouncingBall2D.fmu")
bbstart = 0.0
bbstop = 60.0
bbins = Symbol[]
bbouts = Symbol[]
bbstates = ["dx", "dy", "x", "y"]

fmu = CachedFMU2(bbloc, bbstart, bbstop, bbins, bbouts, bbstates, Dict("eps"=>1e-2))
model = CachedModel(fmu)
cbs = get_callbacks(model, bbstart, bbstop)
sol = solve(ODEProblem{true}(model, Float64[1.0, 0.0, 0.5, 1.0], (bbstart, bbstop), Float64[]), AutoTsit5(Rosenbrock23(autodiff=false)), callback=CallbackSet(cbs...), saveat=bbstart:0.01:bbstop)

reference_results_loc = joinpath(@__DIR__, "..", "deps", "reference_results", "bouncingball.csv")
ref = readdlm(reference_results_loc, ',', skipstart=1)
interp = interpolate.(((Interpolations.deduplicate_knots!(ref[:, 1]),),), eachcol(ref[:, 2:end]), (Gridded(Linear()),))
get_interp(t) = [i(t) for i in interp]

tsteps = bbstart:0.001:bbstop

mse = sum(sum.(abs2, sol.(tsteps) .- get_interp.(tsteps))) / length(tsteps)

@test mse < 1e-3

end
