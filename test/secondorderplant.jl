@testset "Second Order Plant" begin 

    start = 0.0
    stop = 10.0

    # FMU
    loc = joinpath(@__DIR__, "..", "deps", "fmu", "SecondOrderPlant.fmu")
    ins = Symbol[:u]
    outs = Symbol[:y]
    states = ["x1", "x2"]
    parameters = Dict("x10" => 0.0, "x20" => 1.0)
    plantspec = FMUSpecification(ins, outs, states, loc, parameters)

    # Native
    L = [9.0, 16.0]
    state_estimator(u, p, t) = [0 1;0 -1] * u + [0, 1] * p[1] + L * (p[2] - u[1])
    state_output(dst, u, p, t) = copyto!(dst, u)
    s_ins = [:su, :sy]
    s_outs = [:sx1, :sx2]
    s_states = ["sx1", "sx2"]
    s_spec = ModelSpecification(s_ins, s_outs, s_states, state_estimator, state_output)

    ios, xs = address_map([plantspec, s_spec])

    icb = PeriodicCallback(stop/100.0) do integrator
        inp = sin(2π * integrator.t / stop)
        integrator.p[ios[:u]] = inp
        integrator.p[ios[:su]] = inp
    end

    model = create_model([plantspec,s_spec]; start=start, stop=stop)
    cbs = reduce(vcat, get_callbacks.(model, start, stop))
    push!(cbs, output_callback(model))
    push!(cbs, link_models(:y, :sy, ios))
    push!(cbs, icb)
    sol = solve(ODEProblem{false}(dynamics(model), Float64[0.0, 1.0, 0.0, 1.0], (start, stop), zeros(6)),
                AutoTsit5(Rosenbrock23(autodiff=false)), callback=CallbackSet(cbs...))

    tsteps = start:0.01:stop
    mse = sum(map(x->sum(abs2, x[1:2]-x[3:4]), sol.(tsteps))) / length(tsteps)
    @test mse < 1e-3
end
