`default_nettype none

module debug_top (
    input  wire TRST_N,
    input  wire TCK,
    input  wire TMS,
    input  wire TDI,
    output wire TDO,

    input wire CLK100M,

    output wire [3:0] LED
);

  wire tdo_o, tdo_oe;

  assign TDO = (tdo_oe) ? tdo_o : 1'bz;

  wire dmi_en;
  wire dmi_wr, dmi_rd;
  wire [6:0] dmi_ad;
  wire [31:0] dmi_di, dmi_do;

  wire        ar_en;
  wire        ar_wr;
  wire [15:0] ar_ad;
  wire [31:0] ar_di, ar_do;

  wire        am_en;
  wire        am_wr;
  wire [ 3:0] am_st;
  wire [31:0] am_ad;
  wire [31:0] am_di, am_do;

  wire sys_en, sys_wr;
  wire [31:0] sys_ad, sys_di, sys_do;

  wire core_reset;
  wire core_haltreq, core_resumereq;
  reg core_halt, core_resume;

  wire ndmreset;

  debug_core u_debug_core (
      .TMS   (TMS),
      .TCK   (TCK),
      .TRSTN (TRST_N),
      .TDI   (TDI),
      .TDO   (tdo_o),
      .TDO_OE(tdo_oe),

      .TDI_O(tdi_o),

      // Debug Module Status
      .I_RESUMEACK(core_resume),
      .I_RUNNING(core_running),
      .I_HALTED(core_halt),

      .O_HALTREQ  (core_haltreq),
      .O_RESUMEREQ(core_resumereq),
      .O_HARTRESET(core_reset),
      .O_NDMRESET (ndmreset),

      .SYS_RST_N(1'b1),
      .SYS_CLK  (CLK100M),

      .DEBUG_AR_EN(),
      .DEBUG_AR_WR(),
      .DEBUG_AR_AD(),
      .DEBUG_AR_DI(),
      .DEBUG_AR_DO(),

      .DEBUG_MEM_VALID (),
      .DEBUG_MEM_READY (),
      .DEBUG_MEM_WSTB  (),
      .DEBUG_MEM_ADDR  (),
      .DEBUG_MEM_WDATA (),
      .DEBUG_MEM_RDATA (),
      .DEBUG_MEM_EXCEPT()
  );


  reg [31:0] data;
  always @(*) begin
    case (ar_ad)
      16'h0301: data <= 32'h4000_1105;
      default:  data <= 32'd0;
    endcase
  end

  assign ar_di = data;

  always @(posedge CLK100M or negedge TRST_N) begin
    if (!TRST_N) begin
      core_halt   <= 1'b0;
      core_resume <= 1'b0;
    end else begin
      if (core_haltreq) begin
        core_halt   <= 1'b1;
        core_resume <= 1'b0;
      end else if (core_resumereq & core_halt) begin
        core_halt   <= 1'b0;
        core_resume <= 1'b1;
      end else if (!core_resumereq & core_resume) begin
        core_halt   <= 1'b0;
        core_resume <= 1'b0;
      end
    end
  end

  assign LED[0] = core_resume;
  assign LED[1] = core_halt;
  assign LED[2] = 1'b0;
  assign LED[3] = 1'b0;

endmodule

`default_nettype wire
