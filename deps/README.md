# FMIExchange Dependencies

## `BouncingBall2D.fmu` 
FMU of the 2D bouncing ball model in `./src/BouncingBall`.
This FMU was built with Openmodelica v1.23.0-dev.
Later Openmodelica versions have resulted in different behaviour, where proprietary Modelica tools resulted in valid FMUs but require a license to run.
Since Openmodelica v1.23.0-dev is not readily available anymore, we provide solely the binary artifact, compiled for the x86\_64-linux platform.
This FMU is used solely for the tutorial in the documentation.

## `BouncingBallReference.fmu` 
This is the Bouncing Ball model from the [reference FMU implementations v0.0.39](https://github.com/modelica/Reference-FMUs/tree/v0.0.39).
The binary was downloaded from the [0.0.39 release page](https://github.com/modelica/Reference-FMUs/releases/tag/v0.0.39) and should work for both Linux and Windows platforms.

## Custom FMUs
The `./src` folder contains custom Modelica models, which are built using the `build.jl` script.
### Build Locally
Building the FMUs requires an Openmodelica installation and `omc` to be added to PATH, as well as the [Modelica Standard Library 4.0.0](https://github.com/modelica/ModelicaStandardLibrary/tree/v4.0.0), [IDEAS 3.0](github.com/open-ideas/IDEAS) and [Buildings 9.1.1](https://github.com/lbl-srg/modelica-buildings).
Run the following command to build.
```bash
$ julia --project deps/build.jl native
```

### Build Using Provided Docker Image
The provided docker image can be used to build for the x86\_64-linux platform.
Note that if you're running Windows or MacOS, this doesn't guarantee that the FMUs will work on your machine, only within a similar docker container.
```bash
$ docker run -v ./deps:/deps:Z -it ghcr.io/electa-git/fmiexchange.jl:latest
```
