#!/bin/bash
set -e
echo "=== Compilando control standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    ../rtl/control.sv \
    tb_control.sv \
    -l compile.log \
    -o simv
echo "=== Ejecutando simv ==="
./simv -l sim.log
echo "=== Fin ==="
echo "    Waveforms: verdi -sv ../rtl/control.sv tb_control.sv -ssf control_standalone.fsdb &"
