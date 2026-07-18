# control — Test Plan (Standalone TB)

**Bloque:** `control` (unidad de control del CPU multiciclo, FSM Moore 4 estados)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / control_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion standalone del `control`, el modulo mas complejo del Lab III.
Implementa una FSM Moore de 4 estados que orquesta el CPU multiciclo:

- **RST_ST**: captura primer cmd_in del master ("avoid losing one cycle")
- **FETCH_DECODE**: decodifica cmd_in, captura operandos en registros A y B
- **EXECUTE**: ALU computa (y opcionalmente memoryRead para LOAD)
- **STORE**: pulso cpu_rdy, captura siguiente cmd_in, y opcionalmente
  memoryWrite si la instruccion es STORE

## 2. Features del DUT (segun spec e imagenes del laboratorio)

| ID          | Feature                                        | Referencia                  |
| ----------- | ---------------------------------------------- | --------------------------- |
| FEAT-CTL-01 | FSM Moore de 4 estados                         | Diagramas del lab (4 fases) |
| FEAT-CTL-02 | Reset asincrono activo alto lleva a RST_ST     | Convencion del proyecto     |
| FEAT-CTL-03 | Decodificacion de cmd_in [6:5]/[4:3]/[2:0]     | Spec: ISA cmd_in structure  |
| FEAT-CTL-04 | Enables de registro por etapa                  | Spec: "enable stages only when applicable" |
| FEAT-CTL-05 | cpu_rdy pulso de 1 ciclo en STORE              | Spec: "ready when instruction finishes" |
| FEAT-CTL-06 | opcode de 4 bits hacia la ALU                  | Spec: "op input is 4 bits"  |
| FEAT-CTL-07 | Acceso a memoria segun opcode: LOAD lee en EXECUTE, STORE escribe en STORE | Imagenes 3 y 4 |
| FEAT-CTL-08 | nvalid_data = p_error && feedback              | Spec: "invalid_data when data from feedback loop and previous result was not valid" |
| FEAT-CTL-09 | Interfaz mandatoria del lab                     | Spec: "mandatory interface" |

## 3. Matriz de requerimientos

### 3.1 Requerimientos funcionales

| ID          | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CTL-01  | Reset asincrono lleva a RST_ST                                    | DIR + CHK | ESC 1        | **PASS** (tras run) |
| REQ-CTL-02  | RST_ST: datain_reg_en=1, resto=0                                  | DIR + CHK | ESC 1        | **PASS** |
| REQ-CTL-03  | FSM transiciona RST_ST -> FETCH_DECODE -> EXECUTE -> STORE       | DIR + CHK | ESC 2        | **PASS** |
| REQ-CTL-04  | FETCH_DECODE: aluin_reg_en=1                                      | DIR + CHK | ESC 2, 6     | **PASS** |
| REQ-CTL-05  | EXECUTE: aluout_reg_en=1                                          | DIR + CHK | ESC 2, 6, 9  | **PASS** |
| REQ-CTL-06  | STORE: cpu_rdy=1, datain_reg_en=1                                 | DIR + CHK | ESC 2, 6, 9  | **PASS** |
| REQ-CTL-07  | cpu_rdy es pulso de 1 ciclo (solo activo en STORE)                | DIR + CHK | ESC 6        | **PASS** |
| REQ-CTL-08  | opcode = {1'b0, cmd_in[2:0]} (4 bits, MSB=0)                      | DIR + CHK | ESC 2, 3, 9  | **PASS** |
| REQ-CTL-09  | in_select_a = cmd_in[6:5], in_select_b = cmd_in[4:3]              | DIR + CHK | ESC 2        | **PASS** |
| REQ-CTL-10  | LOAD: memoryRead=1 y selmux2=1 en EXECUTE                         | DIR + CHK | ESC 3        | **PASS** |
| REQ-CTL-11  | STORE: memoryWrite=1 en STORE (fase final)                        | DIR + CHK | ESC 4        | **PASS** |
| REQ-CTL-12  | NOP0/NOP1: no accede memoria en ningun estado                     | DIR + CHK | ESC 5        | **PASS** |
| REQ-CTL-13  | ADD/SUB/MUL/DIV: no accede memoria                                 | DIR + CHK | ESC 2, 9     | **PASS** |
| REQ-CTL-14  | nvalid_data = p_error AND (muxA==11 OR muxB==11) en EXECUTE       | DIR + CHK | ESC 7        | **PASS** |
| REQ-CTL-15  | Interfaz cumple spec mandatorio                                    | REVIEW    | Diff con spec | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CON-01  | Reset mid-instruccion vuelve a RST_ST inmediatamente           | DIR + CHK | ESC 8        | **PASS** |
| REQ-CON-02  | Back-to-back instructions fluyen sin reset intermedio          | DIR + CHK | ESC 9        | **PASS** |
| REQ-CON-03  | p_error=1 sin feedback (muxA/B != 11): nvalid_data=0           | DIR + CHK | ESC 7        | **PASS** |
| REQ-CON-04  | p_error=0 con feedback: nvalid_data=0                          | DIR + CHK | ESC 7        | **PASS** |
| REQ-CON-05  | Ausencia de latches inferidos (always_comb con todos defaults) | REVIEW    | Compile      | **PASS** |
| REQ-CON-06  | Registro de estado usa reset asincrono correctamente           | REVIEW    | Diseno       | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                                          | Checks aprox |
| --------- | ------------------------------------------------------------------ | ------------ |
| ESC 1     | Reset asincrono lleva a RST_ST                                     | 6            |
| ESC 2     | Ciclo completo ADD (transiciones + outputs por estado)             | 14           |
| ESC 3     | Ciclo LOAD (memoryRead y selmux2 en EXECUTE)                       | 6            |
| ESC 4     | Ciclo STORE (memoryWrite en STORE)                                 | 5            |
| ESC 5     | NOP0/NOP1 no acceden memoria                                       | 5            |
| ESC 6     | cpu_rdy es pulso de 1 ciclo                                        | 5            |
| ESC 7     | nvalid_data con p_error + feedback (4 casos)                       | 4            |
| ESC 8     | Reset mid-instruccion vuelve a RST_ST                              | 4            |
| ESC 9     | Back-to-back instructions                                          | 6            |
| **Total** |                                                                    | **~55**      |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Todos los checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

## 6. Fase siguiente: env UVM

Este bloque va a ser el mas rico para verificacion UVM:
- Coverage: cada estado, cada opcode, transiciones de estado, cross con
  p_error, cross opcode x estado
- Sequences: mezcla aleatoria de opcodes, resets aleatorios, propagacion
  de p_error, casos borde
- Reference model: replica FSM en Python o SV

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **Diagramas del lab:** 4 imagenes (Reset, Fetch/Decode, Execute, Store)
- **RTL del DUT:** `rtl/control.sv`
- **TB standalone:** `sim/tb_control.sv`
