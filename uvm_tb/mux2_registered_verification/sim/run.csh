#!/bin/bash
#-------------------------------------------------------------------------------
# Script del standalone TB del mux2_registered.
# Usa filelist.f con dependencias RTL a mux2_verification y regbank_verification.
#-------------------------------------------------------------------------------
set -e

echo "=== Compilando mux2_registered standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    -f filelist.f \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv -f filelist.f -ssf mux2_registered_standalone.fsdb &"
