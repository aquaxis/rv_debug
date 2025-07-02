`default_nettype none

module debug_dm (
    input  wire        RST_N,
    input  wire        CLK,
    // DMI
    input  wire        DMI_CS,
    input  wire        DMI_WR,
    input  wire        DMI_RD,
    input  wire [ 6:0] DMI_AD,
    input  wire [31:0] DMI_DI,
    output wire [31:0] DMI_DO,
    // Debug Module Status
    input  wire        I_RESUMEACK,
    input  wire        I_RUNNING,
    input  wire        I_HALTED,
    output wire        O_HALTREQ,
    output wire        O_RESUMEREQ,
    output wire        O_HARTRESET,
    output wire        O_NDMRESET,
    // Register Bus
    output wire        AR_EN,
    output wire        AR_WR,
    output wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO,
    // Memory Bus
    output wire        AM_EN,
    output wire        AM_WR,
    output wire [ 3:0] AM_ST,
    output wire [31:0] AM_AD,
    input  wire [31:0] AM_DI,
    output wire [31:0] AM_DO,
    // System Bus
    output wire        SYS_EN,
    output wire        SYS_WR,
    output wire [31:0] SYS_AD,
    input  wire [31:0] SYS_DI,
    output wire [31:0] SYS_DO
);

  reg  [31:0] data0;
  reg  [31:0] data1;
  reg  [31:0] data0_r;

  // Debug Module Status
  wire        impebreak;  // R
  wire        allhavereset;  // R
  wire        anyhavereset;  // R
  wire        allresumeack;  // R
  wire        anyresumeack;  // R
  wire        allnonexistent;  // R
  wire        anynonexistent;  // R
  wire        allunavail;  // R
  wire        anyunavail;  // R
  wire        allrunning;  // R
  wire        anyrunning;  // R
  wire        allhalted;  // R
  wire        anyhalted;  // R
  wire        authencicated;  // R
  wire        authbusy;  // R
  wire        hasresethalreq;  // R
  wire        confstrptrvalid;  // R
  wire [ 3:0] version;  // R

  assign version[3:0]    = 4'd2;
  assign authencicated   = 1'b1;
  assign impebreak       = 0;
  assign allhavereset    = 0;
  assign anyhavereset    = 0;
  assign allnonexistent  = 0;
  assign anynonexistent  = 0;
  assign allunavail      = 0;
  assign anyunavail      = 0;
  assign authbusy        = 0;
  assign hasresethalreq  = 0;
  assign confstrptrvalid = 0;

  // Debug Module Control
  reg        haltreq;  // W
  reg        resumereq;  // W
  reg        hartreset;  // R/W
  reg        ackhavereset;  // W
  wire       hasel;  // R/W
  wire [9:0] hasello;  // R/W
  wire [9:0] haselhi;  // R/W
  reg        setresethaltreq;  // W
  reg        clrresethaltreq;  // W
  reg        ndmreset;  // R/W
  reg        dmactive;  // R/W

  assign hasel   = 0;
  assign hasello = 0;
  assign haselhi = 0;

  // Halt Status
  wire [ 3:0] nscratch;  // R
  wire        dataaccess;  // R
  wire [ 3:0] datasize;  // R
  wire [11:0] dataaddr;  // R

  assign nscratch   = 4'd0;
  assign dataaccess = 1'b0;
  assign datasize   = 4'd1;
  assign dataaddr   = 12'd0;

  // Hart Window
  reg  [14:0] hawindowsel;  // R/W
  reg  [31:0] maskdata;

  // Abstract Control & Status
  wire [ 6:0] progbufsize;  // R
  wire        busy;  // R
  reg  [ 2:0] cmderr;  // R/W
  wire [ 3:0] datacount;  // R

  assign datacount   = 4'd1;
  assign progbufsize = 0;
  assign busy        = 0;

  // Abstract Command
  wire [ 7:0] cmdtype;  // W
  reg  [ 7:0] old_cmdtype;
  wire [23:0] control;  // W
  reg  [15:0] autoexecprogbuf;  // R/W
  reg  [11:0] autiexecdata;  // R/W
  reg  [31:0] nextdm;
  reg  [31:0] authdata;
  wire [31:0] haltsum0;
  wire [31:0] haltsum1;
  wire [31:0] haltsum2;
  wire [31:0] haltsum3;
  wire [ 2:0] sbversion;  // R
  wire        sbbusyerror;  // R/W
  wire        sbbusy;  // R
  reg         sbreadonaddr;  // R/W
  reg  [ 2:0] sbaccess;  // R/W
  reg         sbautoincrement;  // R/W
  reg         sbreadondata;  // R/W
  wire [ 2:0] sberror;  // R/W
  wire [ 6:0] sbsize;  // R
  wire        sbaccess128;  // R
  wire        sbaccess64;  // R
  wire        sbaccess32;  // R
  wire        sbaccess16;  // R
  wire        sbaccess8;  // R

  assign haltsum0    = 0;
  assign haltsum1    = 0;
  assign haltsum2    = 0;
  assign haltsum3    = 0;
  assign sbbusyerror = 0;
  assign sbbusy      = 0;
  assign sberror     = 0;
  assign sbsize      = 0;
  assign sbversion   = 3'd0;
  assign sbaccess128 = 1'b0;
  assign sbaccess64  = 1'b0;
  assign sbaccess16  = 1'b0;
  assign sbaccess8   = 1'b0;
  assign sbaccess32  = 1'b1;

  reg [31:0] sbaddress0;  // R/W
  reg [31:0] sbdata0_r;  // R/W

  localparam A_DATA0 = 7'h04;
  localparam A_DATA1 = 7'h05;
  localparam A_DMCONTROL = 7'h10;
  localparam A_DMSTATUS = 7'h11;
  localparam A_HALTSUM1 = 7'h12;
  localparam A_HARTINFO = 7'h13;
  localparam A_HAWINDOWSEL = 7'h14;
  localparam A_HAWINDOW = 7'h15;
  localparam A_ABSTRACTCS = 7'h16;
  localparam A_COMMAND = 7'h17;
  localparam A_ABSTRACTAUTO = 7'h18;
  localparam A_NEXTDM = 7'h1D;
  localparam A_AUTODATA = 7'h30;
  localparam A_HALTSUM2 = 7'h34;
  localparam A_HALTSUM3 = 7'h35;
  localparam A_SBCS = 7'h38;
  localparam A_SBADDRESS0 = 7'h39;
  localparam A_SBDATA0 = 7'h3C;
  localparam A_HALTSUM0 = 7'h40;

  wire [31:0] dmcontrol;
  wire [31:0] dmstatus;
  wire [31:0] hartinfo;
  wire [31:0] hawindow;
  wire [31:0] abstractcs;
  wire [31:0] command;
  wire [31:0] abstractauto;
  wire [31:0] sbcs;

  //assign hasresethalreq = haltreq;
  assign allhalted = I_HALTED;
  assign anyhalted = I_HALTED;

  assign allresumeack = I_RESUMEACK;
  assign anyresumeack = I_RESUMEACK;

  assign allrunning = I_RUNNING;
  assign anyrunning = I_RUNNING;

  assign dmstatus = {
    8'd0,
    1'b0,
    impebreak,
    2'd0,
    allhavereset,
    anyhavereset,
    allresumeack,
    anyresumeack,
    allnonexistent,
    anynonexistent,
    allunavail,
    anyunavail,
    allrunning,
    anyrunning,
    allhalted,
    anyhalted,
    authencicated,
    authbusy,
    hasresethalreq,
    confstrptrvalid,
    version
  };
  assign dmcontrol = {
    haltreq,
    resumereq,
    hartreset,
    ackhavereset,
    1'd0,
    hasel,
    hasello,
    haselhi,
    2'd0,
    setresethaltreq,
    clrresethaltreq,
    ndmreset,
    dmactive
  };
  assign hartinfo = {8'd0, nscratch, 3'd0, dataaccess, datasize, dataaddr};
  assign hawindow = {maskdata};
  assign abstractcs = {1'd0, progbufsize, 8'd0, 3'd0, busy, 1'd0, cmderr, 4'd0, datacount};
  assign command = {cmdtype, control};
  assign abstractauto = {autoexecprogbuf, 4'd0, autiexecdata};
  assign sbcs = {
    sbversion,
    6'd0,
    sbbusyerror,
    sbbusy,
    sbreadonaddr,
    sbaccess,
    sbautoincrement,
    sbreadondata,
    sberror,
    sbsize,
    sbaccess128,
    sbaccess64,
    sbaccess32,
    sbaccess16,
    sbaccess8
  };

  reg [31:0] rdata;

  assign cmdtype = DMI_DI[31:24];
  assign control = DMI_DI[23:0];

  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) begin
      sbreadonaddr    <= 0;
      sbaccess        <= 2;
      sbautoincrement <= 0;
      sbreadondata    <= 0;
      old_cmdtype     <= 0;
      haltreq         <= 0;
      resumereq       <= 0;
      ackhavereset    <= 0;
      setresethaltreq <= 0;
      clrresethaltreq <= 0;
      ndmreset        <= 0;
      dmactive        <= 0;
      hartreset       <= 0;
      data0           <= 0;
      data1           <= 0;
      sbaddress0      <= 0;
    end else begin
      if (DMI_CS & DMI_WR) begin
        case (DMI_AD)
          A_DATA0:      data0 <= DMI_DI;
          A_DATA1:      data1 <= DMI_DI;
          A_DMCONTROL: begin
            haltreq         <= DMI_DI[31];
            resumereq       <= DMI_DI[30];
            hartreset       <= DMI_DI[29];
            ackhavereset    <= DMI_DI[28];
            setresethaltreq <= DMI_DI[3];
            clrresethaltreq <= DMI_DI[2];
            ndmreset        <= DMI_DI[1];
            dmactive        <= DMI_DI[0];
          end
          A_DMSTATUS: begin
          end
          A_HARTINFO: begin
          end
          A_HAWINDOWSEL: begin
            hawindowsel <= DMI_DI[14:0];
          end
          A_HAWINDOW:   maskdata <= DMI_DI;
          A_ABSTRACTCS: begin
            cmderr <= (~DMI_DI[10:8]) & cmderr;
          end
          A_COMMAND: begin
            old_cmdtype <= DMI_DI[31:24];
            cmderr      <= ((cmdtype[7:0] == 8'd0) && (control[22:20] != 3'd2)) ? 2 : 0;
            if (control[19]) begin
              if (control[22:20] == 1) begin
                data1 <= data1 + 2;
              end else begin
                data1 <= data1 + 4;
              end
            end
          end
          A_ABSTRACTAUTO: begin
            autoexecprogbuf <= DMI_DI[31:16];
            autiexecdata    <= DMI_DI[11:0];
          end
          A_NEXTDM:     nextdm <= DMI_DI;
          A_AUTODATA:   authdata <= DMI_DI;
          A_SBCS: begin
            sbreadonaddr    <= DMI_DI[20];
            sbaccess        <= DMI_DI[19:17];
            sbautoincrement <= DMI_DI[16];
            sbreadondata    <= DMI_DI[15];
          end
          A_SBADDRESS0: sbaddress0 <= DMI_DI;
          A_SBDATA0: begin
            if (sbautoincrement) begin
              sbaddress0 <= sbaddress0 + 4;
            end
          end
          default: begin
          end
        endcase
      end else begin
        if ((DMI_AD == A_COMMAND) && (DMI_WR | DMI_RD)) begin
          if (control[19]) begin
            if (control[22:20] == 1) begin
              data1 <= data1 + 2;
            end else begin
              data1 <= data1 + 4;
            end
          end
        end
        if ((DMI_AD == A_SBDATA0) && (DMI_WR | DMI_RD)) begin
          if (sbautoincrement) begin
            sbaddress0 <= sbaddress0 + 4;
          end
        end

      end
    end
  end

  always @(posedge CLK or negedge RST_N) begin
    if (!RST_N) begin
      rdata <= 32'd0;
    end else begin
      case (DMI_AD)
        A_DATA0:        rdata <= data0_r;
        A_DMCONTROL:    rdata <= dmcontrol;
        A_DMSTATUS:     rdata <= dmstatus;
        A_HALTSUM1:     rdata <= haltsum1;
        A_HARTINFO:     rdata <= hartinfo;
        A_HAWINDOWSEL:  rdata <= {17'd0, hawindowsel};
        A_HAWINDOW:     rdata <= hawindow;
        A_ABSTRACTCS:   rdata <= abstractcs;
        A_COMMAND:      rdata <= command;
        A_ABSTRACTAUTO: rdata <= abstractauto;
        A_NEXTDM:       rdata <= nextdm;
        A_AUTODATA:     rdata <= authdata;
        A_HALTSUM2:     rdata <= haltsum2;
        A_HALTSUM3:     rdata <= haltsum3;
        A_SBCS:         rdata <= sbcs;
        A_SBADDRESS0:   rdata <= sbaddress0;
        A_SBDATA0:      rdata <= sbdata0_r;
        A_HALTSUM0:     rdata <= haltsum0;
        default:        rdata <= 32'd0;
      endcase
      if ((DMI_AD == A_COMMAND) && (DMI_WR | DMI_RD)) begin
        if ((cmdtype == 8'd0) || ((cmdtype == 8'd1) && (old_cmdtype == 8'd0))) begin
          data0_r <= AR_DI;
        end else if ((cmdtype == 8'd2) || ((cmdtype == 8'd1) && (old_cmdtype == 8'd2))) begin
          if (control[19] && (data1[1:0] == 2)) begin
            data0_r <= {16'd0, AM_DI[31:16]};
          end else begin
            data0_r <= AM_DI;
          end
        end
      end
      if ((DMI_AD == A_SBDATA0) && (DMI_WR | DMI_RD)) begin
        sbdata0_r <= SYS_DI;
      end
    end
  end

  assign DMI_DO = rdata;

  assign AR_EN = ((DMI_AD == A_COMMAND) && (DMI_WR | DMI_RD) && (cmdtype == 8'd0)) ? 1'b1 : 1'b0;
  assign AR_WR = (cmdtype == 8'd0) ? control[16] : 1'b0;
  assign AR_AD = (cmdtype == 8'd0) ? control[15:0] : 16'd0;
  assign AR_DO = data0;

  assign AM_EN = ((DMI_AD == A_COMMAND) && (DMI_WR | DMI_RD) && (cmdtype == 8'd2)) ? 1'b1 : 1'b0;
  assign AM_ST = (cmdtype == 8'd2) ? (control[22:20] == 2) ? 4'b1111 : 4'b0011 << data1[1:0] : 4'd0;
  assign AM_WR = (cmdtype == 8'd2) ? control[16] : 1'b0;
  assign AM_AD = data1;
  assign AM_DO = (cmdtype == 8'd2)?(control[22:20]==2)?data0:((data1[1:0]==2)?{data0[15:0],16'd0}:data0):32'd0;
  assign SYS_EN = ((DMI_AD == A_SBDATA0) && (DMI_WR | DMI_RD)) ? 1'b1 : 1'b0;
  assign SYS_WR = DMI_WR;
  assign SYS_AD = sbaddress0;
  assign SYS_DO = DMI_DI;

  assign O_HALTREQ = haltreq;
  assign O_RESUMEREQ = resumereq;
  assign O_HARTRESET = hartreset;
  assign O_NDMRESET = ndmreset;

endmodule

`default_nettype wire
