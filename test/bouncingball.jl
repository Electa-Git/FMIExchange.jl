@testset "BouncingBall" begin

    bbloc = joinpath(@__DIR__, "..", "deps", "BouncingBallReference.fmu")
    bbstart = 0.0
    bbstop = 3.0
    bbstart = 0.0
    bbstop = 10.0
    bbins = Symbol[]
    bbouts = Symbol[]
    bbstates = ["h", "v"]

    fmu = CachedFMU2(bbloc, bbstart, bbstop, bbins, bbouts, bbstates)
    model = CachedModel(fmu)
    cbs = get_callbacks(model, bbstart, bbstop)
    sol = solve(
        ODEProblem{true}(model, Float64[1.0, 0.0], (bbstart, bbstop), Float64[]),
        AutoTsit5(Rosenbrock23(autodiff = ADTypes.AutoFiniteDiff())),
        callback = CallbackSet(cbs...),
        saveat = 0.0:0.01:3.0,
        tstops = 0.0:0.01:3.0
    )

    # calculate the potential energy at the top of the bounce arc
    # use this to calculate the coefficient of restitution:
    # mgh(top) = Epot(top) = Ekin(bottom) = 1/2 m v(bottom)^2
    # The ball reinitializes v(after bounce) = e v(before bounce)
    # so e = v(after) / v(before)
    #      = sqrt(Ekin(bottom, after) / Ekin(bottom, before))
    #      = sqrt(Epot(top, after) / Epot(top, before))
    #      = sqrt(h(top, after) / h(top, before))
    function coefficient_of_restitution(h)
        topindices = findall(eachindex(h)[(begin + 1):(end - 1)]) do i
            h[i - 1] <= h[i] && h[i + 1] <= h[i]
        end
        map(filter(i -> h[topindices[i]] >= 0.01, eachindex(topindices)[begin:(end - 1)])) do i
            sqrt(h[topindices[i + 1]] / h[topindices[i]])
        end
    end

    # time series comparison is quite sensitive to small errors: a
    # small mistake in the event handling causes time series to drift
    # apart over time incurring large mse. Instead we test the
    # physical properties of the system.
    es = coefficient_of_restitution(Array(sol)[1, :])
    @test all(e -> (≈)(e, 0.7, atol = 1.0e-2), es)
    @test length(es) == 7
end
