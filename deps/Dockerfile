FROM ubuntu:latest as setup

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install omc build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    ccache \
    git \
    g++ \
    clang \
    wget \
    libblas-dev \
    libhwloc-dev \
    liblapack-dev \
    libboost-all-dev \
    libcurl4-openssl-dev \
    uuid-dev \
    default-jre \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    gfortran \
    cmake \
    xdg-utils \
    gcc \
    zip \
    unzip && \
    rm -rf /var/lib/apt/lists/*

FROM setup as omc_build
RUN git clone --recurse-submodules https://github.com/OpenModelica/OpenModelica.git && \
    cd OpenModelica && \
    git checkout v1.23.0-dev && \
    git submodule update --force --init --recursive

RUN cd OpenModelica && \
    cmake -S . -B build_cmake -DOM_ENABLE_GUI_CLIENTS=OFF -DOM_OMC_ENABLE_IPOPT=OFF -DOM_OMC_ENABLE_FORTRAN=OFF && \
    cmake --build build_cmake --target install --parallel $(nproc)

FROM setup as modelica_libs
RUN git config --global advice.detachedHead false
RUN git clone https://github.com/lbl-srg/modelica-buildings ~/.openmodelica/libraries/modelica-buildings --branch v9.1.1 --depth 1
RUN git clone https://github.com/open-ideas/IDEAS ~/.openmodelica/libraries/IDEASlib --branch v3.0 --depth 1
RUN git clone https://gitlab.kuleuven.be/positive-energy-districts/moped ~/.openmodelica/libraries/moped
RUN git clone https://github.com/modelica/ModelicaStandardLibrary ~/.openmodelica/libraries/ModelicaStandardLibrary --branch v4.0.0 --single-branch
RUN mv ~/.openmodelica/libraries/modelica-buildings/Buildings ~/.openmodelica/libraries/
RUN mv ~/.openmodelica/libraries/IDEASlib/IDEAS ~/.openmodelica/libraries/
RUN mv ~/.openmodelica/libraries/moped/MoPED ~/.openmodelica/libraries/
RUN mv ~/.openmodelica/libraries/ModelicaStandardLibrary/Modelica ~/.openmodelica/libraries/

FROM ubuntu:latest
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    liblapack-dev \
    zip
COPY --from=omc_build /OpenModelica/build_cmake/install_cmake /opt/openmodelica
RUN ln -s /opt/openmodelica/bin/omc /usr/bin
ENV OPENMODELICALIBRARY=/root/.openmodelica/libraries
ENV MODELICAPATH=$OPENMODELICALIBRARY
COPY --from=modelica_libs /root/.openmodelica/libraries/Modelica /root/.openmodelica/libraries
COPY --from=modelica_libs /root/.openmodelica/libraries/MoPED /root/.openmodelica/libraries
COPY --from=modelica_libs /root/.openmodelica/libraries/IDEAS /root/.openmodelica/libraries
COPY --from=modelica_libs /root/.openmodelica/libraries/Buildings /root/.openmodelica/libraries
ENTRYPOINT ["deps/build.sh"]
