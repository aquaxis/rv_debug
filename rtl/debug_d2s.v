`default_nettype none

module debug_d2s (
    input  wire HALTREQ_I,
    output wire HALTREQ_O,
    input  wire HALT_I,
    output wire HALT_O,
    input  wire RESUMEREQ_I,
    output wire RESUMEREQ_O,
    input  wire RESUME_I,
    output wire RESUME_O,
    input  wire RUNNING_I,
    output wire RUNNING_O,
    input  wire HARTRESET_I,
    output wire HARTRESET_O,
    input  wire NDMRESET_I,
    output wire NDMRESET_O,

    input  wire        AR_EN,
    input  wire        AR_WR,
    input  wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO,

    input  wire        AM_EN,
    input  wire        AM_WR,
    input  wire [ 3:0] AM_ST,
    input  wire [31:0] AM_AD,
    input  wire [31:0] AM_DI,
    output wire [31:0] AM_DO,

    input  wire        SYS_EN,
    input  wire        SYS_WR,
    input  wire [ 3:0] SYS_ST,
    input  wire [31:0] SYS_AD,
    input  wire [31:0] SYS_DI,
    output wire [31:0] SYS_DO,

    // CPU Clock Domain
    input wire RST_N,
    input wire CLK,

    output wire        REN,
    output wire        RWR,
    output wire [15:0] RAD,
    output wire [31:0] RDI,
    input  wire [31:0] RDO,

    output wire        PVALID,
    input  wire        PREADY,
    output wire [ 3:0] PWSTB,
    output wire [31:0] PADDR,
    output wire [31:0] PWDATA,
    input  wire [31:0] PRDATA
);

  reg [3:0] r_haltreq_i, r_resumereq_i, r_hartreset_i, r_ndmreset_i;

  always @(posedge CLK) begin
    if (!RST_N) begin
      r_haltreq_i   <= 4'd0;
      r_resumereq_i <= 4'd0;
      r_hartreset_i <= 4'd0;
      r_ndmreset_i  <= 4'd0;
    end else begin
      r_haltreq_i   <= {r_haltreq_i[2:0], HALTREQ_I};
      r_resumereq_i <= {r_resumereq_i[2:0], RESUMEREQ_I};
      r_hartreset_i <= {r_hartreset_i[2:0], HARTRESET_I};
      r_ndmreset_i  <= {r_ndmreset_i[2:0], NDMRESET_I};
    end
  end
  assign HALTREQ_O   = r_haltreq_i[3];
  assign RESUMEREQ_O = r_resumereq_i[3];
  assign HARTRESET_O = r_hartreset_i[3];
  assign NDMRESET_O  = r_ndmreset_i[3];
  assign HALT_O      = HALT_I;
  assign RESUME_O    = RESUME_I;
  assign RUNNING_O   = RUNNING_I;

  reg [3:0] r_en;
  wire w_valid_req;

  always @(posedge CLK) begin
    if (!RST_N) begin
      r_en <= 4'd0;
    end else begin
      r_en <= {r_en[2:0], (AR_EN | AM_EN | SYS_EN)};
    end
  end
  assign w_valid_req = ~r_en[3] & r_en[2];

  reg r_valid;

  always @(posedge CLK) begin
    if (!RST_N) begin
      r_valid <= 1'b0;
    end else begin
      r_valid <= w_valid_req;
    end
  end

  reg r_ar, r_am, r_sys;

  reg         r_ar_wr;
  reg  [15:0] r_ar_ad;
  reg  [31:0] r_ar_di;
  reg  [31:0] r_ar_do;

  reg         r_am_wr;
  reg  [ 3:0] r_am_st;
  reg  [31:0] r_am_ad;
  reg  [31:0] r_am_di;
  reg  [31:0] r_am_do;

  reg         r_sys_wr;
  reg  [ 3:0] r_sys_st;
  reg  [31:0] r_sys_ad;
  reg  [31:0] r_sys_di;
  reg  [31:0] r_sys_do;

  wire        w_ready;
  assign w_ready = (r_ar | ((r_am | r_sys) & PREADY));

  always @(posedge CLK) begin
    if (w_ready || !RST_N) begin
      r_ar  <= 1'b0;
      r_am  <= 1'b0;
      r_sys <= 1'b0;
    end else if (r_valid) begin
      r_ar  <= AR_EN;
      r_am  <= AM_EN;
      r_sys <= SYS_EN;
    end

    if (r_valid) begin
      r_ar_wr  <= AR_WR;
      r_ar_ad  <= AR_AD;
      r_ar_di  <= AR_DI;

      r_am_wr  <= AM_WR;
      r_am_st  <= AM_ST;
      r_am_ad  <= AM_AD;
      r_am_di  <= AM_DI;

      r_sys_wr <= SYS_WR;
      r_sys_st <= SYS_ST;
      r_sys_ad <= SYS_AD;
      r_sys_di <= SYS_DI;
    end
  end

  always @(posedge CLK) begin
    if (w_ready & r_ar) begin
      r_ar_do <= RDO;
    end

    if (&w_ready & r_am & PREADY) begin
      r_am_do <= PRDATA;
    end

    if (w_ready & r_sys & PREADY) begin
      r_sys_do <= PRDATA;
    end
  end

  assign AR_DO  = r_ar_do;

  assign REN    = r_ar;
  assign RWR    = r_ar_wr;
  assign RAD    = r_ar_ad;
  assign RDI    = r_ar_di;

  assign AM_DO  = r_am_do;
  assign SYS_DO = r_sys_do;

  assign PVALID = (r_am | r_sys);
  assign PWSTB  = (r_am & r_am_wr) ? r_am_st : (r_sys & r_sys_wr) ? r_sys_st : 0;
  assign PADDR  = (r_am) ? r_am_ad : (r_sys) ? r_sys_ad : 0;
  assign PWDATA = (r_am) ? r_am_di : (r_sys) ? r_sys_di : 0;

endmodule
;

`default_nettype wire
