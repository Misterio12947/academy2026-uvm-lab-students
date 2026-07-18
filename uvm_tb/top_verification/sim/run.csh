#!/bin/bash
set -e
echo "=== Compilando top standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    -f filelist.f \
    -l compile.log \
    -o simv
echo "=== Ejecutando simv ==="
./simv -l sim.log
echo "=== Fin ==="
echo "    Waveforms: verdi -sv -f filelist.f -ssf top_standalone.fsdb &"
