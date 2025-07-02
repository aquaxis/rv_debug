`default_nettype none

module debug_top (
    input  wire TRST_N,
    input  wire TCK,
    input  wire TMS,
    input  wire TDI,
    output wire TDO,

    input wire RST_N,
    input wire CLK,

    output wire [1:0] LED
);

  wire tdo_o, tdo_oe, tdi_o;

  assign TDO = (tdo_oe) ? tdo_o : 1'bz;

  wire        ar_en;
  wire        ar_wr;
  wire [15:0] ar_ad;
  wire [31:0] ar_di, ar_do;

  wire core_reset, core_haltreq, core_resumereq;
  reg core_halt, core_resume, core_running;

  wire ndmreset;

  wire mem_valid, mem_ready, mem_except;
  wire [3:0] mem_wstb;
  wire [31:0] mem_addr, mem_wdata, mem_rdata;

  debug_core u_debug_core (
      .TMS   (TMS),
      .TCK   (TCK),
      .TRST_N(TRST_N),
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

      .SYS_RST_N(RST_N),
      .SYS_CLK  (CLK),

      .DEBUG_AR_EN(ar_en),
      .DEBUG_AR_WR(ar_wr),
      .DEBUG_AR_AD(ar_ad),
      .DEBUG_AR_DI(ar_di),
      .DEBUG_AR_DO(ar_do),

      .DEBUG_MEM_VALID (mem_valid),
      .DEBUG_MEM_READY (mem_ready),
      .DEBUG_MEM_WSTB  (mem_wstb),
      .DEBUG_MEM_ADDR  (mem_addr),
      .DEBUG_MEM_WDATA (mem_wdata),
      .DEBUG_MEM_RDATA (mem_rdata),
      .DEBUG_MEM_EXCEPT(mem_except)
  );


  reg [31:0] data;
  always @(*) begin
    case (ar_ad)
      16'h0301: data = 32'h4000_1105;
      default:  data = 32'd0;
    endcase
  end

  assign ar_di = data;

  always @(posedge CLK or negedge TRST_N) begin
    if (!TRST_N) begin
      core_halt    <= 1'b0;
      core_resume  <= 1'b0;
      core_running <= 1'b0;
    end else begin
      core_running <= 1'b1;
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

  assign LED[0]     = core_resume;
  assign LED[1]     = core_halt;

  assign mem_except = 1'b0;
  assign mem_ready  = mem_valid;
  assign mem_rdata  = mem_addr;

endmodule

`default_nettype wire
