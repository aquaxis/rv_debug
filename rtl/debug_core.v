`default_nettype none

module debug_core (
    input  wire TMS,
    input  wire TCK,
    input  wire TRST_N,
    input  wire TDI,
    output wire TDO,
    output wire TDO_OE,

    output wire TDI_O,

    // Debug Module Status
    input wire I_RESUMEACK,
    input wire I_RUNNING,
    input wire I_HALTED,

    output wire O_HALTREQ,
    output wire O_RESUMEREQ,
    output wire O_HARTRESET,
    output wire O_NDMRESET,

    input wire SYS_RST_N,
    input wire SYS_CLK,

    output wire        DEBUG_AR_EN,
    output wire        DEBUG_AR_WR,
    output wire [15:0] DEBUG_AR_AD,
    input  wire [31:0] DEBUG_AR_DI,
    output wire [31:0] DEBUG_AR_DO,

    output wire        DEBUG_MEM_VALID,
    input  wire        DEBUG_MEM_READY,
    output wire [ 3:0] DEBUG_MEM_WSTB,
    output wire [31:0] DEBUG_MEM_ADDR,
    output wire [31:0] DEBUG_MEM_WDATA,
    input  wire [31:0] DEBUG_MEM_RDATA,
    input  wire        DEBUG_MEM_EXCEPT
);

  wire dmi_en;
  wire dmi_wr, dmi_rd;
  wire [6:0] dmi_ad;
  wire [31:0] dmi_di, dmi_do;

  debug_dtm u_debug_dtm (
      // JTAG pads
      .DEVCODE(32'h10e31913),
      .TRST_N(TRST_N),
      .TCK   (TCK),
      .TMS   (TMS),
      .TDI   (TDI),
      .TDO   (TDO),
      .TDO_OE(TDO_OE),

      .TDI_O(TDI_O),

      .DMI_EN(dmi_en),
      .DMI_WR(dmi_wr),
      .DMI_RD(dmi_rd),
      .DMI_AD(dmi_ad),
      .DMI_DI(dmi_di),
      .DMI_DO(dmi_do)
  );

  wire        ar_en;
  wire        ar_wr;
  wire [15:0] ar_ad;
  wire [31:0] ar_di, ar_do;

  wire       am_en;
  wire       am_wr;
  wire [3:0] am_st;
  wire [31:0] am_ad, am_di, am_do;

  wire sys_en, sys_wr;
  wire [31:0] sys_ad, sys_di, sys_do;

  wire        w_AR_EN;
  wire        w_AR_WR;
  wire [15:0] w_AR_AD;
  wire [31:0] w_AR_DI, w_AR_DO;

  wire        w_AM_EN;
  wire        w_AM_WR;
  wire [ 3:0] w_AM_ST;
  wire [31:0] w_AM_AD;
  wire [31:0] w_AM_DI, w_AM_DO;

  wire        w_SYS_EN;
  wire        w_SYS_WR;
  wire [31:0] w_SYS_AD;
  wire [31:0] w_SYS_DI, w_SYS_DO;

  wire w_haltreq;
  wire w_halted;
  wire w_resumereq;
  wire w_resume;
  wire w_running;
  wire w_hartreset;
  wire w_ndmreset;

  debug_dm u_debug_dm (
      .RST_N(TRST_N),
      .CLK  (TCK),

      // DMI
      .DMI_CS(dmi_en),
      .DMI_WR(dmi_wr),
      .DMI_RD(dmi_rd),
      .DMI_AD(dmi_ad[6:0]),
      .DMI_DI(dmi_do),
      .DMI_DO(dmi_di),

      // Debug Module Status
      .I_RESUMEACK(w_resume),
      .I_RUNNING  (w_running),
      .I_HALTED   (w_halted),

      .O_HALTREQ  (w_haltreq),
      .O_RESUMEREQ(w_resumereq),
      .O_HARTRESET(w_hartreset),
      .O_NDMRESET (w_ndmreset),

      .AR_EN(w_AR_EN),
      .AR_WR(w_AR_WR),
      .AR_AD(w_AR_AD),
      .AR_DI(w_AR_DI),
      .AR_DO(w_AR_DO),

      .AM_EN(w_AM_EN),
      .AM_WR(w_AM_WR),
      .AM_ST(w_AM_ST),
      .AM_AD(w_AM_AD),
      .AM_DI(w_AM_DI),
      .AM_DO(w_AM_DO),

      .SYS_EN(w_SYS_EN),
      .SYS_WR(w_SYS_WR),
      .SYS_AD(w_SYS_AD),
      .SYS_DI(w_SYS_DI),
      .SYS_DO(w_SYS_DO)
  );

  debug_d2s u_debug_d2s (
      .HALTREQ_I  (w_haltreq),
      .HALTREQ_O  (O_HALTREQ),
      .HALT_I     (I_HALTED),
      .HALT_O     (w_halted),
      .RESUMEREQ_I(w_resumereq),
      .RESUMEREQ_O(O_RESUMEREQ),
      .RESUME_I   (I_RESUMEACK),
      .RESUME_O   (w_resume),
      .RUNNING_I  (I_RUNNING),
      .RUNNING_O  (w_running),
      .HARTRESET_I(w_hartreset),
      .HARTRESET_O(O_HARTRESET),
      .NDMRESET_I (w_ndmreset),
      .NDMRESET_O (O_NDMRESET),

      .AR_EN(w_AR_EN),
      .AR_WR(w_AR_WR),
      .AR_AD(w_AR_AD),
      .AR_DI(w_AR_DO),
      .AR_DO(w_AR_DI),

      .AM_EN(w_AM_EN),
      .AM_WR(w_AM_WR),
      .AM_ST(w_AM_ST),
      .AM_AD(w_AM_AD),
      .AM_DI(w_AM_DO),
      .AM_DO(w_AM_DI),

      .SYS_EN(w_SYS_EN),
      .SYS_WR(w_SYS_WR),
      .SYS_ST(4'hF),
      .SYS_AD(w_SYS_AD),
      .SYS_DI(w_SYS_DO),
      .SYS_DO(w_SYS_DI),

      .RST_N(SYS_RST_N),
      .CLK  (SYS_CLK),

      .REN(DEBUG_AR_EN),
      .RWR(DEBUG_AR_WR),
      .RAD(DEBUG_AR_AD),
      .RDI(DEBUG_AR_DI),
      .RDO(DEBUG_AR_DO),

      .PVALID(DEBUG_MEM_VALID),
      .PREADY(DEBUG_MEM_READY),
      .PWSTB (DEBUG_MEM_WSTB),
      .PADDR (DEBUG_MEM_ADDR),
      .PWDATA(DEBUG_MEM_WDATA),
      .PRDATA(DEBUG_MEM_RDATA)
  );

endmodule

`default_nettype wire
