# control Verification (Standalone Phase)

Validacion del bloque `control`, unidad de control del CPU multiciclo del
Lab III. FSM Moore de 4 estados orquestando las etapas de reset, decodificacion,
ejecucion y almacenamiento.

## Estructura
```
control_verification/
├── README.md
├── rtl/
│   └── control.sv              # DUT: FSM 4 estados con decodificacion cmd_in
├── sim/
│   ├── tb_control.sv           # TB self-checking, 9 escenarios, ~55 checks
│   └── run.sh                  # compile + sim
└── docs/
└── TESTPLAN.md             # Testplan v1.0 (standalone)
```
## Uso

```bash
cd sim/
./run.sh
```

## FSM (4 estados basada en las imagenes del spec del lab)
```
   posedge rst
  +-----------+
  |           |
  v           |
[RST_ST] --> [FETCH_DECODE] --> [EXECUTE] --> [STORE]
^                                |
+--------------------------------+
```
- **RST_ST**: captura primer cmd_in ("avoid losing one cycle")
- **FETCH_DECODE**: decodifica cmd_in, captura A y B en registros ALU
- **EXECUTE**: ALU computa, o LOAD lee memoria
- **STORE**: pulso cpu_rdy, captura siguiente cmd_in, STORE escribe memoria

## Escenarios cubiertos

1. Reset asincrono lleva a RST_ST
2. Ciclo completo ADD (transiciones y outputs por estado)
3. Ciclo LOAD (memoryRead + selmux2 en EXECUTE)
4. Ciclo STORE (memoryWrite en STORE)
5. NOP0/NOP1 no acceden memoria
6. cpu_rdy es pulso de 1 ciclo (solo en STORE)
7. nvalid_data = p_error && feedback (4 casos)
8. Reset mid-instruccion vuelve a RST_ST
9. Back-to-back instructions

## Criterio de sign-off

Todos los ~55 checks PASS. Ver `docs/TESTPLAN.md` para matriz de trazabilidad.

## Nota didactica: FSM basada en los diagramas del spec

Este bloque ilustra la interpretacion de un diagrama arquitectural para
derivar la FSM correcta. Los 4 estados del `control` derivan directamente
de las 4 imagenes del spec del lab:

- Imagen 1 (Reset) -> estado RST_ST con datain_reg_en=1
- Imagen 2 (Fetch/Decode) -> estado FETCH_DECODE con aluin_reg_en=1
- Imagen 3 (Execute) -> estado EXECUTE con aluout_reg_en=1 (+ memoryRead si LOAD)
- Imagen 4 (Store) -> estado STORE con cpu_rdy=1, datain_reg_en=1 (+ memoryWrite si STORE)

Cada senal naranja/verde de las imagenes corresponde a un output del RTL
en ese estado. Los defaults de `always_comb` capturan las senales inactivas
(grises en las imagenes).

## Fase siguiente

Env UVM enfocado en coverage por estado, opcode, y cruces criticos
(estado x opcode, p_error x feedback, transiciones consecutivas).

