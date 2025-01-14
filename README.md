# RISC-V JTAG Debug Module


## Build

```
$ cd simocd
$ make setup
$ make
```

## Execute for Simulation



```
$ cd simocd
$ ./obj_dir/Vdebug_top
```

```
$ cd simocd
$ openocd -f jtag.cfg
```

```
$ telnet localhost 4444
```
