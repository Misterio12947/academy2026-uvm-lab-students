# Register Bank — Test Plan

**Bloque:** `register_bank` (registro D con enable y reset asincrono activo alto)
**Documento de referencia:** RTL and Verification Lab — Synopsys, Octubre 2025
**Verificado bajo:** `academy2026-uvm-lab / uvm_tb / regbank_verification`
**Herramientas:** VCS V-2023.12-SP2-8, UVM-1.2, URG, Verdi
**Version del testplan:** 1.0

---

## 1. Alcance

Este testplan formaliza la verificacion funcional del `register_bank`
parametrizado del laboratorio. Documenta requerimientos, metodo, tests, y
coverpoints con trazabilidad completa.

**Nota arquitectural**: aunque el nombre "register bank" sugiere un banco de
N registros direccionables, la interfaz mandatoria del lab no incluye
address ni parametro de profundidad. Arquitecturalmente es un **unico
registro D-type parametrizado en WIDTH**. El nombre se conserva por respeto
a la spec del lab.

## 2. Features del DUT (segun spec)

| ID          | Feature                                        | Referencia spec           |
| ----------- | ---------------------------------------------- | ------------------------- |
| FEAT-RB-01  | Registro D operando en posedge clk             | *"Operate on positive edge of the clock (clk)"* |
| FEAT-RB-02  | Reset asincrono                                | *"Have an Asynchronous reset (rst)"* |
| FEAT-RB-03  | Enable de escritura (wr_en)                    | *"Have an enable signal (wr_en) which allows data capturing only when asserted"* |
| FEAT-RB-04  | Retencion (hold) cuando wr_en=0                | Implicito por (03): "only when asserted" |
| FEAT-RB-05  | WIDTH parametrizable                           | `parameter WIDTH = 8`     |
| FEAT-RB-06  | Interfaz mandatoria                            | *"Using the provided module interface is crucial and mandatory"* |

## 3. Matriz de requerimientos

**Leyenda de metodos:**
- **DIR**: Directed test
- **RND**: Random test
- **SCB**: Verificado por reference model del scoreboard
- **COV**: Cerrado por functional coverage
- **STR**: Cerrado por structural coverage

### 3.1 Requerimientos funcionales

| ID         | Descripcion                                                    | Metodo         | Test / Sequence                              | Coverpoint / Evidence                                  | Status |
| ---------- | -------------------------------------------------------------- | -------------- | -------------------------------------------- | ------------------------------------------------------ | ------ |
| REQ-RB-01  | Registro D captura en posedge clk cuando wr_en=1                | DIR + RND + SCB + COV | `regbank_directed_seq` (writes), `regbank_seq_rand`, `regbank_coverage_seq` | `cg_regbank.cx_wr_en_rst.wr_en_high_rst_low`, `cp_in`  | **TBD** |
| REQ-RB-02  | Reset asincrono (activo alto) fuerza out=0 sin depender de clk | DIR + RND + SCB + COV | `regbank_reset_seq`, `regbank_seq_rand` (5% resets), standalone TB ESC 1/6 | `cg_regbank.cp_rst.high`, `cg_transitions.cp_action.reset_only` | **TBD** |
| REQ-RB-03  | Enable wr_en: captura de in SOLO cuando wr_en=1                | DIR + RND + SCB + COV | `regbank_directed_seq` (bloque hold), `regbank_seq_rand` | `cg_regbank.cx_wr_en_rst`, `cg_transitions.cp_transitions.hold_to_write` | **TBD** |
| REQ-RB-04  | Retencion: con wr_en=0 y rst=0, out mantiene valor previo      | DIR + RND + SCB + COV | `regbank_directed_seq` (hold sostenido), `regbank_coverage_seq` (varias duraciones) | `cg_hold_duration.cp_hold_len.{one_cycle,short_hold,medium_hold,long_hold}` | **TBD** |
| REQ-RB-05  | WIDTH parametrizado (probado en WIDTH=8)                       | STR            | Todos los tests (WIDTH=8 en `regbank_pkg::WIDTH`) | Compile OK; parametro reutilizable                     | **TBD** |
| REQ-RB-06  | Interfaz cumple spec mandatorio                                | REVIEW         | Diff con spec del lab                        | Ports 1:1 con spec (verificado manual)                 | **TBD** |

### 3.2 Requerimientos de consistencia / robustez

Requerimientos derivados por analisis:

| ID          | Descripcion                                                          | Metodo    | Test / Sequence                          | Coverpoint / Evidence                                    | Status |
| ----------- | -------------------------------------------------------------------- | --------- | ---------------------------------------- | -------------------------------------------------------- | ------ |
| REQ-CON-01  | Reset domina sobre wr_en (rst=1 + wr_en=1 → out=0)                  | DIR + COV | `regbank_reset_seq`, `regbank_coverage_seq` | `cg_regbank.cx_wr_en_rst.wr_en_high_rst_high`           | **TBD** |
| REQ-CON-02  | Reset dispara asincronamente (fuera de flanco de clk)                | DIR       | Standalone TB ESC 6                      | Verificado pre-UVM (18/18 checks PASS)                   | **TBD** |
| REQ-CON-03  | Back-to-back writes en ciclos consecutivos con valores distintos     | DIR + SCB | `regbank_directed_seq` (patrones 0x11..0x44) | `cg_transitions.cp_transitions.write_to_write`          | **TBD** |
| REQ-CON-04  | Hold sostenido: valor se mantiene durante N ciclos con wr_en=0       | DIR + COV | `regbank_coverage_seq` (1, 3, 10, 25 ciclos) | `cg_hold_duration.cp_hold_len` (4 bins)                | **TBD** |
| REQ-CON-05  | Transiciones criticas: hold->write, write->hold, write->reset, etc.  | COV       | `regbank_seq_rand` + `regbank_coverage_seq` | `cg_transitions.cp_transitions` (8 bins)                | **TBD** |
| REQ-CON-06  | Reset seguido de write inmediato: primer valor post-reset se captura | DIR + SCB | `regbank_reset_seq` (escenario E)          | Scoreboard verifica en cada tx                          | **TBD** |
| REQ-CON-07  | Multiples resets consecutivos: comportamiento idempotente            | DIR + SCB | `regbank_reset_seq` (escenario B)          | Scoreboard verifica en cada tx                          | **TBD** |
| REQ-CON-08  | Valor `in` cubre rangos: zero/low/mid/high/max                       | COV       | `regbank_coverage_seq` + `regbank_seq_rand` | `cg_regbank.cp_in` (5 bins)                            | **TBD** |
| REQ-CON-09  | Valor `out` alcanza rangos: zero/low/mid/high/max                    | COV       | Todos los tests                          | `cg_regbank.cp_out` (5 bins)                             | **TBD** |

---

## 4. Plan de coverage

### 4.1 Functional coverage — `regbank_coverage.sv`

**`cg_regbank`** — cobertura del comportamiento normal:
- `cp_wr_en` (2 bins): wr_en en 0 y 1
- `cp_rst` (2 bins): rst en 0 y 1
- `cx_wr_en_rst` (4 bins): cross wr_en x rst — cubre las 4 combinaciones incluyendo el caso "reset domina" (REQ-CON-01)
- `cp_in` (5 bins con guard `iff (wr_en && !rst)`): rangos del valor escrito
- `cp_out` (5 bins): rangos del valor observado

**`cg_transitions`** — cobertura de transiciones entre ciclos consecutivos:
- `cp_action` (4 bins): hold, write, reset_only, reset_write
- `cp_transitions` (8 bins): transiciones criticas entre acciones (hold→write, write→hold, write→reset, etc.)

**`cg_hold_duration`** — cobertura de duracion de retencion (REQ-CON-04):
- `cp_hold_len` (4 bins): one_cycle, short_hold (2-5), medium_hold (6-20), long_hold (21+)

**Meta:** 100% en los 3 covergroups.

### 4.2 Structural coverage — VCS `-cm`

Metricas: `line + cond + fsm + tgl + branch + assert`.
Filtrado a DUT + testbench con `sim/cm_hier.cfg`.

**Meta:** >= 99% score en `testbench` (incluye `dut`).

### 4.3 Holes de coverage esperados (a documentar cuando se corra)

- Watchdog `uvm_fatal` en `testbench.sv`: excluido con pragma `// VCS coverage off`
- Signal `assert_reset` en el transaction no aparece en `out` (es una señal de control interna del env)

---

## 5. Metodologia de verificacion

### 5.1 Stimulus generation

Cuatro niveles de estimulos:

1. **`regbank_seq_rand`**: 1000 transacciones aleatorias
2. **`regbank_directed_seq`**: casos borde derivados del standalone TB (writes con valores extremos, hold sostenido, back-to-back writes, toggle write/hold)
3. **`regbank_reset_seq`**: 5 escenarios especificos de reset (simple, doble, durante hold, seguido de write, con rafaga posterior)
4. **`regbank_coverage_seq`**: closure exhaustivo con holds de 1/3/10/25 ciclos y todas las transiciones criticas

### 5.2 Response checking

**Scoreboard con reference model estado-completo** (`regbank_scoreboard.sv`):
- Mantiene `model_reg` que se actualiza con `predict(current, rst, wr_en, in)`
- Metodologia reactive model (opcion A): recibe tx del monitor, predice next state, compara `tx.out` contra el estado esperado, actualiza `model_reg`
- Warmup de 4 ciclos antes de empezar a checkear (sincronizacion con el reset inicial del driver)

### 5.3 Testbench synchronization

- Driver hace reset inicial (rst=1 por 3 ciclos) en `run_phase`
- Interface separa reset (asincrono, fuera de clocking block) de las senales sincronas
- Monitor con `input #1` post-edge para capturar `out` ya actualizado
- Filtro `$isunknown` en el monitor
- Driver mantiene resets inyectados por >= 2 ciclos (garantiza que el rst sea visible en al menos un edge del monitor)

### 5.4 Simplificacion documentada

El env UVM ejercita **resets alineados a ciclos completos**. Resets asincronos mid-cycle (fuera de flanco de clk) NO se ejercitan a nivel UVM porque introducirian complejidad de sync en el scoreboard. El **standalone TB** (fuera del env UVM, `sim/tb_register_bank.sv` en el commit previo) ya valida el comportamiento mid-cycle en el ESC 6.

---

## 6. Criterios de aceptacion (Pass/Fail)

Un run del **`regbank_regression_test`** se considera PASS solo si:

- [ ] **Scoreboard:** `num_errors == 0` en todos los tests
- [ ] **Functional coverage:** `cg_regbank`, `cg_transitions`, `cg_hold_duration` == 100.00%
- [ ] **Structural coverage:** score `testbench` >= 99%
- [ ] **Tests individuales:** los 5 tests terminan con `UVM_ERROR: 0` y `UVM_FATAL: 0`
- [ ] **Trazabilidad:** todos los requerimientos de las secciones 3.1 y 3.2 estan en PASS
- [ ] **Standalone TB previo:** 18/18 checks PASS (validacion pre-UVM del RTL)

### Comando de sign-off

```bash
cd uvm_tb/regbank_verification/sim
make clean && make regress
```

---

## 7. Sign-off status

| Fecha       | Version | Estado    | Firma / Verificador           |
| ----------- | ------- | --------- | ----------------------------- |
| 2026-07-15  | 1.0     | ⏳ Pending validacion | Cesar Otamendi — Ing. VLSI |

**Sera actualizado con los resultados de la primera regresion exitosa.**

---

## 8. Referencias

- **Spec del lab:** RTL and Verification Lab — Synopsys, Octubre 2025
- **RTL del DUT:** `rtl/register_bank.sv`
- **Standalone TB (validacion previa):** commit anterior a la infra UVM
- **Env UVM:** `tb/regbank_*.sv`
- **Flujo:** `sim/Makefile`
- **Reporte de coverage:** `sim/cov_report/dashboard.html`
