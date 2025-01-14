# RISC-V JTAG Module

This module is the JTAG module for the RISC-V.

https://github.com/riscv/riscv-debug-spec/blob/release/riscv-debug-release.pdf

## Signals

T.B.D.

## Build for Simulation

This module can a simulation with OpenOCD + JTAG VPI Server.

```
$ cd simocd
$ make setup
$ make
```

## Execute for Simulation

The simulation use three CLIs.

### CLI-1

```
$ cd simocd
$ ./obj_dir/Vdebug_top
```

### CLI-2

```
$ cd simocd
$ openocd -f jtag.cfg
```

### CLI-3

```
$ telnet localhost 4444
```
