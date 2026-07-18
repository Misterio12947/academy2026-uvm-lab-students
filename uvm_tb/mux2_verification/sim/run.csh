#!/bin/bash
#-------------------------------------------------------------------------------
# Script del standalone TB del mux2.
#-------------------------------------------------------------------------------
set -e

echo "=== Compilando mux2 standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    ../rtl/mux2.sv \
    tb_mux2.sv \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv ../rtl/mux2.sv tb_mux2.sv -ssf mux2_standalone.fsdb &"
