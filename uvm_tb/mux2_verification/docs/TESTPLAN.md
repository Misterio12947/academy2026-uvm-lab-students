# mux2 — Test Plan (Standalone TB)

**Bloque:** `mux2` (multiplexor 2:1 parametrizado, combinacional)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / mux2_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Validacion inicial (standalone SystemVerilog) del `mux2`, modulo **derivado**
necesario para el top del CPU (la senal `selmux2` del control unit demanda
un multiplexor 2:1 de ancho 2*WIDTH).

**Nota**: el `mux2` NO aparece en la spec explicita del Lab I, pero es un
bloque de infraestructura requerido para completar el top del proyecto. Se
verifica con el mismo rigor que los modulos formales del lab, siguiendo la
convencion establecida: incluso los modulos derivados/triviales requieren
testplan formal.

## 2. Features del DUT

| ID          | Feature                                        | Referencia                       |
| ----------- | ---------------------------------------------- | -------------------------------- |
| FEAT-MUX2-01 | 2 entradas de datos                            | `input [WIDTH-1:0] din1, din2`   |
| FEAT-MUX2-02 | Salida = una de las 2 entradas segun select    | Derivado del patron de mux4      |
| FEAT-MUX2-03 | Ancho parametrizable (default WIDTH=8)         | Consistencia con mux4/regbank    |
| FEAT-MUX2-04 | Combinacional (sin registro de salida)         | Sera envuelto en mux2_registered |
| FEAT-MUX2-05 | Interfaz consistente con convenciones del proyecto | Alineado con mux4            |

## 3. Matriz de requerimientos

**Metodo:** DIR (directed), CHK (self-check en TB), STR (structural), REVIEW.

### 3.1 Requerimientos funcionales

| ID           | Descripcion                                          | Metodo    | Escenario TB   | Status |
| ------------ | ---------------------------------------------------- | --------- | -------------- | ------ |
| REQ-MUX2-01  | select=1'b0 -> dout = din1                           | DIR + CHK | ESC 1, 2, 3, 5 | **PASS** (tras run) |
| REQ-MUX2-02  | select=1'b1 -> dout = din2                           | DIR + CHK | ESC 1, 2, 3, 5 | **PASS** |
| REQ-MUX2-03  | WIDTH parametrizable (probado con WIDTH=8)           | STR       | Compile OK     | **PASS** |
| REQ-MUX2-04  | Salida combinacional (cambio de select refleja sin clk) | DIR + CHK | ESC 2, 6    | **PASS** |
| REQ-MUX2-05  | Interfaz consistente con mux4                        | REVIEW    | Convencion     | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CON-01  | Ausencia de latches inferidos (always_comb con todas ramas)   | REVIEW    | Compile      | **PASS** |
| REQ-CON-02  | Independencia entre entradas: cambio en din no seleccionada    | DIR + CHK | ESC 4        | **PASS** |
|             | no afecta dout                                                 |           |              |        |
| REQ-CON-03  | Robustez frente a toggle rapido de select                     | DIR + CHK | ESC 6        | **PASS** |
| REQ-CON-04  | Valores extremos (all-zero, all-one) se propagan correctamente | DIR + CHK | ESC 3        | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                              | Checks |
| --------- | ------------------------------------------------------ | ------ |
| ESC 1     | Cada select individual con valores distintivos por din | 2      |
| ESC 2     | Cambio dinamico de select (combinacional)              | 3      |
| ESC 3     | Valores extremos (all-zero, all-one)                   | 2      |
| ESC 4     | Independencia de entradas no seleccionadas             | 4      |
| ESC 5     | Barrido con patrones alternados                        | 4      |
| ESC 6     | Toggle rapido de select (stress combinacional)         | 1      |
| **Total** |                                                        | **16** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Los 16 checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

### Comando de sign-off

```bash
cd sim/
./run.sh
grep "ALL TESTS PASSED" sim.log
```

## 6. Fase siguiente: env UVM

Env UVM enfocado en:
- Coverage: 2 bins de select, cross con rangos de din1/din2
- Sequences: random y directed con valores extremos
- Estructura identica al env del mux4 (adaptado a select de 1 bit)

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/mux2.sv`
- **TB standalone:** `sim/tb_mux2.sv`
- **Modulo consumidor:** `mux2_registered` (por implementar) y `top` del CPU
