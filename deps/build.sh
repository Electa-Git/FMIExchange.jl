#!/bin/bash
cd deps
mkdir -p build
cp src/* build -r
cd build
for d in */; do
    cd $d;
    omc buildFMU.mos;
    cd ..;
done;
cd ..
mkdir -p fmu
find build -iname '*.fmu' -exec mv {} fmu \;
tar -czf fmu.tar.gz fmu
cd ..

