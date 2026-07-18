# Memory Verification (Standalone Phase)

Validacion inicial del bloque `memory` del laboratorio Synopsys. TB
standalone en SystemVerilog puro (sin UVM) para validar el RTL antes de
invertir en el env UVM completo.

## Estructura
```
memory_verification/
├── README.md
├── rtl/
│   └── memory.sv               # DUT: 8 palabras x 2*WIDTH bits
├── sim/
│   ├── tb_memory.sv            # TB self-checking, 6 escenarios, 11 checks
│   └── run.sh                  # compile + sim
└── docs/
└── TESTPLAN.md             # Testplan v1.0 (standalone)
```
## Uso

```bash
cd sim/
./run.sh
```

## Escenarios cubiertos

1. Escritura + lectura en misma direccion
2. Multiples writes y reads secuenciales
3. `memoryWrite=0` no modifica memoria
4. `memoryRead=0` fuerza `data_out=0`
5. Lectura asincrona (cambio de addr refleja sin clk)
6. Overwrite (ultima escritura gana)

## Criterio de sign-off

**11/11 checks PASS**. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Fase siguiente

Env UVM completo replicando la estructura de `regbank_verification/`, con
covergroups especificos para memoria (direcciones, patrones write-read).
