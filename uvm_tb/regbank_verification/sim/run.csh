#!/bin/bash
#-------------------------------------------------------------------------------
# Script minimalista para el TB standalone del register_bank.
# Cuando la validacion pase, migramos a Makefile completo estilo UVM.
#-------------------------------------------------------------------------------

set -e

echo "=== Compilando register_bank standalone TB ==="
vcs -full64 -sverilog -debug_access+all -kdb \
    -timescale=1ns/1ps \
    ../rtl/register_bank.sv \
    tb_register_bank.sv \
    -l compile.log \
    -o simv

echo "=== Ejecutando simv ==="
./simv -l sim.log

echo "=== Fin. Ver sim.log para el reporte completo ==="
echo "    Waveforms: verdi -sv ../rtl/register_bank.sv tb_register_bank.sv -ssf regbank_standalone.fsdb &"
