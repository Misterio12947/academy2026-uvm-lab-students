# Nota sobre reference_sim.log de alu_verification

Este `reference_sim.log` proviene del flow **UVM** del proyecto origen
(`sim_alu_regression_test.log`), NO de un testbench standalone. En el
proyecto origen la ALU fue verificada con un env UVM completo que alcanzo
99.38% de cobertura estructural.

## Consecuencias para ti como estudiante

- El formato del log es UVM (`UVM_INFO`, `UVM_ERROR`, fases, phase objections).
  Tu TB standalone producira un formato distinto (tus propios `$display`
  con contadores `OK`/`ERR`). No intentes replicar el formato UVM.

- Usa este log como **oraculo semantico**, no textual:
  * Verifica que tu TB standalone ejercita los mismos escenarios listados
    en `docs/TESTPLAN.md`.
  * Verifica que los resultados esperados (patrones aritmeticos, flags de
    overflow, zero, negative, carry) coinciden con lo que reporta este log.
  * No hagas `diff` byte-a-byte, no tendria sentido.

- Cuando llegues a la fase UVM del curso, este log si sera comparable
  textualmente contra tu env UVM.
