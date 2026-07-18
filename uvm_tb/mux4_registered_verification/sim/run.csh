#!/bin/bash
#-------------------------------------------------------------------------------
# Script del standalone TB del mux4_registered.
# Usa filelist.f que referencia los RTL de mux4_verification y regbank_verification
# (single source of truth: no duplicamos codigo entre bloques).
#-------------------------------------------------------------------------------
set -e

echo "=== Compilando mux4_registered standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    -f filelist.f \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv -f filelist.f -ssf mux4_registered_standalone.fsdb &"
