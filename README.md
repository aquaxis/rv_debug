# RISC-V JTAG Module

このモジュールはRISC-V用のJTAGモジュールです。

This module is the JTAG module for the RISC-V.

![Block Diagram](./doc/images/block_01.drawio.png)

このJTAGモジュールは、以下のRISC-Vデバッグドキュメントに準拠するだけで、汎用JTAGモジュールとして使用できます。

This JTAG module can be used as a general-purpose JTAG module simply by complying with the following RISC-V Debug document.

https://github.com/riscv/riscv-debug-spec/blob/release/riscv-debug-release.pdf

このモジュールを使用すると、OpenOCDやFTDIなどのUSB-Serialデバイスを使用してホストからアクセスできます。
また、JTAG Server VPIを使用することで、シミュレーション環境でこのJTAGモジュールにアクセスできるため、ハードウェア環境と同じホスト環境でシミュレーションを行うことができます。

Using this module, you can access it from the host using OpenOCD and USB-Serial devices such as FTDI.
And by using the JTAG Server VPI, you can access this JTAG module in a simulation environment, so you can perform simulation in the same host environment as the hardware environment.

デバッグ側のインターフェースは2つあります。

There are two debug interfaces:

* 単純なSRAMインターフェースライクなレジスタインターフェース
* APBライクなメモリインターフェース

* Simple SRAM-like Register Interface
* APB-like Memory Interface

## Modules

* debug_code
  * debug_d2s
  * debug_dtm
  * debug_dm

## Signals

### JTAG Signals

| Name | In/Out | Size | Description |
|-----|:---:|----:|:----|
| TRST_N           | in  |  1 | JTAG Reset: Active Low |
| TCK              | in  |  1 | JTAG Clock |
| TMS              | in  |  1 | JTAG Mode Select |
| TDI              | in  |  1 | JTAG Data In |
| TDO              | out |  1 | JTAG Data Out |
| TDO_OE           | out |  1 | JTAG Data Out Enable |
| TDI_O            | out |  1 | Reserved signal |

### Hart(CPU) Signals

| Name | In/Out | Size | Description |
|-----|:---:|----:|:----|
| I_RESUMEACK      | in  |  1 | Resume Acknoledge |
| I_RUNNING        | in  |  1 | Running |
| I_HALTED         | in  |  1 | Halt |
| O_HALTREQ        | out |  1 | Halt Request |
| O_RESUMEREQ      | out |  1 | Rusume Request |
| O_HARTRESET      | out |  1 | Hart Reset |
| O_NDMRESET       | out |  1 | NDM Reset |

### System Signals

| Name | In/Out | Size | Description |
|-----|:---:|----:|:----|
| SYS_RST_N        | in  |  1 | System Reset: Active Low|
| SYS_CLK          | in  |  1 | System Clock|

### Hart Register Access Signals

| Name | In/Out | Size | Description |
|-----|:---:|----:|:----|
| DEBUG_AR_EN      | out |  1 | Enable |
| DEBUG_AR_WR      | out |  1 | Write Enable |
| DEBUG_AR_AD      | out | 16 | Address |
| DEBUG_AR_DI      | in  | 32 | Data In |
| DEBUG_AR_DO      | out | 32 | Data Out |

### Memory Access Signals

| Name | In/Out | Size | Description |
|-----|:---:|----:|:----|
| DEBUG_MEM_VALID  | out |  1 | Valid |
| DEBUG_MEM_READY  | in  |  1 | Ready |
| DEBUG_MEM_WSTB   | out |  4 | Write Strobe |
| DEBUG_MEM_ADDR   | out | 32 | Address |
| DEBUG_MEM_WDATA  | out | 32 | Write Data |
| DEBUG_MEM_RDATA  | in  | 32 | Read Data |
| DEBUG_MEM_EXCEPT | in  |  1 | Exception |

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
