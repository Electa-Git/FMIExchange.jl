@testset "Battery" begin

batstart = 0.0
batstop = 7200.0
control_period = 14.4

batloc = joinpath(@__DIR__, "..", "deps", "fmu", "MoPED.Electrical.Storage.StorageSubsystem.fmu")
batparameters = Dict([
    "BatCap" => 720000,
    "EffBatC" => 0.97,
    "EffBatD" => 0.97,
    "EffInvNominal" => 0.97,
    "PBatRated" => 1000.0,
    "PInvACRated" => 1000.0,
    "SoCInit" => 0.5,
    "SoCMax" => 0.95,
    "SoCMin" => 0.15,
    "V_nominal" => 230.0
])
batins = [:P_setpoint]
batouts = [:SoC, :P_ac]
batstates = ["bat.EneSoC"]

batspec = FMUSpecification(batins, batouts, batstates, batloc, batparameters)
batmodel = create_model(batspec) 

pn, un = address_map(batins, batouts, batstates, batmodel)

cbs = get_callbacks(batmodel, batstart, batstop)

bat_control_cb = PeriodicCallback(control_period) do integrator
    integrator.p[pn[:P_setpoint]] = 1200 * sin(2e-4 * 2π * integrator.t)
end

u0 = [0.5 * batparameters["BatCap"]]
p0 = [0.0, 0.5, 0.0]
tspan = (batstart, batstop)

sol = solve(ODEProblem(batmodel, u0, tspan, p0), callback=CallbackSet(cbs..., bat_control_cb), AutoTsit5(Rosenbrock23(autodiff=false)))

reference_results_loc = joinpath(@__DIR__, "..", "deps", "reference_results", "battery.csv")
ref = readdlm(reference_results_loc, ',', skipstart=1)
interp = interpolate((Interpolations.deduplicate_knots!(ref[:, 1]),), ref[:, 2], Gridded(Linear()))

tsteps = batstart:0.001:batstop

mse = sum(abs2, (first.(sol.(tsteps)) .- interp.(tsteps)) ./ first.(sol.(tsteps))) / length(tsteps)
@test mse < 1e-3

end
