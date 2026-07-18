# top — Test Plan (Standalone TB)

**Bloque:** `top` (CPU multiciclo integrado, Lab III completo)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / top_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion end-to-end del CPU multiciclo completo. Integra los 7 submodulos
ya firmados en sus respectivos bloques:

- **mux4** + **mux4_registered** (mux A y mux B con registro)
- **mux2** + **mux2_registered** (mux de salida ALU/memoria)
- **register_bank** (flags zero, error, y cmd)
- **memory** (8 palabras de 2*WIDTH bits)
- **ALU** (arithmetic, error handling)
- **control** (FSM 4 estados: RST_ST -> FETCH_DECODE -> EXECUTE -> STORE)

**Enfoque de verificacion**: submodulos ya firmados por separado. Este TB
verifica la **integracion end-to-end**: cada opcode del ISA ejecuta
correctamente, el feedback loop conecta bien, y errores propagan.

## 2. Features del DUT (segun spec e imagenes del lab)

| ID          | Feature                                        | Referencia                  |
| ----------- | ---------------------------------------------- | --------------------------- |
| FEAT-TOP-01 | CPU multiciclo de 3 etapas sin pipelining      | Spec Lab III                |
| FEAT-TOP-02 | 3 buses de entrada (din_1, din_2, din_3)       | Spec                        |
| FEAT-TOP-03 | 2 muxes 4:1 con feedback loop de ALU output    | Imagenes 1-4                |
| FEAT-TOP-04 | ALU con opcode ISA de 8 operaciones            | Spec                        |
| FEAT-TOP-05 | Memoria integrada (write STORE, read LOAD)     | Spec                        |
| FEAT-TOP-06 | Flags zero, error registrados                  | Imagen 4 (verde)            |
| FEAT-TOP-07 | Feedback loop: muxA<-dout_high, muxB<-dout_low | Spec + imagen 3             |
| FEAT-TOP-08 | Address de memoria = mux_a_out registrado      | Imagen 4                    |
| FEAT-TOP-09 | cpu_rdy pulso al terminar instruccion          | Spec                        |
| FEAT-TOP-10 | Interfaz mandatoria                             | Spec                        |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales por opcode

| ID          | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-TOP-01  | Reset asincrono: cpu_rdy=0, dout=0, zero=0, error=0               | DIR + CHK | ESC 1        | **PASS** |
| REQ-TOP-02  | ADD: dout = din_muxA + din_muxB (2*WIDTH bits)                    | DIR + CHK | ESC 2, 9     | **PASS** |
| REQ-TOP-03  | SUB: dout = din_muxA - din_muxB                                    | DIR + CHK | ESC 3        | **PASS** |
| REQ-TOP-04  | MUL: dout = din_muxA * din_muxB (verifica dout_high y dout_low)   | DIR + CHK | ESC 4        | **PASS** |
| REQ-TOP-05  | DIV normal: dout = din_muxA / din_muxB                             | DIR + CHK | ESC 5        | **PASS** |
| REQ-TOP-06  | DIV /0: error=1, dout=0xFFFF (-1)                                  | DIR + CHK | ESC 6        | **PASS** |
| REQ-TOP-07  | NOP: dout=0, zero=1, error=0, cpu_rdy=1                            | DIR + CHK | ESC 7        | **PASS** |
| REQ-TOP-08  | STORE escribe a memoria; LOAD lee del mismo address                | DIR + CHK | ESC 8        | **PASS** |

### 3.2 Requerimientos de integracion

| ID          | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-INT-01  | Feedback loop muxA=11 usa dout_high                                | DIR + CHK | ESC 9        | **PASS** |
| REQ-INT-02  | Feedback loop muxB=11 usa dout_low                                 | DIR + CHK | ESC 9        | **PASS** |
| REQ-INT-03  | p_error registrado propaga a control unit                           | DIR + CHK | ESC 10       | **PASS** |
| REQ-INT-04  | nvalid_data se asserta con p_error + muxA/B==11                    | DIR + CHK | ESC 10       | **PASS** |
| REQ-INT-05  | ALU con invalid_data=1 fuerza error=1, out=-1                      | DIR + CHK | ESC 10       | **PASS** |
| REQ-INT-06  | Instrucciones back-to-back fluyen sin reset intermedio             | DIR + CHK | ESC 8, 9, 10 | **PASS** |
| REQ-INT-07  | Address de memoria proviene de mux_a_out (registrado)              | DIR + CHK | ESC 8        | **PASS** |
| REQ-INT-08  | Datos escritos a memoria = {dout_high, dout_low}                   | DIR + CHK | ESC 8        | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                              | Checks |
| --------- | ------------------------------------------------------ | ------ |
| ESC 1     | Reset behavior (todos los outputs en 0)                | 4      |
| ESC 2     | ADD 5+3                                                | 4      |
| ESC 3     | SUB 16-1                                               | 3      |
| ESC 4     | MUL (verifica dout_high y dout_low, 2 casos)           | 2      |
| ESC 5     | DIV normal                                              | 2      |
| ESC 6     | DIV por cero (error condition)                          | 3      |
| ESC 7     | NOP                                                     | 4      |
| ESC 8     | STORE + LOAD (write-then-read en memoria)              | 3      |
| ESC 9     | Feedback loop (dos instrucciones encadenadas)          | 2      |
| ESC 10    | p_error via feedback -> nvalid_data -> ALU forza error | 3      |
| **Total** |                                                        | **~30** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Todos los checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

### Comando de sign-off

```bash
cd sim/
./run.sh
grep "ALL TESTS PASSED" sim.log
```

## 6. Dependencias RTL (single source of truth)

Este bloque referencia RTLs de **todos** los submodulos previos via
`filelist.f`. Ningun RTL se duplica.

**Politica**: si cualquier submodulo cambia en su bloque origen, este TB
debe re-ejecutarse. Esto garantiza consistencia end-to-end.

## 7. Modelo de timing

Cada instruccion toma **3 posedges** para completarse:
- Posedge 1: RST_ST -> FETCH_DECODE (o STORE previo -> FETCH_DECODE)
- Posedge 2: FETCH_DECODE -> EXECUTE (mux_a, mux_b capturan operandos)
- Posedge 3: EXECUTE -> STORE (mux2_registered captura resultado; cpu_rdy=1)

El TB usa este modelo para sincronizar checks (`repeat (3) @(posedge clk)`).

## 8. Fase siguiente: env UVM

El env UVM del top sera el mas rico:
- Coverage: cada opcode ejercitado, cada combinacion muxA/muxB, secuencias
  de instrucciones consecutivas, propagacion de errores
- Sequences: streams de instrucciones aleatorias con constraints (probabilidad
  balanceada por opcode), streams directed para casos borde
- Reference model: replica del CPU multiciclo en SV comportamental

## 9. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Imagenes del spec:** 4 diagramas (Reset, Fetch/Decode, Execute, Store)
- **RTL del DUT:** `rtl/top.sv`
- **RTL submodulos:** referenciados via `filelist.f`
- **TB standalone:** `sim/tb_top.sv`
