var documenterSearchIndex = {"docs":
[{"location":"Defining_and_Simulating_Models_short/#Defining-and-Simulating-Models","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"","category":"section"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"This guide explains the mathematical formalism on which this package is based, and how that translates to package usage.","category":"page"},{"location":"Defining_and_Simulating_Models_short/#Mathematical-Background","page":"Defining and Simulating Models","title":"Mathematical Background","text":"","category":"section"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"In the context of this package, a model is a system ordinary differential equations with events (further hybrid ODE). A model has inputs, states and outputs: inputs are external to the model; states evolve according to some hybrid ODE; outputs are an arbitrary function of time, inputs and states.","category":"page"},{"location":"Defining_and_Simulating_Models_short/#Working-with-Model-Exchange-FMUs","page":"Defining and Simulating Models","title":"Working with Model-Exchange FMUs","text":"","category":"section"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"A Model-Exchange FMU contains a system described by a differential algebraic equation with events (hybrid DAE), but exposes this to the user as a hybrid ODE by internally resolving all algebraic relations. The FMU can be used to compute derivatives, outputs and event indicators. Performing integration and triggering events at the appropriate time is the task of the external solver. Event handlers inside the FMU are activated when the external solver triggers an event. These handlers change the internal FMU state.","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"FMIExchange.jl was developed to make the bridge between the FMU and the external solver, which is DifferentialEquations.jl. The main idea is to provide functionality to automatically convert the FMU object as imported by FMIImport.jl to a callable function that can be used by DifferentialEquations.jl and to automatically generate the callbacks to trigger FMU events.","category":"page"},{"location":"Defining_and_Simulating_Models_short/#Composing-Simulations-With-FMIExchange.jl","page":"Defining and Simulating Models","title":"Composing Simulations With FMIExchange.jl","text":"","category":"section"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"To incorporate FMUs in a DifferentialEquations.jl workflow, we need to fit it into a function of one of the forms du = f(u, p, t) or f!(du, u, p, t). To do this FMIExchange.jl takes the following approach:","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"All states are stored in u\nAll inputs and outputs are stored in p","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"As such, u and p act as memory buffers for the models, and should be some subtype of AbstractVector. If a simulation comprises multiple models, their memory buffers should not overlap to avoid unexpected issues.","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"Because assigning and keeping track of memory addresses by hand is tedious and error-prone, FMIExchange.jl provides some basic functionality to do this automatically. FMIExchange.jl takes a two-step approach as visualised in the figure below:","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"The user must bundle the model ODE, output function and callbacks with some descriptive information in a model specification (AbstractModelSpecification). This descriptive information should contain human-readable names for the states, inputs and outputs of this model.\nFMIExchange.jl transforms a (vector of) model specification(s) into a (vector of) simulation model(s) which correspond to the model definition in the first section. All simulation model instances can be directly simulated with DifferentialEquations.jl (see the tutorial). These simulation models automatically provide the model ODE and output function with a view of the relevant part of the u and p memory buffers.","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"(Image: ) It is entirely possible to bypass the first step, or to combine FMUs with native ODEs without wrapping the ODEs in a simulation model if so desired.","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"FMIExchange.jl will not implement any hierarchy in u and p and implement them as a flat Vector{Float64}. To simplify adding interactions between the various models, FMIExchange.jl can also generate address maps that translate the human-readable variable names into indices for the u and p vectors.","category":"page"},{"location":"Defining_and_Simulating_Models_short/","page":"Defining and Simulating Models","title":"Defining and Simulating Models","text":"To simplify the composition process further, FMIExchange.jl provides functions to perform common operations: automatically calling the model output function, linking different model's inputs and outputs to each other and creating a single DifferentialEquations.jl-compatible ODE function from multiple models. See the Reference section for the corresponding syntax.","category":"page"},{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/#FMU-specific-functions","page":"Reference","title":"FMU-specific functions","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"FMIExchange.jl currently supports only FMI version 2.0. FMIExchange.jl automatically generates the callbacks required for handling all FMU events. To simulate the FMU, a CachedFMU2 must be wrapped in a CachedModel (See Simulation Models)","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"CachedFMU2\nFMIExchange.affectFMU!(model::CachedModel{<:CachedFMU2}, integrator, idx)\nFMIExchange.condition!(model::CachedModel{<:CachedFMU2}, x, t, integrator)\nFMIExchange.get_time_callbacks\nFMIExchange.get_state_callbacks\nFMIExchange.get_step_callbacks\nFMIExchange.get_input_callbacks","category":"page"},{"location":"reference/#FMIExchange.CachedFMU2","page":"Reference","title":"FMIExchange.CachedFMU2","text":"CachedFMU2{R}\nCachedFMU2(fmuloc::String, start::Real, stop::Real, ins::AbstractVector, outs::AbstractVector, staterefs::AbstractVector, parameters::Union{Dict,Nothing}=nothing)\n\nWrapper struct for FMU2s. This is mainly used for dispatch purposes and ensures that the inputs, states and outputs are returned in the expected order\n\nArguments\n\nfmuloc::String fmu file path\nstart::Real simulation start time\nstop::Real simulation stop time\nins::AbstractVector vector of fmu inputs (as string or symbol)\nouts::AbstractVector vector of fmu outputs (as string or symbol)\nstaterefs::AbstractVector vector of fmu states (as string or symbol)\nparameters::Union{Dict, Nothing}=nothing dictionary of fmu parameters or nothing if the default parameters should be used\n\nFields\n\nfmu::FMU2 fmu object as defined by FMICore.jl\nc::FMU2Component fmu component object as defined by FMICore.jl\ninput_value_references::R vector of non-human-readable references to the inputs (for working with the fmu)\noutput_value_references::R vector of non-human-readable references to the outputs (for working with the fmu)\nstate_value_references::R vector of non-human-readable references to the states (for working with the fmu)\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.affectFMU!-Tuple{CachedModel{<:CachedFMU2}, Any, Any}","page":"Reference","title":"FMIExchange.affectFMU!","text":"affectFMU!(model::CachedModel{<:CachedFMU2}, integrator, idx)\n\nHandle events in the FMU\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.condition!-Tuple{CachedModel{<:CachedFMU2}, Any, Any, Any}","page":"Reference","title":"FMIExchange.condition!","text":"condition!(model::CachedModel{<:CachedFMU2}, x, t, integrator)\ncondition!(out, model::CachedModel{<:CachedFMU2}, x, t, integrator)\n\nReturn event indicators out for the FMU (non-mutating and mutating version)\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.get_time_callbacks","page":"Reference","title":"FMIExchange.get_time_callbacks","text":"get_time_callbacks(model::CachedModel{<:CachedFMU2}, start, stop)\n\nReturn a callback to handle all time events in the FMU\n\n\n\n\n\n","category":"function"},{"location":"reference/#FMIExchange.get_state_callbacks","page":"Reference","title":"FMIExchange.get_state_callbacks","text":"get_state_callbacks(model::CachedModel{<:CachedFMU2})\n\nReturn a callback to handle state events in an FMU.\n\nThe returned callback is a continuous callback is able to detect events due to changes in the FMU state, but it will not be able to detect events due to changes in the FMU input.\n\nSee also get_input_callbacks\n\n\n\n\n\n","category":"function"},{"location":"reference/#FMIExchange.get_step_callbacks","page":"Reference","title":"FMIExchange.get_step_callbacks","text":"get_step_callbacks(model::CachedModel{<:CachedFMU2})\n\nReturn a callback to handle integrator step completion in the FMU\n\n\n\n\n\n","category":"function"},{"location":"reference/#FMIExchange.get_input_callbacks","page":"Reference","title":"FMIExchange.get_input_callbacks","text":"get_input_callbacks(model::CachedModel{<:CachedFMU2})\n\nReturn a callback to handle state events in an FMU.\n\nThe returned callback is a discrete callback will be able to detect events due to changes in the FMU input, but it  will not be able to detect events due to changes in the FMU state.\n\nSee also get_state_callbacks\n\n\n\n\n\n","category":"function"},{"location":"reference/#Simulation-Models","page":"Reference","title":"Simulation Models","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Simulation models can be directly simulated with DifferentialEquations.jl like one normally would. They contain machine-readable address maps which allow to easily combine multiple simulation models in one simulation.","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"AbstractSimModel\nSimModel\nCachedModel\n(AbstractSimModel)(u, p, t)\noutput!(::AbstractSimModel, u, p, t)\nget_callbacks(::AbstractSimModel, start, stop)","category":"page"},{"location":"reference/#FMIExchange.AbstractSimModel","page":"Reference","title":"FMIExchange.AbstractSimModel","text":"AbstractSimModel\n\nSimulation model that can be directly simulated using DifferentialEquations.jl. An AbstractSimModel wraps an ODE with events such that it can be easily used in a simulation with multiple components.\n\nUsage\n\nA simulation model contains a number of inputs, states and outputs. States are subject to an ODE with events. Outputs can be calculated from the inputs and states of the model, but this calculation may not modify the state of the model.\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.SimModel","page":"Reference","title":"FMIExchange.SimModel","text":"SimModel <: AbstractSimModel\nSimModel(f, g, ilength::Integer, olength::Integer, xlength::Integer, cbs; ioffset = 0, xoffset = 0)\n\nReturn a basic simulation model\n\nArguments\n\nf: function for calculating the derivative (refer to DifferentialEquations.jl)\ng: function for calculating the output. This function is called as follows g(out, state, in, time) and should mutate the out variable \nilength: length of the model input\nolength: length of the model output\nxlength: length of the model state\ncbs: callbacks associated with the model\nioffset=0: io memory buffer address offset\nxoffset=0: state memory buffer address offset\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.CachedModel","page":"Reference","title":"FMIExchange.CachedModel","text":"CachedModel <: AbstractSimModel\nCachedModel(fmu::CachedFMU2, uoffset=0, poffset=0)\n\nSimulation model that contains caches for storing the state and input/output.\n\nThis is primarily used to accelerate FMUs: C-calls to the FMU cannot operate on array views. If a standard SimModel were used, every C-call to the FMU would thus convert that view to a new array, allocating memory and massively slowing down the simulation.  This struct preallocates fixed-size caches of types which can be directly passed to C-calls and do not need to be converted.\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.AbstractSimModel-Tuple{Any, Any, Any}","page":"Reference","title":"FMIExchange.AbstractSimModel","text":"(::AbstractSimModel)(u, p, t)\n(::AbstractSimModel)(du, u, p, t)\n\nCalculate the derivative of the model state. Refer to the documentation of DifferentialEquations.jl\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.output!-Tuple{AbstractSimModel, Any, Any, Any}","page":"Reference","title":"FMIExchange.output!","text":"output!(::AbstractSimModel, u, p, t)\n\nWrite the model output to the relevant indices of p\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.get_callbacks-Tuple{AbstractSimModel, Any, Any}","page":"Reference","title":"FMIExchange.get_callbacks","text":"get_callbacks(model::AbstractSimModel, start, stop)\n\nReturn a vector of callbacks associated with the simulation model.\n\nArguments\n\nmodel::AbstractSimModel simulation model\nstart simulation start time\nstop simulation stop time\n\n\n\n\n\n","category":"method"},{"location":"reference/#Model-Specifications","page":"Reference","title":"Model Specifications","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Model specifications contain human-readable address maps, and can be converted to simulation models for simulation.","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"AbstractModelSpecification\nModelSpecification\nFMUSpecification\nFMIExchange.usize(spec::AbstractModelSpecification)\nFMIExchange.psize(spec::AbstractModelSpecification)\ncreate_model(::AbstractModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)","category":"page"},{"location":"reference/#FMIExchange.AbstractModelSpecification","page":"Reference","title":"FMIExchange.AbstractModelSpecification","text":"AbstractModelSpecification{S1,S2}\n\nCustom type with human-readable model information which allows automatic generation of simulation models\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.ModelSpecification","page":"Reference","title":"FMIExchange.ModelSpecification","text":"ModelSpecification{S1,S2,F,G} <: AbstractModelSpecification{S1,S2}\n\nFields\n\ninputs::AbstractVector{S1}: Vector of human-readable input names\noutputs::AbstractVector{S1}: Vector of human-readable output names\nstates::AbstractVector{S2}: Vector of human-readable state names\ndynamics::F: Function for calculating the derivative (refer to DifferentialEquations.jl)\noutput::G: Function for calculating the output. This function is called as follows output(out, state, in, time) and should mutate the out variable \n\nSee also SimModel\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.FMUSpecification","page":"Reference","title":"FMIExchange.FMUSpecification","text":"FMUSpecification{S1, S2, S3<:Union{Symbol,AbstractString}, P<:Union{Dict{String,Float64},Nothing}} <: AbstractModelSpecification{S1,S2}\n\nA model specification that can be converted to a CachedModel{<:CachedFMU2}\n\nFields\n\ninputs::AbstractVector{S1}: Vector of human-readable input names\noutputs::AbstractVector{S1}: Vector of human-readable output names\nstates::AbstractVector{S2}: Vector of human-readable state names\nfmu_location::S3: Path to the FMU\nparameters::P: Dictionary with FMU parameters (or nothing to use defaults)\n\n\n\n\n\n","category":"type"},{"location":"reference/#FMIExchange.usize-Tuple{AbstractModelSpecification}","page":"Reference","title":"FMIExchange.usize","text":"usize(spec::AbstractModelSpecification)\n\nReturn the length of the state memory buffer\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.psize-Tuple{AbstractModelSpecification}","page":"Reference","title":"FMIExchange.psize","text":"psize(spec::AbstractModelSpecification)\n\nReturn the length of the io memory buffer\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.create_model","page":"Reference","title":"FMIExchange.create_model","text":"create_model(::AbstractModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)\ncreate_model(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0; start=0.0, stop=1.0)\n\nReturn a simulation model (<:AbstractSimModel) with machine-readable address maps\n\nIf a vector of model specifications is provided, return a vector of simulation models with non-overlapping address maps\n\nSee also AbstractSimModel\n\n\n\n\n\n","category":"function"},{"location":"reference/#Simulation-composition-functionality","page":"Reference","title":"Simulation composition functionality","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"Below functions are meant to simplify composing complex simulations with multiple models.","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"address_map(names, indices::AbstractVector{<:Integer})\nlink_models(src, dst)\noutput_callback(m::AbstractSimModel)\ndynamics(models)","category":"page"},{"location":"reference/#FMIExchange.address_map-Tuple{Any, AbstractVector{<:Integer}}","page":"Reference","title":"FMIExchange.address_map","text":"address_map(ins, outs, states, m::AbstractSimModel)\naddress_map(spec::AbstractModelSpecification, uoffset=0, poffset=0)\naddress_map(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0)\n\nReturn two dictionaries linking human-readable strings/symbols for model inputs/outputs and states to machine-readable indices\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.link_models-Tuple{Any, Any}","page":"Reference","title":"FMIExchange.link_models","text":"link_models(src, dst)\nlink_models(src, dst, iomap)\n\nReturn a FunctionCallingCallback that connects inputs and outputs of models. This does not automatically resolve algebraic loops!\n\nArguments\n\nsrc human-readable strings/symbols or machine-readable indices of the model io that will be copied\ndst human-readable strings/symbols or machine-readable indices of the copy destinations\niomap dictionary mapping the human-readable strings/symbols to indices (if src and dst provided as string/symbol)\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.output_callback-Tuple{AbstractSimModel}","page":"Reference","title":"FMIExchange.output_callback","text":"output_callback(m::AbstractSimModel)\noutput_callback(ms::AbstractVector{<:AbstractSimModel})\n\nReturn a callback that calls the output function of the simulation model m (or every simulation model in ms) after every integration step\n\n\n\n\n\n","category":"method"},{"location":"reference/#FMIExchange.dynamics-Tuple{Any}","page":"Reference","title":"FMIExchange.dynamics","text":"dynamics(models)\n\nReturn a single DifferentialEquations.jl-compatible function that calculates derivatives of all models in models\n\n\n\n\n\n","category":"method"},{"location":"#FMIExchange.jl","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"","category":"section"},{"location":"#What-is-FMIExchange.jl?","page":"FMIExchange.jl","title":"What is FMIExchange.jl?","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl provides ways to easily load Model Exchange Functional Mock-up Units (FMUs) and simulate them using the DifferentialEquations.jl package.  This package cannot run simulations on its own, but merely provides tools to construct ODEFunctions and callbacks from FMUs.  The user retains full control over the simulation with the powerful and familiar interface of DifferentialEquations.jl.","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl allows to simulate multiple FMUs at the same time and even combine them with native Julia ODEs; this is the main use-case of this package. FMIExchange.jl includes some functionality to automate the process of combining multiple models into one simulation: automatic addressing, human-readable address map generation and functions for connecting model inputs and outputs.","category":"page"},{"location":"#What-is-FMIExchange.jl-not?","page":"FMIExchange.jl","title":"What is FMIExchange.jl not?","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl is not a package for simulating or manipulating FMUs: it doesn't include a simulator but merely provides convenience functions to allow simulating FMUs with the DifferentialEquations.jl package. FMIImport.jl and FMICore.jl provide functionality for importing and manipulating FMUs.  FMI.jl has built-in FMU simulation functionality, but this is limited to simulating a single FMU at a time and it is impossible to combine native ODEs with FMUs.","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl is not a modelling package. While it has some basic simulation composition functionality it lacks some crucial features such as algebraic loop resolution.  Some packages that support this are ModelingToolkit.jl and Causal.jl. Pull requests to make FMIExchange.jl compatible with these packages are welcome!","category":"page"},{"location":"#Installation","page":"FMIExchange.jl","title":"Installation","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl can be installed through the Julia package manager as below","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"using Pkg\nPkg.add(\"https://github.com/Electa-Git/FMIExchange.jl\")","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"Currently, FMIExchange.jl is not yet added to the general registry, but plans are to change that.","category":"page"},{"location":"#Generating-Test-FMUs","page":"FMIExchange.jl","title":"Generating Test FMUs","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"To run the tests you need to generate the FMUs.  This requires OpenModelica to be installed and the compiler omc to be available in your PATH variable. The Modelica Standard Library, Buildings, IDEAS and MoPED libraries should be available in your Modelica path.","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"You can find your Modelica path by creating a mos script with the following contents","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"getModelicaPath()","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"and running it with omc. On Linux, the result is ~/.openmodelica/libraries.","category":"page"},{"location":"#Running-Tests-Without-Generating-FMUs","page":"FMIExchange.jl","title":"Running Tests Without Generating FMUs","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"It is possible to download the compiled FMUs from the Github workflow runs of this repository if the artifacts are still available on Github. First extract all FMUs to deps/fmu/, then run tests as normal. It is possible that these FMUs do not work on your architecture / OS, in which case you will have to generate the FMUs manually.","category":"page"},{"location":"#License","page":"FMIExchange.jl","title":"License","text":"","category":"section"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"FMIExchange.jl is available under the BSD 3-clause license.  FMIExchange.jl was developed at KU Leuven - Electa by Lucas Bex.","category":"page"},{"location":"","page":"FMIExchange.jl","title":"FMIExchange.jl","text":"A portion of this package reuses and modifies code from FMI.jl. A link to this portion of the code and a list of modifications can be found in FMIExchange.jl's README.","category":"page"},{"location":"tutorial/#Tutorials","page":"Tutorials","title":"Tutorials","text":"","category":"section"},{"location":"tutorial/#Simulating-an-FMU","page":"Tutorials","title":"Simulating an FMU","text":"","category":"section"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"In this example, we will simulate an FMU of a ball bouncing around in a 2D space. The ball has a radius of 0.1 and the 2D space is given by by 00 10 times 00 infty","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"For this tutorial we will need OrdinaryDiffEq.jl to run the simulation and Plots.jl for visualisation.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"using FMIExchange\nusing OrdinaryDiffEq\nusing Plots","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"To initialise the FMU, we must provide the path to the FMU, its inputs, outputs and states and the simulation start and stop times. If we wish to change the parameters of the FMU we can do this by providing a dictionary of parameter-value pairs.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"bbloc = joinpath(\"deps\", \"fmu\", \"BouncingBall2D.fmu\") # fmu file location\nbbloc = joinpath(@__DIR__, \"..\", \"..\", \"deps\", \"fmu\", \"BouncingBall2D.fmu\") # hide\nbbstart = 0.0 # simulation start\nbbstop = 10.0 # simulation stop\nbbins = String[] # FMU inputs (this FMU has none)\nbbouts = String[] # FMU outputs (this FMU has none)\nbbstates = [\"dx\", \"dy\", \"x\", \"y\"] # FMU states\nbbparameters = Dict(\"eps\"=>1e-2) # FMU parameters (optional)\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"We then instantiate the FMU as a CachedFMU2 (the name CachedFMU2 is to avoid naming conflicts with related packages). To simulate the FMU, we need to convert it to an AbstractSimModel. Simulation models can be directly simulated with OrdinaryDiffEq.jl. In this example we use the CachedModel simulation model, which contains preallocated caches to make calls to the FMU faster.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"fmu = CachedFMU2(bbloc, bbstart, bbstop, bbins, bbouts, bbstates, bbparameters)\nmodel = CachedModel(fmu)\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"Let's simulate the FMU with the default solver.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"u0 = [1.0, 0.0, 0.5, 1.0]\np0 = Float64[]\ntspan = (bbstart, bbstop)\n\nsol = solve(\n    ODEProblem(model, u0, tspan, p0),\n    AutoTsit5(Rosenbrock23(autodiff=false)),\n)\nplot(sol, idxs=(3,4), legend=false)\nsavefig(\"nocb.png\"); nothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"(Image: )","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"That doesn't look right: the ball does not bounce when it hits the ground or the wall. There is a simple reason for this: we forgot to include callbacks to handle the FMU events. FMIExchange.jl can automatically generate the required callbacks. If we include them, the ball behaves as expected.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"cbs = get_callbacks(model, bbstart, bbstop)\nsol = solve(\n    ODEProblem(model, u0, tspan, p0),\n    AutoTsit5(Rosenbrock23(autodiff=false)),\n    saveat=bbstart:0.01:bbstop, # for a nicer plot\n    callback=CallbackSet(cbs...)\n)\nplot(sol, idxs=(3,4), legend=false)\nsavefig(\"cb.png\"); nothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"(Image: )","category":"page"},{"location":"tutorial/#Mixed-Native-ODEs-and-FMUs","page":"Tutorials","title":"Mixed Native ODEs and FMUs","text":"","category":"section"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"This example will again simulate the bouncing ball FMU, but this time it adds a second ball that is defined by a native Julia ODE.  We will call the balls bb and ss respectively. ss is subject to \"screensaver physics\": its speed is constant but ss changes direction when it collides with a wall or with bb. To avoid ss flying away, we restrict it to the 0 1 times 0 1 box.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"First, define our bouncing ball FMU bb again (see Simulating an FMU).","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"using FMIExchange\nusing LinearAlgebra\nusing OrdinaryDiffEq\nusing Plots\n\nbbloc = joinpath(\"deps\", \"fmu\", \"BouncingBall2D.fmu\") # fmu file location\nbbloc = joinpath(@__DIR__, \"..\", \"..\", \"deps\", \"fmu\", \"BouncingBall2D.fmu\") # hide\nbbstart = 0.0 # simulation start\nbbstop = 10.0 # simulation stop\nbbins = String[] # FMU inputs (this FMU has none)\nbbouts = String[] # FMU outputs (this FMU has none)\nbbstates = [\"dx\", \"dy\", \"x\", \"y\"] # FMU states\nbb_radius = 0.1\nbbparameters = Dict(\"eps\"=>1e-2, \"r\" => bb_radius) # FMU parameters (optional)\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"Now define the physics for ss.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"ss_radius = 0.1\nymin = xmin = 0.0\nymax = xmax = 1.0\n# The three statements below are a formality\nssinputs = [\"dxs\", \"dys\"]\nssoutputs = String[]\nssstates = [\"xs\", \"ys\"]\n\nscreensaver(du, u, p, t)  = du[:] = p[1:2]\nscreencb = VectorContinuousCallback(\n    (out, u, t, integrator) -> begin\n        out[1] = u[1] - (xmin + ss_radius)\n        out[2] = u[1] - (xmax - ss_radius)\n        out[3] = u[2] - (ymin + ss_radius)\n        out[4] = u[2] - (ymax - ss_radius)\n    end,\n    (integrator, idx) -> begin\n        if idx <= 2\n            integrator.p[1] = -integrator.p[1]\n        else\n            integrator.p[2] = -integrator.p[2]\n        end\n    end,\n    4\n)\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"Now that we have both models, it's time to combine them. We wrap ss in a ModelSpecification and bb in an FMUSpecification which will allow us to use FMIExchange.jl's simulation composition functionality.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"ss_spec = ModelSpecification(ssinputs, ssoutputs, ssstates, screensaver, (args...) -> nothing)\nbb_spec = FMUSpecification(bbins, bbouts, bbstates, bbloc, bbparameters)\nspecs = [ss_spec, bb_spec]\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"The specifications can be converted to simulation models via the create_model function, which will automatically assign the correct address maps as well.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"models = create_model(specs, start=bbstart, stop=bbstop)\niomap, umap = address_map(specs)\nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"Since there are now two objects in our 2D space, we need to define a callback that handles collision between both.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"collision_cb = ContinuousCallback(\n    (u, t, integrator) -> begin\n        (u[umap[\"x\"]] - u[umap[\"xs\"]]) ^ 2 + (u[umap[\"y\"]] - u[umap[\"ys\"]]) ^ 2 - (ss_radius + bb_radius) ^ 2\n    end,\n    (integrator) -> begin\n        u, p = integrator.u, integrator.p\n\n        # collision line and orthogonal\n        collision_line = normalize([u[umap[\"x\"]] - u[umap[\"xs\"]], u[umap[\"y\"]] - u[umap[\"ys\"]]])\n        orth = vec(nullspace(collision_line')) \n\n        # velocity vectors of bb and ss\n        vbb = @view(u[[umap[\"dx\"], umap[\"dy\"]]])\n        vss = @view(p[[iomap[\"dxs\"], iomap[\"dys\"]]])\n\n        # New vectors using dot(a, b) to project two vectors onto each other\n        vbb[:] = abs(dot(collision_line, vbb)) * collision_line + dot(orth, vbb) * orth\n        vss[:] = - abs(dot(collision_line, vss)) * collision_line + dot(orth, vss) * orth\n\n        u_modified!(integrator, true)\n    end\n) \nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"details: Collision Physics\nTo simulate the collision between ss and bb, we decompose the velocity vector of each into components that are orthogonal and tangential to the collision line (the line between the centers of ss and bb).  The tangential component of bb's velocity vector will point away from ss after bouncing and vice versa. The orthogonal velocity component remains the same for both.  For simplicity we assume the magnitude of each object's velocity remains constant.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"Finally we define initial conditions and simulate the system. One small change compared to the first example, is that we now need to call the dynamics function to obtain our ODEfunction. This is because models is not an AbstractSimModel, but rather a Vector{AbstractSimModel}. dynamics(models) automatically generates an OrdinaryDiffEq.jl-compatible function that combines the ODEs of both models.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"u0 = zeros(length(keys(umap)))\nu0[umap[\"x\"]] = 0.5\nu0[umap[\"dx\"]] = 0.5\nu0[umap[\"y\"]] = 1.0\nu0[umap[\"dy\"]] = 0.0\nu0[umap[\"xs\"]] = 0.2\nu0[umap[\"ys\"]] = 0.8\np0 = Float64[0.2, 0.2]\ntspan = (bbstart, bbstop)\nsol = solve(\n    ODEProblem(dynamics(models), u0, tspan, p0),\n    AutoTsit5(Rosenbrock23(autodiff=false)),\n    callback=CallbackSet(\n        reduce(vcat, get_callbacks.(models, bbstart, bbstop))...,\n        screencb,\n        collision_cb\n    ),\n    dtmax=0.01 # The collision callback may give errors when using large steps\n) \nnothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"We can plot the solution as a nice animation.","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"import Logging # hide\nLogging.disable_logging(Logging.Info) # hide\n# this function was copied from\n# https://discourse.julialang.org/t/plot-a-circle-with-a-given-radius-with-plots-jl/23295\nfunction circleShape(h, k, r)\n    θ = LinRange(0, 2π, 500)\n    h .+ r * sin.(θ), k .+ r * cos.(θ)\nend\n\nanim = @animate for t = sort(bbstart:0.1:bbstop)\n    plot(sol, idxs=[(umap[\"x\"], umap[\"y\"]), (umap[\"xs\"], umap[\"ys\"])],\n         tspan=(bbstart, t), xlim=(xmin, xmax), ylim=(ymin, ymax),\n         aspect_ratio=:equal, label=[\"bb\" \"ss\"], legend=:topleft\n    )\n    plot!(circleShape(sol(t)[umap[\"x\"]], sol(t)[umap[\"y\"]], bb_radius),\n          fill=(0,), color=palette(:default)[1], label=nothing)\n    plot!(circleShape(sol(t)[umap[\"xs\"]], sol(t)[umap[\"ys\"]], ss_radius),\n          fill=(0,), color=palette(:default)[2], label=nothing)\nend\n\ngif(anim, \"ss.gif\"); nothing # hide","category":"page"},{"location":"tutorial/","page":"Tutorials","title":"Tutorials","text":"(Image: )","category":"page"}]
}
