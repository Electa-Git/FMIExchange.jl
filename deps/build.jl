using Base.Filesystem

const BUILDDIR = joinpath(@__DIR__, "build")
const FMUDIR = joinpath(@__DIR__, "fmu")

function _build_initialise()
    rm(BUILDDIR, force=true, recursive=true)
    mkdir(BUILDDIR)
    mkpath(FMUDIR)

    for (root, dirs, files) in walkdir(joinpath(@__DIR__, "src"))
        cd(root)
        for f in files
            if last(f, 4) == ".mos"
                cp("$root", "$BUILDDIR/$(basename(root))")
                break
            end
        end
    end
end

function _build_native()
    for (root, dirs, files) in walkdir(BUILDDIR)
        cd(root)
        for f in filter(==("buildFMU.mos"), files)
            run(`omc $f`)
        end
    end
end

function _build_move_fmus()
    for (root, dirs, files) in walkdir(BUILDDIR)
        for f in filter(endswith(".fmu"), files)
            mv(joinpath(root, f), joinpath(FMUDIR, basename(f)), force=true)
        end
    end
    @info "FMUs were moved to `deps/fmu`"
end

if !isempty(ARGS)
    build_type = first(ARGS)
    if build_type == "native"
        @assert !isnothing(Sys.which("omc")) "You are trying to build FMUs but `omc` is not in your PATH"
        _build_initialise()
        _build_native()
        _build_move_fmus()
    else
        @error "Unknown build type $build_type. Valid values are `native`"
    end
else
    @info "The build script of FMIExchange.jl was called without arguments so no FMUs were created. If you do not need to run the tests of FMIExchange.jl, you can safely ignore this message"
end
