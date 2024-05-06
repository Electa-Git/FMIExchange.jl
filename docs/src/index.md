# FMIExchange.jl
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

## Installation
FMIExchange.jl can be installed through the Julia package manager as below
```julia
using Pkg
Pkg.add("FMIExchange")
```

### Generating Test FMUs
To run the tests you need to generate the FMUs. 
This requires OpenModelica to be installed and the compiler `omc` to be available in your `PATH` variable.
The [Modelica Standard Library](https://github.com/modelica/ModelicaStandardLibrary), [Buildings](https://github.com/lbl-srg/modelica-buildings), [IDEAS](https://github.com/open-ideas/IDEAS) and [MoPED](https://gitlab.kuleuven.be/positive-energy-districts/moped.git) libraries should be available in your Modelica path.

You can find your Modelica path by creating a `mos` script with the following contents
```
getModelicaPath()
```
and running it with `omc`.
On Linux, the result is `~/.openmodelica/libraries`.

### Running Tests Without Generating FMUs
It is possible to download the compiled FMUs from the Github workflow runs of this repository if the artifacts are still available on Github.
First extract all FMUs to `deps/fmu/`, then run tests as normal.
It is possible that these FMUs do not work on your architecture / OS, in which case you will have to [generate the FMUs manually](###-Generating-Test-FMUs).

## License
FMIExchange.jl is available under the BSD 3-clause license. 
FMIExchange.jl was developed at KU Leuven - Electa by Lucas Bex.

A portion of this package reuses and modifies code from [FMI.jl](https://github.com/ThummeTo/FMI.jl).
A link to this portion of the code and a list of modifications can be found in FMIExchange.jl's [README](https://github.com/Electa-Git/FMIExchange.jl/blob/main/README.md).

## Reproducibility

```@raw html
<details><summary>The documentation of this package was built using these direct dependencies,</summary>
```

```@example
using Pkg # hide
Pkg.status() # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>and using this machine and Julia version.</summary>
```

```@example
using InteractiveUtils # hide
versioninfo() # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>A more complete overview of all dependencies and their versions is also provided.</summary>
```

```@example
using Pkg # hide
Pkg.status(; mode = PKGMODE_MANIFEST) # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>The software used to compile the FMUs used in this documentation is</summary>
```

```@example
using FMIImport # hide
println(fmi2Load(joinpath(@__DIR__, "..", "..", "deps", "fmu", "BouncingBall2D.fmu")).modelDescription.generationTool) # hide
```
```@raw html
</details>
```
The [Modelica implementation of the FMUs](https://github.com/Electa-Git/FMIExchange.jl/tree/main/deps/src) can be found in the [FMIExchange.jl](https://github.com/Electa-Git/FMIExchange.jl/tree/main) repo.

## Compatibility Information
FMIExchange.jl supports simulating Model Exchange FMUs compatible with FMI 2.0. Since FMIExchange.jl relies on [FMIImport.jl](https://github.com/ThummeTo/FMIImport.jl) to load and handle FMUs, it should be compatible with any FMUs that can be simulated using that package. FMIExchange.jl does not support exporting FMUs.

This package was tested using the tools and FMUs listed under [Reproducibility](##-Reproducibility). The FMUs were created using [OpenModelica](https://openmodelica.org/).
