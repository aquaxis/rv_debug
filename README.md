# RISC-V JTAG Debug Module


## Build

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
