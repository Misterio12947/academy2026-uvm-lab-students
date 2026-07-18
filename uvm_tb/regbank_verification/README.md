# Register Bank UVM Verification

Entorno UVM para verificar el `register_bank` (registro D con enable y reset
asincrono activo alto) del laboratorio Synopsys.

## Estructura del proyecto

```
regbank_verification/
├── README.md
├── rtl/
│   └── register_bank.sv        # DUT
├── tb/
│   ├── regbank_if.sv           # Interface (rst separado del cb)
│   ├── regbank_transaction.sv  # Sequence item
│   ├── regbank_driver.sv       # Driver con reset_dut() explicito
│   ├── regbank_monitor.sv      # Monitor con sample post-edge
│   ├── regbank_coverage.sv     # Coverage funcional (3 covergroups)
│   ├── regbank_agent.sv
│   ├── regbank_scoreboard.sv   # Con estado interno model_reg
│   ├── regbank_env.sv
│   ├── regbank_pkg.sv
│   ├── regbank_seq_rand.sv     # 1000 tx aleatorias
│   ├── regbank_directed_seq.sv # Casos borde
│   ├── regbank_reset_seq.sv    # Escenarios de reset
│   ├── regbank_coverage_seq.sv # Closure de covergroups
│   ├── regbank_test.sv         # 5 tests (base, random, directed, reset, coverage, regression)
│   ├── regbank_test_pkg.sv
│   └── testbench.sv
├── sim/
│   ├── Makefile
│   ├── filelist.f
│   ├── cm_hier.cfg
│   ├── tb_register_bank.sv     # TB standalone (validacion previa al env UVM)
│   └── run.sh                  # Script del standalone
└── docs/
    └── TESTPLAN.md
```

## Uso

```bash
cd sim/

# Regresion completa: los 4 tests acumulados + reporte
make regress

# Test individual
make compile
make sim TEST=regbank_reset_test
make cov
```

## Tests disponibles

| Test                       | Proposito                                                |
| -------------------------- | -------------------------------------------------------- |
| `regbank_random_test`      | 1000 transacciones aleatorias                            |
| `regbank_directed_test`    | Casos borde (writes, hold, back-to-back)                 |
| `regbank_reset_test`       | Escenarios de reset asincrono (5 subescenarios)          |
| `regbank_coverage_test`    | Closure de covergroups                                   |
| `regbank_regression_test`  | Encadena los 4 en una sola simulacion                    |

## Metodologia clave

- **RTL corregido**: reset asincrono activo alto (spec original decia `if (!rst)` — cambiamos a activo alto por convencion industrial y consistencia con el resto del top del CPU).
- **Validacion pre-UVM**: standalone TB con 6 escenarios criticos (18/18 checks PASS) antes de invertir en el env.
- **Interface con reset fuera del clocking block**: rst es asincrono por definicion, no puede sincronizarse.
- **Scoreboard con estado interno (opcion A)**: `model_reg` reactive, actualizado igual que el DUT en cada tx recibida.
- **Warmup de 4 ciclos**: sincroniza el modelo con el reset inicial del driver antes de empezar checks.
- **Coverage funcional**: 3 covergroups (`cg_regbank`, `cg_transitions`, `cg_hold_duration`).
- **Waivers**: pragmas `// VCS coverage off/on` en el watchdog del testbench.

## Sign-off

Ver `docs/TESTPLAN.md` para la matriz de trazabilidad completa y criterios
de aceptacion.
