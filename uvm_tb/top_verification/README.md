# top Verification (Standalone Phase)

Validacion end-to-end del CPU multiciclo completo del Lab III. Ultimo bloque
del proyecto que integra los 7 submodulos ya firmados en un CPU funcional.

```
## Estructura
top_verification/
├── README.md
├── rtl/
│   └── top.sv                  # DUT: CPU multiciclo integrado
├── sim/
│   ├── tb_top.sv               # TB self-checking, 10 escenarios, ~30 checks
│   ├── filelist.f              # Referencias a TODOS los submodulos
│   └── run.sh                  # compile + sim
└── docs/
└── TESTPLAN.md             # Testplan v1.0 (standalone)
```

## Dependencias RTL

Este bloque **NO duplica** ningun RTL. Referencia los 7 submodulos:
```
../../mux4_verification/rtl/mux4.sv
../../mux4_registered_verification/rtl/mux4_registered.sv
../../mux2_verification/rtl/mux2.sv
../../mux2_registered_verification/rtl/mux2_registered.sv
../../regbank_verification/rtl/register_bank.sv
../../memory_verification/rtl/memory.sv
../../alu_verification/rtl/alu.sv
../../control_verification/rtl/control.sv
```

Si algun submodulo cambia, este TB debe re-ejecutarse.

## Uso

```bash
cd sim/
./run.sh
```

## Escenarios cubiertos

| ESC | Proposito                                         |
| --- | ------------------------------------------------- |
| 1   | Reset behavior                                     |
| 2   | ADD 5+3=8                                          |
| 3   | SUB 16-1=15                                        |
| 4   | MUL (dout_high y dout_low)                         |
| 5   | DIV 32/4=8                                         |
| 6   | DIV /0 -> error=1, dout=-1                         |
| 7   | NOP -> zero=1                                       |
| 8   | STORE then LOAD (write-then-read memoria)          |
| 9   | Feedback loop (muxA=11 y muxB=11)                  |
| 10  | p_error via feedback -> nvalid_data -> ALU error   |

## Criterio de sign-off

~30/30 checks PASS. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Nota didactica: integracion end-to-end

Este es el bloque culmen del proyecto. Ilustra:
- **Composicion masiva**: 7 submodulos integrados via single-source-of-truth
- **Testplan end-to-end**: no re-verifica los submodulos (ya firmados), sino
  la integracion (feedback loop, direcciones de memoria, propagacion de errores)
- **Timing multiciclo**: cada instruccion toma 3 posedges, TB sincroniza con
  `repeat (3) @(posedge clk)` en vez de con cpu_rdy directamente
- **ISA end-to-end**: cada opcode del ISA (ADD, SUB, MUL, DIV, NOP, LOAD, STORE)
  se ejercita al menos una vez

Con este bloque firmado, la fase RTL del proyecto queda completa. Fase
siguiente: envs UVM completos para todos los bloques.

## Fase siguiente

Env UVM del top con reference model del CPU multiciclo completo, coverage
por opcode + cruces con propagacion de errores.
