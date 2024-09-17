# FMIExchange.jl
[![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://electa-git.github.io/FMIExchange.jl/dev/) 
[![Build Docs](https://github.com/Electa-Git/FMIExchange.jl/actions/workflows/Documentation.yaml/badge.svg)](https://github.com/Electa-Git/FMIExchange.jl/actions/workflows/Documentation.yaml)
[![Test](https://github.com/Electa-Git/FMIExchange.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/Electa-Git/FMIExchange.jl/actions/workflows/Test.yml)
## What is FMIExchange.jl?
FMIExchange.jl provides ways to easily load Model Exchange Functional Mock-up Units (FMUs) and simulate them using the [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/) package. 
This package cannot run simulations on its own, but merely provides tools to construct ODEFunctions and callbacks from FMUs. 
The user retains full control over the simulation with the powerful and familiar interface of [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/).

FMIExchange.jl allows to simulate multiple FMUs at the same time and even combine them with native Julia ODEs; this is the main use-case of this package.
FMIExchange.jl includes some functionality to automate the process of combining multiple models into one simulation: automatic addressing, human-readable address map generation and functions for connecting model inputs and outputs.

## What is FMIExchange.jl not?
FMIExchange.jl is not a package for simulating or manipulating FMUs: it doesn't include a simulator but merely provides convenience functions to allow simulating FMUs with the [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/) package.
[FMIImport.jl](https://github.com/ThummeTo/FMIImport.jl) and [FMICore.jl](https://github.com/ThummeTo/FMICore.jl) provide functionality for importing and manipulating FMUs. 
[FMI.jl](https://github.com/ThummeTo/FMI.jl) has built-in FMU simulation functionality, but this is limited to simulating a single FMU at a time and it is impossible to combine native ODEs with FMUs.

FMIExchange.jl is not a modelling package.
While it has some basic simulation composition functionality it lacks some crucial features such as algebraic loop resolution. 
Some packages that support this are [ModelingToolkit.jl](https://github.com/SciML/ModelingToolkit.jl) and [Causal.jl](https://github.com/zekeriyasari/Causal.jl).
Pull requests to make FMIExchange.jl compatible with these packages are welcome!

## Usage
Below example walks you through simulating an FMU using FMIExchange.jl and [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/). The example FMU is a bouncing ball in a 2D space.

Import packages. Define FMU file location, and simulation start and stop times.
```julia
using FMIExchange
using DifferentialEquations

bbloc = joinpath("deps", "fmu", "BouncingBall2D.fmu") # fmu file location
bbstart = 0.0 # simulation start
bbstop = 60.0 # simulation stop
```

Define the FMU inputs, outputs, states. 
This step ensures that correct references to the model variables are made in the simulation.
Optionally, the model parameters of the FMU can be changed.
```julia
bbins = String[] # FMU inputs (this FMU has none)
bbouts = String[] # FMU outputs (this FMU has none)
bbstates = ["dx", "dy", "x", "y"] # FMU states
bbparamters = Dict("eps"=>1e-2) # FMU parameters (optional)
```

Use the `CachedFMU2` function to load the FMU (the name `CachedFMU2` is to avoid naming conflicts with related packages).
We then wrap it in a `CachedModel` struct which will automatically preallocate caches for faster calls to the FMU.
```julia
fmu = CachedFMU2(bbloc, bbstart, bbstop, bbins, bbouts, bbstates, bbparameters)
model = CachedModel(fmu)
```

FMU events are handled through callbacks.
FMIExchange.jl can automatically generate the callbacks to handle these events using the `get_callbacks` function.
```julia
# For the bouncing ball, an event occurs whenever the ball hits a wall
cbs = get_callbacks(model, bbstart, bbstop)
```

Finally use the `CachedModel` and the callbacks as you would typically simulate a native Julia ODE.
```julia
# Solve using DifferentialEquations.jl
sol = solve(ODEProblem{true}(model, Float64[1.0, 0.0, 0.5, 1.0], (bbstart, bbstop), Float64[]), 
	    callback=CallbackSet(cbs...), saveat=bbstart:0.01:bbstop)
```
## Installation
FMIExchange.jl can be installed through the Julia package manager as below
```julia
using Pkg
Pkg.add("FMIExchange.jl")
```

### Generating Test FMUs
#### Locally
To run the tests you need to generate the FMUs. 
This requires OpenModelica to be installed and the compiler `omc` to be available in your `PATH` variable.
The [Modelica Standard Library](https://github.com/modelica/ModelicaStandardLibrary), [Buildings](https://github.com/lbl-srg/modelica-buildings), [IDEAS](https://github.com/open-ideas/IDEAS) and [MoPED](https://gitlab.kuleuven.be/positive-energy-districts/moped.git) libraries should be available in your Modelica path.

You can find your Modelica path by creating a `mos` script with the following contents
```
getModelicaPath()
```
and running it with `omc`.
On Linux, the result is `~/.openmodelica/libraries`.
#### Using Docker
Newer versions of OpenModelica have been found to generate faulty FMUs. 
The [Dockerfile](./deps/Dockerfile) contains a static OpenModelica version (built from source) which can be used to compile the FMUs in this repo.
```bash
# pull image from the github repository
$ docker pull ghcr.io/electa-git/fmiexchange.jl:latest
$ docker tag ghcr.io/electa-git/fmiexchange.jl:latest fmiexchange.jl:latest
# OR build the image yourself
$ docker build deps -t fmiexchange.jl:latest
# Run the image
$ docker run -v ./deps:/deps:Z -it fmiexchange.jl:latest
```

### Running Tests Without Generating FMUs
It is possible to download the compiled FMUs from the Github workflow runs of this repository if the artifacts are still available on Github.
First extract all FMUs to `deps/fmu/`, then run tests as normal.
It is possible that these FMUs do not work on your architecture / OS, in which case you will have to [generate the FMUs manually](###-Generating-Test-FMUs).

## License
The package is available under the BSD 3-clause license [here](./LICENSE). 
FMIExchange.jl was developed at KU Leuven - Electa by Lucas Bex.

A portion of this package reuses and modifies code from [FMI.jl](https://github.com/ThummeTo/FMI.jl).
The details, including a link to the copyright notice of [FMI.jl](https://github.com/ThummeTo/FMI.jl), can be found in [src/callbacks_fmijl.jl](./src/callbacks_fmijl.jl).
The modifications include the following:
- Compatibility with the interface of FMIExchange.jl
- Rigorous caching for better performance
