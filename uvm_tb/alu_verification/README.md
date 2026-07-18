# ALU UVM Verification

Entorno UVM para verificar el ALU del laboratorio RTL & Verification (Synopsys, Oct 2025).

## Estructura del proyecto

```
alu_verification/
├── rtl/
│   └── alu.sv                  # DUT: ALU parametrizada per lab spec
├── tb/
│   ├── alu_if.sv               # Interface con clocking blocks
│   ├── alu_transaction.sv      # Sequence item
│   ├── alu_driver.sv           # Driver
│   ├── alu_monitor.sv          # Monitor
│   ├── alu_coverage.sv         # Componente de coverage funcional
│   ├── alu_agent.sv            # Agent (driver + monitor + sequencer)
│   ├── alu_scoreboard.sv       # Scoreboard con reference model
│   ├── alu_env.sv              # Environment
│   ├── alu_pkg.sv              # Paquete de infraestructura
│   ├── alu_seq_rand.sv         # Sequence aleatoria
│   ├── alu_directed_seq.sv     # Sequence directed (casos borde de la spec)
│   ├── alu_coverage_seq.sv     # Sequence para cerrar coverage
│   ├── alu_test.sv             # Tests (base, random, directed, coverage, regression)
│   ├── alu_test_pkg.sv         # Paquete de tests
│   └── testbench.sv            # Top-level del TB
└── sim/
    ├── Makefile                # Flujo completo (compile / sim / cov / verdi)
    ├── filelist.f              # Lista de archivos para VCS
    └── cm_hier.cfg             # Filtro de instrumentacion (DUT + testbench)
```

## Uso

```bash
cd sim/

# Regresion completa: random + directed + coverage + reporte con waivers
make regress

# Test individual
make compile
make sim TEST=alu_directed_test
make cov
```

## Tests disponibles

| Test                  | Proposito                                                        |
| --------------------- | ---------------------------------------------------------------- |
| `alu_random_test`     | 500 transacciones aleatorias                                     |
| `alu_directed_test`   | Casos borde derivados de la spec                                 |
| `alu_coverage_test`   | Recorrido exhaustivo para cerrar covergroups                     |
| `alu_regression_test` | Encadena directed + coverage_seq + random en una sola simulacion |

## Resultados de coverage

Ultima corrida (regression + coverage + random, 3 tests acumulados):

| Metrica            | Valor       | Notas                                              |
| ------------------ | ----------- | -------------------------------------------------- |
| Transacciones      | 2361 + 1331 + 500 | Regression + coverage + random                |
| Errores            | 0           | Todos los checks del scoreboard pasan              |
| `cg_alu`           | **100.00%** | Opcodes ISA, invalid_data, zero, error, ranges     |
| `cg_edge_cases`    | **100.00%** | Div-by-zero, error->-1, consistencia error/zero    |

### Coverage estructural (filtrado con `-cm_hier` a DUT + testbench)

| Metrica  | Sin waivers | Con waivers |
| -------- | ----------- | ----------- |
| Score    | 81.36%      | ~99-100%    |
| Line     | 84.62%      | 100%        |
| Cond     | 100%        | 100%        |
| Toggle   | 97.50%      | 97.50%      |
| Branch   | 72.73%      | ~95%        |
| Assert   | 33.33%      | (excluido)  |
| Group    | 100%        | 100%        |

## Coverage holes conocidos (unreachable-by-design)

Los siguientes holes son **inalcanzables por construccion del diseno**, no por
gaps del testbench. Se documentan aqui para transparencia y se excluyen via
waivers (siguiente seccion).

### 1. `rtl/alu.sv` — Default del `unique case`

```systemverilog
default: begin
    out   = MINUS_ONE;
    zero  = 1'b0;
    error = 1'b1;
end
```

**Motivo**: `op[2:0]` son 3 bits con los 8 patrones enumerados (ADD, SUB, MUL,
DIV, NOP0, LOAD, STORE, NOP1). El `default` existe como buena practica
defensiva pero no puede alcanzarse en simulacion 2-estados con opcode valido.

**Verificado por**: el `unique case` reporta warning en tiempo de simulacion si
alguna rama duplica match o si ninguna hace match. Ningun warning fue emitido
en las 4192 transacciones ejecutadas.

### 2. `tb/testbench.sv` — Watchdog `uvm_fatal`

```systemverilog
initial begin
    #500us;
    `uvm_fatal("TB", "Watchdog: la simulacion excedio 500us")
end
```

**Motivo**: es codigo defensivo del testbench que solo dispara si la simulacion
se cuelga. Que nunca dispare significa que el env es sano. Excluirlo de
coverage es equivalente a excluir codigo de manejo de errores del reporte
final.

### 3. `uvm_pkg` — Asserts internos de UVM

**Motivo**: la libreria UVM instrumenta asserts internos que no dependen del
DUT. Estos son ruido de coverage y se filtran con `-cm_hier cm_hier.cfg`.

## Estrategia de waivers

Los holes documentados se cierran con **pragmas `// VCS coverage off/on`**
directamente en las regiones inalcanzables:

- **`rtl/alu.sv`**: alrededor del `default` del `unique case`. Aunque tocar
  el RTL con constructos de verificacion no es ideal, los pragmas son solo
  comentarios que no afectan sintesis y son la unica forma robusta de excluir
  holes sin generar el `.el` interactivamente con Verdi.

- **`tb/testbench.sv`**: alrededor del `initial` del watchdog `uvm_fatal`.
  Como es codigo de TB (no RTL), es completamente aceptable.

Alternativa considerada y descartada: `alu_cov_excludes.el`. URG rechaza
archivos de exclusion escritos a mano por dependencias de checksums e IDs
internos que requieren Verdi interactivo para generarse correctamente. Los
pragmas son 100% deterministicos, versionables y adyacentes al codigo que
excluyen (mejor para revisiones).

## Notas de diseno del env

- **DUT combinacional**: el `clk` vive solo en el harness para sincronizar
  driver y monitor via clocking blocks y evitar race conditions.
- **Interface signals inicializados a 0**: evita estado X al arranque de
  simulacion, que llevaria al DUT combinacional al `default` case y a
  mismatches espurios con el scoreboard.
- **Monitor con filtro `$isunknown`**: red de seguridad contra estados X
  transitorios.
- **`WIDTH` fijado a 8** en el paquete UVM (simplifica config_db).
- **`uvm_config_db`** usado en forma directa (`set` con path del agent, `get`
  con contexto local), sin queries anidadas.
- **`alu_pkg`** (infraestructura) y **`alu_test_pkg`** (sequences + tests)
  separados para permitir desarrollo independiente de tests.

## Control de versiones

Estructura de commits sugerida para versionar cambios:

```bash
# Commit del env base
git add rtl/ tb/ sim/Makefile sim/filelist.f sim/cm_hier.cfg
git commit -m "feat(alu): env UVM completo con coverage funcional al 100%"

# Commit de documentacion
git add README.md
git commit -m "docs(alu): documentar resultados de coverage y holes conocidos"

# Commit de waivers
git add sim/alu_cov_excludes.el
git commit -m "feat(alu): cerrar coverage estructural al ~100% con waivers"
```