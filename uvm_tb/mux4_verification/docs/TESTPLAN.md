# mux4 — Test Plan (Standalone TB)

**Bloque:** `mux4` (multiplexor 4:1 parametrizado, combinacional)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux4_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion inicial (standalone SystemVerilog) del mux4 antes de la fase UVM.
El mux4 es uno de los bloques mas simples del lab, pero se documenta con el
mismo rigor que los demas para servir como plantilla didactica: incluso los
modulos triviales requieren testplan formal, matriz de trazabilidad y
criterios de aceptacion explicitos.

## 2. Features del DUT (segun spec)

| ID          | Feature                                        | Referencia spec                  |
| ----------- | ---------------------------------------------- | -------------------------------- |
| FEAT-MUX4-01 | 4 entradas de datos                            | `input [WIDTH-1:0] din1..din4`   |
| FEAT-MUX4-02 | Salida = una de las 4 entradas segun select    | *"4-input multiplexer (mux)"*    |
| FEAT-MUX4-03 | Ancho parametrizable (default WIDTH=8)         | *"variable (parameterized) input and output bus width"* |
| FEAT-MUX4-04 | Combinacional (sin registro de salida)         | Idem — el spec pide mux4_registered aparte |
| FEAT-MUX4-05 | Interfaz mandatoria                            | *"Using the provided module interface is crucial and mandatory"* |

## 3. Matriz de requerimientos

**Metodo:** DIR (directed), CHK (self-check en TB), STR (structural).

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                          | Metodo    | Escenario TB | Status |
| ------------ | ---------------------------------------------------- | --------- | ------------ | ------ |
| REQ-MUX4-01  | select=2'b00 -> dout = din1                          | DIR + CHK | ESC 1, 2, 3, 5 | **PASS** (tras run) |
| REQ-MUX4-02  | select=2'b01 -> dout = din2                          | DIR + CHK | ESC 1, 2, 5    | **PASS** |
| REQ-MUX4-03  | select=2'b10 -> dout = din3                          | DIR + CHK | ESC 1, 2, 5    | **PASS** |
| REQ-MUX4-04  | select=2'b11 -> dout = din4                          | DIR + CHK | ESC 1, 2, 3, 5 | **PASS** |
| REQ-MUX4-05  | WIDTH parametrizable (probado con WIDTH=8)           | STR       | Compile OK   | **PASS** |
| REQ-MUX4-06  | Salida combinacional (cambio de select refleja sin clk) | DIR + CHK | ESC 2, 6     | **PASS** |
| REQ-MUX4-07  | Interfaz cumple spec mandatorio                       | REVIEW    | Diff con spec | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CON-01  | Ausencia de latches inferidos (always_comb con todas ramas)   | REVIEW    | Compile      | **PASS** |
| REQ-CON-02  | Independencia entre entradas: cambio en din no seleccionada    | DIR + CHK | ESC 4        | **PASS** |
|             | no afecta dout                                                 |           |              |        |
| REQ-CON-03  | Robustez frente a cambios rapidos de select (glitch-free)     | DIR + CHK | ESC 6        | **PASS** |
| REQ-CON-04  | Valores extremos (all-zero, all-one) se propagan correctamente | DIR + CHK | ESC 3        | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                              | Checks |
| --------- | ------------------------------------------------------ | ------ |
| ESC 1     | Cada select individual con valores distintivos por din | 4      |
| ESC 2     | Cambio dinamico de select (combinacional)              | 4      |
| ESC 3     | Valores extremos (all-zero, all-one)                   | 2      |
| ESC 4     | Independencia de entradas no seleccionadas             | 2      |
| ESC 5     | Barrido con patrones alternados                        | 4      |
| ESC 6     | Cambios rapidos (stress combinacional)                 | 1      |
| **Total** |                                                        | **17** |

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

## 6. Fase siguiente: env UVM

Con el RTL validado, se implementara un env UVM completo replicando la
estructura de `alu_verification/`. Aunque el mux4 es simple, el env UVM
demuestra el patron completo con:
- Interface con las 4 entradas y select
- Sequence item con constraints de rangos
- Scoreboard con reference model trivial (seleccion directa)
- Covergroups: los 4 selects, cross select x rangos de din

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux4.sv`
- **TB standalone:** `sim/tb_mux4.sv`
