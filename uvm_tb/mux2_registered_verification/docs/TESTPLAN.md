# mux2_registered — Test Plan (Standalone TB)

**Bloque:** `mux2_registered` (mux2 + register_bank con bus 2*WIDTH)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux2_registered_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion inicial (standalone SystemVerilog) del `mux2_registered`, bloque
compuesto **derivado** que integra:
- `mux2` (combinacional 2:1 parametrizado) — verificado en `mux2_verification/`
- `register_bank` (registro D con enable y reset asincrono) instanciado con
  `WIDTH = 2*WIDTH_EXTERNO` — verificado en `regbank_verification/`

**Nota**: el `mux2_registered` NO aparece en la spec del Lab I, pero es
necesario para el top del CPU. Su bus de datos es de **2*WIDTH bits** (16
bits con WIDTH=8) para acomodar las salidas de la ALU y los datos hacia
memoria en el CPU multiciclo.

**Enfoque de verificacion**: submodulos ya firmados por separado con sus
testplans. Este TB se enfoca en verificar la **composicion correcta con
ancho de bus 2*WIDTH**, incluyendo:
- Parametrizacion correcta del register_bank interno con 2*WIDTH
- Composicion mux2 + regbank equivalente al patron del mux4_registered
- Compatibilidad de la interfaz con el uso en el top del CPU

## 2. Features del DUT

| ID            | Feature                                                    | Referencia                       |
| ------------- | ---------------------------------------------------------- | -------------------------------- |
| FEAT-M2R-01   | 2 entradas de datos de 2*WIDTH bits                        | Necesidad del top del CPU        |
| FEAT-M2R-02   | Salida registrada de 2*WIDTH bits (sincrona)                | Patron de mux4_registered        |
| FEAT-M2R-03   | Reset asincrono activo alto                                  | Convencion del top del CPU       |
| FEAT-M2R-04   | Enable de captura (wr_en)                                    | Consistencia con mux4_registered |
| FEAT-M2R-05   | WIDTH externo parametrizable, bus interno automaticamente 2*WIDTH | Composicion parametrica     |
| FEAT-M2R-06   | Interfaz consistente con mux4_registered                     | Convencion del proyecto          |

## 3. Matriz de requerimientos

**Metodo:** DIR (directed), CHK (self-check en TB), STR (structural), REVIEW.

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ------------ | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-M2R-01   | Reset asincrono fuerza out=0 sin depender de clk                  | DIR + CHK | ESC 1, 4     | **PASS** (tras run) |
| REQ-M2R-02   | Con wr_en=1 en posedge clk: out = din[sel] del ciclo anterior     | DIR + CHK | ESC 2, 5     | **PASS** |
| REQ-M2R-03   | Con wr_en=0: out mantiene valor previo (hold), ignora cambios sel | DIR + CHK | ESC 3        | **PASS** |
| REQ-M2R-04   | Reset domina sobre wr_en (rst=1 + wr_en=1 -> out=0)               | DIR + CHK | ESC 4        | **PASS** |
| REQ-M2R-05   | WIDTH externo=8 -> bus interno de 16 bits                          | STR       | Compile OK   | **PASS** |
| REQ-M2R-06   | Interfaz consistente con mux4_registered                          | REVIEW    | Diff con mux4_registered | **PASS** |

### 3.2 Requerimientos de composicion

| ID          | Descripcion                                                       | Metodo    | Escenario TB | Status |
| ----------- | ----------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-COM-01  | mux2 drivea correctamente al register_bank con bus de 2*WIDTH     | REVIEW    | Diseno       | **PASS** |
| REQ-COM-02  | Cambio de din de entrada seleccionada NO afecta out durante hold  | DIR + CHK | ESC 6        | **PASS** |
| REQ-COM-03  | Cambio de din tras activar wr_en si SE captura correctamente      | DIR + CHK | ESC 6        | **PASS** |
| REQ-COM-04  | Ambos selects son alcanzables y capturables en back-to-back        | DIR + CHK | ESC 5        | **PASS** |
| REQ-COM-05  | Post-reset con wr_en=1 captura correctamente en el sig. edge      | DIR + CHK | ESC 4        | **PASS** |
| REQ-COM-06  | Parametrizacion del bus a 2*WIDTH funciona correctamente          | STR + DIR | Todos los ESC | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                                          | Checks |
| --------- | ------------------------------------------------------------------ | ------ |
| ESC 1     | Reset asincrono al arranque fuerza out=0                           | 2      |
| ESC 2     | Captura de cada select (0, 1) con wr_en=1                          | 2      |
| ESC 3     | Hold con wr_en=0: cambios de sel no afectan out                    | 2      |
| ESC 4     | Reset mid-operacion domina sobre wr_en, recuperacion post-reset    | 3      |
| ESC 5     | Back-to-back writes alternando selects                             | 4      |
| ESC 6     | Cambio de din durante hold vs con wr_en=1                          | 2      |
| **Total** |                                                                    | **15** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Los 15 checks reportan `[PASS]`
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

- `../../mux2_verification/rtl/mux2.sv`
- `../../regbank_verification/rtl/register_bank.sv`

**Politica**: si un submodulo cambia en su bloque origen, este TB debe
re-ejecutarse para validar que la composicion sigue firmada.

## 7. Nota sobre el ancho parametrizable

El parametro externo `WIDTH` refiere al ancho **base** del proyecto (default 8).
Internamente, este bloque instancia sus submodulos con `WIDTH_INTERNO = 2*WIDTH`
porque el bus de datos requerido por el top del CPU es de 2*WIDTH bits. Esta
convencion es consistente con la ALU (que produce `out` de 2*WIDTH bits) y
con la memoria (que almacena palabras de 2*WIDTH bits).

## 8. Fase siguiente: env UVM

Env UVM enfocado en:
- Coverage: 2 bins de select, cross con wr_en x rst
- Sequences: mezcla de captura, hold, reset con valores extremos del bus 16-bit
- Estructura identica al env del mux4_registered

## 9. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux2_registered.sv`
- **RTL dependencias:** `mux2_verification/rtl/mux2.sv`, `regbank_verification/rtl/register_bank.sv`
- **TB standalone:** `sim/tb_mux2_registered.sv`
- **Modulo hermano:** `mux4_registered` (verificado previamente)
