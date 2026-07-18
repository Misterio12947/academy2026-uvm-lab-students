# mux2_registered Verification (Standalone Phase)

Validacion del bloque compuesto `mux2_registered` = mux2 + register_bank
con bus de 2*WIDTH bits. Modulo derivado necesario para el top del CPU.

## Estructura
```
mux2_registered_verification/
├── README.md
├── rtl/
│   └── mux2_registered.sv        # DUT: mux2 + regbank compuesto con bus 2*WIDTH
├── sim/
│   ├── tb_mux2_registered.sv     # TB self-checking, 6 escenarios, 15 checks
│   ├── filelist.f                # Lista RTL con dependencias externas
│   └── run.sh                    # compile + sim
└── docs/
└── TESTPLAN.md               # Testplan v1.0 (standalone)
```

## Dependencias RTL

Este bloque **NO duplica** los RTLs de sus submodulos:
```
../../mux2_verification/rtl/mux2.sv              # verificado por separado
../../regbank_verification/rtl/register_bank.sv  # verificado por separado
../rtl/mux2_registered.sv                        # RTL de este bloque
```
El register_bank se instancia con `WIDTH = 2*WIDTH_EXTERNO` (bus interno de
16 bits con WIDTH=8) para acomodar las salidas de la ALU y datos hacia
memoria en el CPU multiciclo.

## Uso

```bash
cd sim/
./run.sh
```

## Escenarios cubiertos

1. Reset asincrono al arranque fuerza `out=0`
2. Captura de cada select (0, 1) con `wr_en=1`
3. Hold con `wr_en=0`: cambios de `sel` no afectan `out`
4. Reset mid-operacion domina sobre `wr_en`, recuperacion post-reset
5. Back-to-back writes alternando selects
6. Cambio de din de entrada seleccionada durante hold vs con `wr_en=1`

## Criterio de sign-off

**15/15 checks PASS**. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Nota didactica: composicion con ancho derivado

Este bloque ilustra un patron avanzado: **el bus interno se calcula a
partir del parametro externo**. Con `WIDTH=8`, el bus interno es 16 bits.
Los submodulos (mux2 y register_bank) se parametrizan con `2*WIDTH`
directamente, aprovechando su naturaleza generica.

Es un ejemplo de composicion parametrica donde:
- El parametro externo mantiene consistencia con el resto del proyecto (WIDTH=8)
- El bloque compuesto sirve como puente entre bloques de distintos anchos
- Los submodulos NO se modifican; simplemente se instancian con el parametro
  adecuado

## Fase siguiente

Env UVM identico en estructura al del mux4_registered, con crosses de
`select x wr_en x rst` sobre bus de 2*WIDTH bits.
