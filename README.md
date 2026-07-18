# academy2026-uvm-lab-students

Repositorio didactico derivado del proyecto `academy2026-uvm-lab` del
bootcamp Synopsys Academy 2026, adaptado para estudiantes del curso de
verificacion funcional en CINVESTAV.

Cada bloque corresponde a un modulo del CPU multiciclo del Lab Synopsys
2025. Tu trabajo es escribir el testbench standalone (self-checking) de
cada bloque, ejecutarlo con VCS, y validar tus resultados contra el log
de referencia que se te entrega.

---

## Que se te entrega y por que

Para cada bloque `uvm_tb/<bloque>/` recibes:

- `rtl/*.sv` -- El RTL de referencia. Este RTL ya esta validado en el
  proyecto origen; no lo modifiques al inicio. Si crees que tienes un
  bug, primero sospecha de tu testbench.
- `docs/TESTPLAN.md` -- Testplan formal con matriz de trazabilidad
  requisito -> escenario -> cobertura. Es tu contrato de verificacion.
- `README.md` del bloque -- Interfaz del modulo, tabla de operaciones,
  criterios de aceptacion y nota didactica.
- `sim/run.csh` -- Script de compilacion y simulacion con VCS. Ya esta
  parametrizado; no necesitas escribirlo desde cero.
- `sim/filelist.f` -- Filelist para VCS con las dependencias RTL del
  bloque (cuando aplica).
- `sim/reference_sim.log` -- Salida esperada del TB standalone del
  proyecto origen. Es tu oraculo comparativo: si tu TB produce resultados
  distintos, uno de los dos esta mal (y usualmente no es el RTL).

## Que debes producir tu

- `sim/tb_<modulo>.sv` -- Tu testbench standalone, self-checking, con
  contadores `OK`/`ERR` y reporte final tipo `TEST PASSED` /
  `TEST FAILED`. Debe cubrir todos los escenarios del `TESTPLAN.md`.

Los envs UVM completos (`tb/`) del proyecto origen no se distribuyen en
este repo. La transicion a UVM la haras en una fase posterior del curso,
una vez que tengas dominado el flujo standalone.

## Estructura sugerida para tu `tb_<modulo>.sv`

Como referencia, un TB standalone razonable en este curso tiene:

- Bloque de declaracion de senales conectadas al DUT.
- Instancia del DUT (`dut u_dut(...)`).
- Bloque `initial` con generador de clock si el bloque es secuencial.
- Bloque `initial` con tareas de estimulo, agrupadas por escenario del
  testplan (una tarea por escenario, no un macro-initial).
- Tarea `check(expected, actual, msg)` que incrementa `ok_cnt` o
  `err_cnt` segun el resultado.
- `final` block con reporte agregado y `$finish`.

Convenciones minimas:

- Sin `uvm_field_utils` ni herencia UVM en el standalone.
- Sin prefijo `m_` en variables.
- Nombres de tarea reflejan escenario del testplan
  (por ejemplo `run_scn_alu_add_overflow`).

## Flujo de trabajo

1. Haz fork de este repo a tu cuenta de GitHub.
2. Clona tu fork al servidor `syn-sr` en tu `Isolated/`.
3. Elige un bloque, lee `README.md` y `docs/TESTPLAN.md`.
4. Escribe tu `sim/tb_<modulo>.sv`.
5. Ejecuta `cd uvm_tb/<bloque>/sim && csh run.csh`.
6. Compara tu `sim.log` contra `sim/reference_sim.log`. Debes lograr
   `OK` == numero de escenarios del testplan y `ERR == 0`.
7. Haz commit de tu TB en tu fork, en una rama por bloque
   (por ejemplo `feat/alu-tb-standalone`).

## Reglas del curso

- No copies TBs de fuentes externas. La curva de aprendizaje esta en
  escribir el TB desde cero contra el testplan.
- El log de referencia es oraculo, no plantilla. No lo uses para
  ingenieria inversa del formato de mensajes.
- Si sospechas de un bug en el RTL, abre issue en tu fork con evidencia
  (waveforms, log). El instructor confirmara o refutara antes de que
  toques `rtl/`.

## Servidor y herramientas

- Servidor: `syn-sr` (Rocky Linux 8.8).
- Toolchain: Synopsys V-2023.12-SP5-x (VCS para simulacion).
- Waveform viewer sugerido: Verdi (`fsdb`).
