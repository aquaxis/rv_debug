`default_nettype none

module debug_dtm (
    input  wire [31:0] DEVCODE,
    input  wire        TRST_N,
    input  wire        TMS,
    input  wire        TCK,
    input  wire        TDI,
    output reg         TDO,
    output reg         TDO_OE,

    output wire TDI_O,

    output wire        DMI_EN,
    output wire        DMI_WR,
    output wire        DMI_RD,
    output wire [ 6:0] DMI_AD,
    input  wire [31:0] DMI_DI,
    output wire [31:0] DMI_DO
);

  localparam DTMCS_ABITS = 6'b000111;
  localparam DTMCS_VERSION = 4'b0001;
  localparam DTMCS_VALUE = 32'h00000101;
  localparam IR_LENGTH = 5;
  localparam EXTEST = 5'b00000;
  localparam IDCODE = 5'b00001;
  localparam BYPASS = 5'b11111;
  localparam DTMCS = 5'b10000;
  localparam DMI = 5'b10001;

  wire test_logic_reset;
  wire run_test_idle;
  wire select_dr_scan;
  wire capture_dr;
  wire shift_dr;
  wire exit1_dr;
  wire pause_dr;
  wire exit2_dr;
  wire update_dr;
  wire select_ir_scan;
  wire capture_ir;
  wire shift_ir;
  wire exit1_ir;
  wire pause_ir;
  wire exit2_ir;
  wire update_ir;
  wire extest_select;
  wire idcode_select;
  wire bypass_select;
  wire dtmcs_select;
  wire dmi_select;

  assign TDI_O  = TDI;
  assign DMI_EN = dmi_select;

  localparam S_TEST_LOGIC_RESET = 4'hF;
  localparam S_RUN_TEST_IDLE = 4'hC;
  localparam S_SELECT_DR_SCAN = 4'h7;
  localparam S_CAPTURE_DR = 4'h6;
  localparam S_SHIFT_DR = 4'h2;
  localparam S_EXIT1_DR = 4'h1;
  localparam S_PAUSE_DR = 4'h3;
  localparam S_EXIT2_DR = 4'h0;
  localparam S_UPDATE_DR = 4'h5;
  localparam S_SELECT_IR_SCAN = 4'h4;
  localparam S_CAPTURE_IR = 4'hE;
  localparam S_SHIFT_IR = 4'hA;
  localparam S_EXIT1_IR = 4'h9;
  localparam S_PAUSE_IR = 4'hB;
  localparam S_EXIT2_IR = 4'h8;
  localparam S_UPDATE_IR = 4'hD;

  reg [3:0] state = S_TEST_LOGIC_RESET;
  reg [3:0] next_state;
  reg [3:0] state_n;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) state = S_TEST_LOGIC_RESET;
    else state = next_state;
  end

  always @(negedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) state_n = S_TEST_LOGIC_RESET;
    else state_n = state;
  end

  always @(state or TMS) begin
    case (state)
      S_TEST_LOGIC_RESET: begin
        if (TMS) next_state = S_TEST_LOGIC_RESET;
        else next_state = S_RUN_TEST_IDLE;
      end
      S_RUN_TEST_IDLE: begin
        if (TMS) next_state = S_SELECT_DR_SCAN;
        else next_state = S_RUN_TEST_IDLE;
      end
      S_SELECT_DR_SCAN: begin
        if (TMS) next_state = S_SELECT_IR_SCAN;
        else next_state = S_CAPTURE_DR;
      end
      S_CAPTURE_DR: begin
        if (TMS) next_state = S_EXIT1_DR;
        else next_state = S_SHIFT_DR;
      end
      S_SHIFT_DR: begin
        if (TMS) next_state = S_EXIT1_DR;
        else next_state = S_SHIFT_DR;
      end
      S_EXIT1_DR: begin
        if (TMS) next_state = S_UPDATE_DR;
        else next_state = S_PAUSE_DR;
      end
      S_PAUSE_DR: begin
        if (TMS) next_state = S_EXIT2_DR;
        else next_state = S_PAUSE_DR;
      end
      S_EXIT2_DR: begin
        if (TMS) next_state = S_UPDATE_DR;
        else next_state = S_SHIFT_DR;
      end
      S_UPDATE_DR: begin
        if (TMS) next_state = S_SELECT_DR_SCAN;
        else next_state = S_RUN_TEST_IDLE;
      end
      S_SELECT_IR_SCAN: begin
        if (TMS) next_state = S_TEST_LOGIC_RESET;
        else next_state = S_CAPTURE_IR;
      end
      S_CAPTURE_IR: begin
        if (TMS) next_state = S_EXIT1_IR;
        else next_state = S_SHIFT_IR;
      end
      S_SHIFT_IR: begin
        if (TMS) next_state = S_EXIT1_IR;
        else next_state = S_SHIFT_IR;
      end
      S_EXIT1_IR: begin
        if (TMS) next_state = S_UPDATE_IR;
        else next_state = S_PAUSE_IR;
      end
      S_PAUSE_IR: begin
        if (TMS) next_state = S_EXIT2_IR;
        else next_state = S_PAUSE_IR;
      end
      S_EXIT2_IR: begin
        if (TMS) next_state = S_UPDATE_IR;
        else next_state = S_SHIFT_IR;
      end
      S_UPDATE_IR: begin
        if (TMS) next_state = S_SELECT_DR_SCAN;
        else next_state = S_RUN_TEST_IDLE;
      end
      default: next_state = S_TEST_LOGIC_RESET;
    endcase
  end

  assign test_logic_reset = (state_n == S_TEST_LOGIC_RESET) ? 1'b1 : 1'b0;
  assign run_test_idle    = (state_n == S_RUN_TEST_IDLE) ? 1'b1 : 1'b0;
  assign select_dr_scan   = (state_n == S_SELECT_DR_SCAN) ? 1'b1 : 1'b0;
  assign capture_dr       = (state_n == S_CAPTURE_DR) ? 1'b1 : 1'b0;
  assign shift_dr         = (state_n == S_SHIFT_DR) ? 1'b1 : 1'b0;
  assign exit1_dr         = (state_n == S_EXIT1_DR) ? 1'b1 : 1'b0;
  assign pause_dr         = (state_n == S_PAUSE_DR) ? 1'b1 : 1'b0;
  assign exit2_dr         = (state_n == S_EXIT2_DR) ? 1'b1 : 1'b0;
  assign update_dr        = (state_n == S_UPDATE_DR) ? 1'b1 : 1'b0;
  assign select_ir_scan   = (state_n == S_SELECT_IR_SCAN) ? 1'b1 : 1'b0;
  assign capture_ir       = (state_n == S_CAPTURE_IR) ? 1'b1 : 1'b0;
  assign shift_ir         = (state_n == S_SHIFT_IR) ? 1'b1 : 1'b0;
  assign exit1_ir         = (state_n == S_EXIT1_IR) ? 1'b1 : 1'b0;
  assign pause_ir         = (state_n == S_PAUSE_IR) ? 1'b1 : 1'b0;
  assign exit2_ir         = (state_n == S_EXIT2_IR) ? 1'b1 : 1'b0;
  assign update_ir        = (state_n == S_UPDATE_IR) ? 1'b1 : 1'b0;

  // JTAG_IR
  reg  [IR_LENGTH-1:0] jtag_ir;
  reg  [IR_LENGTH-1:0] latched_jtag_ir;
  wire                 instruction_tdo;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) jtag_ir[IR_LENGTH-1:0] <= '0;
    else if (test_logic_reset == 1) jtag_ir[IR_LENGTH-1:0] <= '0;
    else if (capture_ir) jtag_ir <= 5'b00101;
    else if (shift_ir) jtag_ir[IR_LENGTH-1:0] <= {TDI, jtag_ir[IR_LENGTH-1:1]};
  end

  assign instruction_tdo = jtag_ir[0];

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) latched_jtag_ir <= IDCODE;
    else if (test_logic_reset) latched_jtag_ir <= IDCODE;
    else if (update_ir) latched_jtag_ir <= jtag_ir;
  end

  // ICODE
  reg  [31:0] idcode_reg;
  wire        idcode_tdo;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) idcode_reg <= DEVCODE;
    else if (test_logic_reset) idcode_reg <= DEVCODE;
    else if (idcode_select & capture_dr) idcode_reg <= DEVCODE;
    else if (idcode_select & shift_dr) idcode_reg <= {TDI, idcode_reg[31:1]};
  end

  assign idcode_tdo = idcode_reg[0];

  // DTMCS
  reg  [31:0] dtmcs_reg;
  wire        dtmcs_tdo;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) dtmcs_reg <= {22'd0, DTMCS_ABITS, DTMCS_VERSION};
    else if (test_logic_reset) dtmcs_reg <= {22'd0, DTMCS_ABITS, DTMCS_VERSION};
    else if (dtmcs_select & capture_dr) dtmcs_reg <= {dtmcs_reg[31:10], DTMCS_ABITS, DTMCS_VERSION};
    else if (dtmcs_select & shift_dr) dtmcs_reg <= {TDI, dtmcs_reg[31:1]};
  end

  assign dtmcs_tdo = dtmcs_reg[0];

  // DMI
  reg  [33+DTMCS_ABITS:0] dmi_reg;
  wire                    dmi_tdo;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) dmi_reg <= 0;
    else if (test_logic_reset) dmi_reg <= 0;
    else if (dmi_select & capture_dr) dmi_reg <= {dmi_reg[33+DTMCS_ABITS:34], DMI_DI[31:0], 2'b00};
    else if (dmi_select & shift_dr) dmi_reg <= {TDI, dmi_reg[33+DTMCS_ABITS:1]};
  end

  assign dmi_tdo = dmi_reg[0];

  assign DMI_WR  = update_dr & (dmi_reg[1:0] == 2'b10);
  assign DMI_RD  = update_dr & (dmi_reg[1:0] == 2'b01);
  assign DMI_AD  = dmi_reg[33+DTMCS_ABITS:34];
  assign DMI_DO  = dmi_reg[33:2];
  // BYPASS
  wire bypassed_tdo;
  reg  bypass_reg;

  always @(posedge TCK or negedge TRST_N) begin
    if (TRST_N == 0) bypass_reg <= 1'b0;
    else if (test_logic_reset == 1) bypass_reg <= 1'b0;
    else if (bypass_select & capture_dr) bypass_reg <= 1'b0;
    else if (bypass_select & shift_dr) bypass_reg <= TDI;
  end

  assign bypassed_tdo = bypass_reg;

  assign extest_select = (latched_jtag_ir == EXTEST) ? 1'b1 : 1'b0;  // External test
  assign idcode_select = (latched_jtag_ir == IDCODE) ? 1'b1 : 1'b0;  // ID Code
  assign dtmcs_select = (latched_jtag_ir == DTMCS) ? 1'b1 : 1'b0;  // DTM Control and Status
  assign dmi_select = (latched_jtag_ir == DMI) ? 1'b1 : 1'b0;  // DMI
  assign bypass_select = ((latched_jtag_ir == BYPASS) || (latched_jtag_ir == 0))?1'b1:1'b0; // BYPASS

  reg tdo_mux_out;

  always @(shift_ir or instruction_tdo or latched_jtag_ir or idcode_tdo or dtmcs_tdo or dmi_tdo or bypassed_tdo)
  begin
    if (shift_ir) tdo_mux_out = instruction_tdo;
    else begin
      case (latched_jtag_ir)
        IDCODE: tdo_mux_out = idcode_tdo;  // Reading ID code
        DTMCS:  tdo_mux_out = dtmcs_tdo;  // DTM Control and Status
        DMI:    tdo_mux_out = dmi_tdo;  // DMI
        default: tdo_mux_out = bypassed_tdo;  // BYPASS instruction
      endcase
    end
  end

  always @(negedge TCK) begin
    TDO <= tdo_mux_out;
  end

  always @(*) begin
    TDO_OE = shift_ir | shift_dr;
  end

endmodule

`default_nettype wire
