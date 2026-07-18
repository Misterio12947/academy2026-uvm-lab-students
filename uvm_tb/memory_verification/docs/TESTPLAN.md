# Memory — Test Plan (Standalone TB)

**Bloque:** `memory` (8 palabras de 2*WIDTH bits, write sincrono / read asincrono)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / memory_verification`
**Herramientas:** VCS V-2023.12-SP2-8
**Version del testplan:** 1.0 (standalone, pre-UVM)

## 1. Alcance

Este testplan formaliza la verificacion inicial (standalone SystemVerilog,
sin UVM) del bloque `memory`. El objetivo es validar el RTL contra la spec
del lab antes de invertir en el env UVM completo.

**Nota**: este documento cubre la validacion pre-UVM. Un TESTPLAN v2.0
formalizara la verificacion UVM cuando se implemente en la fase siguiente.

## 2. Features del DUT (segun spec)

| ID          | Feature                                        | Referencia spec           |
| ----------- | ---------------------------------------------- | ------------------------- |
| FEAT-MEM-01 | Memoria de 8 palabras                          | *"2*WIDTH per 8 words memory"* |
| FEAT-MEM-02 | Ancho de palabra = 2*WIDTH bits                | Idem                      |
| FEAT-MEM-03 | Escritura sincrona (posedge clk)               | *"synchronous for writing data"* |
| FEAT-MEM-04 | Lectura asincrona (combinacional)              | *"asynchronous for reading data"* |
| FEAT-MEM-05 | Enable de escritura (memoryWrite)              | *"a pin to enable the writing"* |
| FEAT-MEM-06 | Enable de lectura (memoryRead)                 | *"a pin to enable the reading"* |
| FEAT-MEM-07 | Interfaz mandatoria                            | *"Using the provided module interface is crucial and mandatory"* |

## 3. Matriz de requerimientos (validacion standalone)

**Metodo:** DIR (directed), CHK (self-check en TB).

### 3.1 Requerimientos funcionales

| ID          | Descripcion                                                       | Metodo    | Escenario TB   | Status |
| ----------- | ----------------------------------------------------------------- | --------- | -------------- | ------ |
| REQ-MEM-01  | Write en posedge clk cuando memoryWrite=1 captura data_in en addr | DIR + CHK | ESC 1, ESC 2   | **PASS** (tras ejecutar) |
| REQ-MEM-02  | Read asincrono: data_out = mem[addr] sin esperar clk              | DIR + CHK | ESC 5          | **PASS** |
| REQ-MEM-03  | memoryWrite=0 no modifica memoria (retencion)                     | DIR + CHK | ESC 3          | **PASS** |
| REQ-MEM-04  | memoryRead=0 fuerza data_out=0 (gating)                           | DIR + CHK | ESC 4          | **PASS** |
| REQ-MEM-05  | 8 palabras direccionables (0-7)                                   | DIR + CHK | ESC 2 (addr[7]) | **PASS** |
| REQ-MEM-06  | Ancho de datos 2*WIDTH bits (WIDTH=8 → 16 bits)                  | STR       | Compile OK     | **PASS** |
| REQ-MEM-07  | Interfaz cumple spec mandatorio                                   | REVIEW    | Diff con spec  | **PASS** |

### 3.2 Requerimientos de consistencia

| ID          | Descripcion                                                    | Metodo    | Escenario TB | Status |
| ----------- | -------------------------------------------------------------- | --------- | ------------ | ------ |
| REQ-CON-01  | Overwrite: escritura en misma addr sobreescribe valor previo   | DIR + CHK | ESC 6        | **PASS** |
| REQ-CON-02  | Lectura de posicion no escrita: comportamiento no verificado   | N/A       | (documentado como fuera de alcance) | N/A |
| REQ-CON-03  | Direcciones altas (>7) se enmascaran a los 3 LSB               | REVIEW    | Diseno explicito con addr[2:0] | **PASS** |

## 4. Escenarios del TB standalone

| Escenario | Proposito                                          | Checks |
| --------- | -------------------------------------------------- | ------ |
| ESC 1     | Write + read en misma direccion                    | 1      |
| ESC 2     | Multiples writes en varias direcciones + reads     | 4      |
| ESC 3     | memoryWrite=0 no modifica memoria                  | 1      |
| ESC 4     | memoryRead=0 fuerza data_out=0                     | 1      |
| ESC 5     | Lectura asincrona: cambio de addr sin clk          | 3      |
| ESC 6     | Overwrite: ultima escritura gana                   | 1      |
| **Total** |                                                    | **11** |

## 5. Criterios de aceptacion

Un run del TB standalone se considera PASS si:
- Los 11 checks reportan `[PASS]`
- El reporte final muestra `>>> ALL TESTS PASSED <<<`
- No hay warnings de compilacion en VCS

### Comando de sign-off

```bash
cd sim/
./run.sh
grep "ALL TESTS PASSED" sim.log
```

## 6. Siguiente fase: Env UVM

Con el RTL validado, se implementara un env UVM completo replicando la
estructura de `alu_verification/` y `regbank_verification/` con:
- Interface con memoryAddress, memoryWrite/Read, data_in/out
- Driver que emite writes sincronos y reads asincronos
- Monitor que samplea tanto en posedge clk (writes) como en cambios de addr (reads)
- Scoreboard con modelo de la memoria como array asociativo
- Covergroups: direcciones (8 bins), datos (rangos), cruces write/read

## 7. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/memory.sv`
- **TB standalone:** `sim/tb_memory.sv`
- **Script:** `sim/run.sh`
