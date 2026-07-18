#!/bin/bash
#-------------------------------------------------------------------------------
# Script del standalone TB de la memoria.
#-------------------------------------------------------------------------------
set -e

echo "=== Compilando memory standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    ../rtl/memory.sv \
    tb_memory.sv \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv ../rtl/memory.sv tb_memory.sv -ssf memory_standalone.fsdb &"
