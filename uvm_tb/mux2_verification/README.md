# mux2 Verification (Standalone Phase)

Validacion del multiplexor 2:1 parametrizado, modulo derivado necesario
para el top del CPU (senal `selmux2` del control unit).

## Estructura
```
mux2_verification/
├── README.md
├── rtl/
│   └── mux2.sv                 # DUT: mux 2:1 parametrizado combinacional
├── sim/
│   ├── tb_mux2.sv              # TB self-checking, 6 escenarios, 16 checks
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

1. Cada select individual (1'b0, 1'b1)
2. Cambio dinamico de select (verifica combinacional)
3. Valores extremos (all-zero, all-one)
4. Independencia de entradas no seleccionadas
5. Barrido con patrones alternados por din
6. Toggle rapido de select (stress combinacional)

## Criterio de sign-off

**16/16 checks PASS**. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Nota didactica: modulos derivados

Este es el primer bloque del proyecto que verifica un **modulo derivado**
(no listado explicitamente en Lab I pero necesario para el top). Ilustra:
- Que los modulos "extra" que agregas al proyecto merecen el mismo rigor
  que los formales
- La convencion de la interfaz sigue el patron del mux4 (mismo naming, mismo
  estilo de default con pragma)
- El testplan documenta explicitamente la razon de su existencia (uso en el
  top del CPU)

## Fase siguiente

Env UVM identico en estructura al del mux4 (adaptado a select de 1 bit), y
uso del bloque como submodulo en `mux2_registered_verification/`.

