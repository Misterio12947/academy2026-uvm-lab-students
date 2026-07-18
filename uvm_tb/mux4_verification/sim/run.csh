#!/bin/bash
#-------------------------------------------------------------------------------
# Script del standalone TB del mux4.
#-------------------------------------------------------------------------------
set -e

echo "=== Compilando mux4 standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    ../rtl/mux4.sv \
    tb_mux4.sv \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv ../rtl/mux4.sv tb_mux4.sv -ssf mux4_standalone.fsdb &"
