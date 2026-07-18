# mux4_registered — Test Plan (Standalone TB)

**Bloque:** `mux4_registered` (mux4 + register_bank, compuesto secuencial)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux4_registered_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion inicial (standalone SystemVerilog) del `mux4_registered`, bloque
compuesto que integra:
- `mux4` (combinacional 4:1 parametrizado) — verificado en `mux4_verification/`
- `register_bank` (registro D con enable y reset asincrono activo alto) —
  verificado en `regbank_verification/`

**Enfoque de verificacion**: los submodulos ya fueron firmados por separado
con sus propios testplans. Este TB se enfoca en verificar la **composicion
correcta**: que el mux drivea al registro, que el registro captura solo en
posedge clk con wr_en=1, y que el reset asincrono propaga a la salida.

## 2. Features del DUT (segun spec)

| ID           | Feature                                                    | Referencia spec |
| ------------ | ---------------------------------------------------------- | --------------- |
| FEAT-MUXR-01 | 4 entradas de datos y select de 2 bits                     | Lab I mux4_registered |
| FEAT-MUXR-02 | Salida registrada (sincrona)                                | *"synchronous output"* |
| FEAT-MUXR-03 | Reset asincrono activo alto                                 | Interfaz mandatoria + convencion del top del CPU |
| FEAT-MUXR-04 | Enable de captura (wr_en): solo captura cuando esta activo  | Interfaz mandatoria |
| FEAT-MUXR-05 | WIDTH parametrizable                                         | *"variable (parameterized) width"* |
| FEAT-MUXR-06 | Interfaz mandatoria                                          | *"Using the provided module interface is crucial and mandatory"* |

## 3. Matriz de requerimientos

**Metodo:** DIR (directed), CHK (self-check en TB), STR (structural), REVIEW.

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ------------ | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-MUXR-01  | Reset asincrono fuerza out=0 sin depender de clk                  | DIR + CHK | ESC 1, 4     | **PASS** (tras run) |
| REQ-MUXR-02  | Con wr_en=1 en posedge clk: out = din[sel] del ciclo anterior     | DIR + CHK | ESC 2, 5     | **PASS** |
| REQ-MUXR-03  | Con wr_en=0: out mantiene valor previo (hold), ignora cambios sel | DIR + CHK | ESC 3        | **PASS** |
| REQ-MUXR-04  | Reset domina sobre wr_en (rst=1 + wr_en=1 -> out=0)               | DIR + CHK | ESC 4        | **PASS** |
| REQ-MUXR-05  | WIDTH parametrizable (probado con WIDTH=8)                        | STR       | Compile OK   | **PASS** |
| REQ-MUXR-06  | Interfaz cumple spec mandatorio                                    | REVIEW    | Diff con spec | **PASS** |

### 3.2 Requerimientos de composicion

| ID           | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ------------ | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-COM-01   | mux4 drivea correctamente al register_bank via wire interno    | REVIEW    | Diseno       | **PASS** |
| REQ-COM-02   | Cambio de din de entrada seleccionada NO afecta out durante hold | DIR + CHK | ESC 6      | **PASS** |
| REQ-COM-03   | Cambio de din tras activar wr_en si SE captura correctamente   | DIR + CHK | ESC 6        | **PASS** |
| REQ-COM-04   | Los 4 selects son alcanzables y capturables en back-to-back    | DIR + CHK | ESC 5        | **PASS** |
| REQ-COM-05   | Post-reset con wr_en=1 captura correctamente en el sig. edge   | DIR + CHK | ESC 4        | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                                          | Checks |
| --------- | ------------------------------------------------------------------ | ------ |
| ESC 1     | Reset asincrono al arranque fuerza out=0                           | 2      |
| ESC 2     | Captura de cada select (00, 01, 10, 11) con wr_en=1                | 4      |
| ESC 3     | Hold con wr_en=0: cambios de sel no afectan out                    | 2      |
| ESC 4     | Reset mid-operacion domina sobre wr_en, recuperacion post-reset    | 3      |
| ESC 5     | Back-to-back writes con distintos selects                          | 4      |
| ESC 6     | Cambio de din de entrada seleccionada durante hold vs con wr_en    | 2      |
| **Total** |                                                                    | **17** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Los 17 checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

### Comando de sign-off

```bash
cd sim/
./run.sh
grep "ALL TESTS PASSED" sim.log
```

## 6. Dependencias RTL (single source of truth)

Este bloque NO duplica RTL de otros bloques. El `filelist.f` referencia:

- `../../mux4_verification/rtl/mux4.sv`
- `../../regbank_verification/rtl/register_bank.sv`

**Politica**: si un submodulo cambia en su bloque origen, este TB debe
re-ejecutarse para validar que la composicion sigue firmada. Es la ventaja
de single source of truth: se garantiza consistencia entre bloques al costo
de re-verificar composiciones cuando cambia una dependencia.

## 7. Fase siguiente: env UVM

Con el RTL validado, se implementara un env UVM completo enfocado en:
- Coverage: crosses `select x wr_en x rst`, transiciones de estado (write ->
  hold -> write, reset durante write, etc.)
- Sequences: mezcla de captura, hold, reset, con distintos patrones de din

## 8. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux4_registered.sv`
- **RTL dependencias:** `mux4_verification/rtl/mux4.sv`, `regbank_verification/rtl/register_bank.sv`
- **TB standalone:** `sim/tb_mux4_registered.sv`
