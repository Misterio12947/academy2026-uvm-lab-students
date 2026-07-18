# mux4 Verification (Standalone Phase)
Validacion inicial del multiplexor 4:1 parametrizado del laboratorio Synopsys. TB standalone en SystemVerilog puro para validar el RTL antes del
env UVM.
## Estructura
```
mux4_verification/
├── README.md
├── rtl/
│   └── mux4.sv                 # DUT: mux 4:1 parametrizado combinacional
├── sim/
│   ├── tb_mux4.sv              # TB self-checking, 6 escenarios, 17 checks
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
1. Cada select individual (2'b00, 01, 10, 11) 
2. Cambio dinamico de select (verifica combinacional) 
3. Valores extremos (all-zero, all-one) 
4. Independencia de entradas no seleccionadas 
5. Barrido con patrones alternados por din 
6. Cambios rapidos (stress combinacional)

## Criterio de sign-off
**17/17 checks PASS**. Ver `docs/TESTPLAN.md` para trazabilidad completa.

## Nota didactica
Aunque el mux4 es uno de los bloques mas simples del lab, esta verificacion se documenta con el mismo rigor que los modulos complejos. Sirve como
plantilla para estudiantes: incluso los modulos "vanales" requieren: 
- Testplan formal con matriz de trazabilidad 
- Escenarios explicitos con checks self-verifying 
- Criterios de aceptacion medibles 
- Waivers documentados para holes de coverage (ej. default unreachable del case)

## Fase siguiente
Env UVM completo replicando la estructura de bloques anteriores, con
covergroups para todos los selects y cruces con rangos de datos.
