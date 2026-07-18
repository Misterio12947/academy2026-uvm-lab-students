# mux4_registered Verification (Standalone Phase)

Validacion del bloque compuesto `mux4_registered` = mux4 + register_bank.
Segundo bloque del proyecto que **compone modulos ya firmados**, sirviendo
como plantilla para verificacion de composiciones.

## Estructura
```
mux4_registered_verification/
├── README.md
├── rtl/
│   └── mux4_registered.sv       # DUT: mux4 + regbank compuesto
├── sim/
│   ├── tb_mux4_registered.sv    # TB self-checking, 6 escenarios, 17 checks
│   ├── filelist.f               # Lista RTL con dependencias externas
│   └── run.sh                   # compile + sim
└── docs/
└── TESTPLAN.md              # Testplan v1.0 (standalone)
```

## Dependencias RTL

Este bloque **NO duplica** los RTLs de sus submodulos. Referencia los
originales via `filelist.f`:
```
../../mux4_verification/rtl/mux4.sv           # verificado por separado
../../regbank_verification/rtl/register_bank.sv  # verificado por separado
../rtl/mux4_registered.sv                     # RTL de este bloque
```
Ventaja: single source of truth. Si `mux4` o `register_bank` cambian en su
bloque origen, este TB debe re-ejecutarse.

## Uso

```bash
cd sim/
./run.sh
```

## Escenarios cubiertos

1. Reset asincrono al arranque fuerza `out=0`
2. Captura de cada select (00, 01, 10, 11) con `wr_en=1`
3. Hold con `wr_en=0`: cambios de `sel` no afectan `out`
4. Reset mid-operacion domina sobre `wr_en`, recuperacion post-reset
5. Back-to-back writes con distintos selects
6. Cambio de din de entrada seleccionada durante hold vs con `wr_en=1`

## Criterio de sign-off

**17/17 checks PASS**. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Nota didactica: composicion de bloques

Este es el primer bloque del proyecto que compone submodulos ya verificados.
Ilustra:
- Como referenciar RTL entre bloques sin duplicar (filelist con paths relativos)
- Como el testplan se enfoca en la **composicion correcta**, no en re-verificar
  los submodulos (que ya tienen su propio testplan firmado)
- Como los escenarios prueban la interfaz combinada (secuencial via regbank,
  seleccion via mux) en vez de cada uno por separado

## Fase siguiente

Env UVM enfocado en coverage cruzado de `select x wr_en x rst` y transiciones
mid-operacion.
