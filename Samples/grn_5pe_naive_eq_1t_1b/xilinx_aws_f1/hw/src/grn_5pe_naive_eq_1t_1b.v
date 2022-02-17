

module grn_5pe_naive_eq_1t_1b #
(
  parameter C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  parameter C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter C_M_AXI_ADDR_WIDTH = 64,
  parameter C_M_AXI_DATA_WIDTH = 32
)
(
  input ap_clk,
  input ap_rst_n,
  input s_axi_control_awvalid,
  output s_axi_control_awready,
  input [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_awaddr,
  input s_axi_control_wvalid,
  output s_axi_control_wready,
  input [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_wdata,
  input [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb,
  input s_axi_control_arvalid,
  output s_axi_control_arready,
  input [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_araddr,
  output s_axi_control_rvalid,
  input s_axi_control_rready,
  output [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_rdata,
  output [2-1:0] s_axi_control_rresp,
  output s_axi_control_bvalid,
  input s_axi_control_bready,
  output [2-1:0] s_axi_control_bresp,
  output interrupt,
  output m00_axi_awvalid,
  input m00_axi_awready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr,
  output [8-1:0] m00_axi_awlen,
  output m00_axi_wvalid,
  input m00_axi_wready,
  output [C_M_AXI_DATA_WIDTH-1:0] m00_axi_wdata,
  output [C_M_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb,
  output m00_axi_wlast,
  input m00_axi_bvalid,
  output m00_axi_bready,
  output m00_axi_arvalid,
  input m00_axi_arready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m00_axi_araddr,
  output [8-1:0] m00_axi_arlen,
  input m00_axi_rvalid,
  output m00_axi_rready,
  input [C_M_AXI_DATA_WIDTH-1:0] m00_axi_rdata,
  input m00_axi_rlast
);

  (* DONT_TOUCH = "yes" *)
  reg areset;
  wire ap_start;
  wire ap_idle;
  wire ap_done;
  wire ap_ready;
  wire [32-1:0] in_s0;
  wire [32-1:0] out_s0;
  wire [64-1:0] in0;
  wire [64-1:0] out0;

  always @(posedge ap_clk) begin
    areset <= ~ap_rst_n;
  end


  control_s_axi_1
  #(
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH)
  )
  control_s_axi_inst
  (
    .aclk(ap_clk),
    .areset(areset),
    .aclk_en(1'b1),
    .awvalid(s_axi_control_awvalid),
    .awready(s_axi_control_awready),
    .awaddr(s_axi_control_awaddr),
    .wvalid(s_axi_control_wvalid),
    .wready(s_axi_control_wready),
    .wdata(s_axi_control_wdata),
    .wstrb(s_axi_control_wstrb),
    .arvalid(s_axi_control_arvalid),
    .arready(s_axi_control_arready),
    .araddr(s_axi_control_araddr),
    .rvalid(s_axi_control_rvalid),
    .rready(s_axi_control_rready),
    .rdata(s_axi_control_rdata),
    .rresp(s_axi_control_rresp),
    .bvalid(s_axi_control_bvalid),
    .bready(s_axi_control_bready),
    .bresp(s_axi_control_bresp),
    .interrupt(interrupt),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_ready(ap_ready),
    .ap_idle(ap_idle),
    .in_s0(in_s0),
    .out_s0(out_s0),
    .in0(in0),
    .out0(out0)
  );


  app_top
  #(
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
  )
  app_inst
  (
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .in_s0(in_s0),
    .out_s0(out_s0),
    .in0(in0),
    .out0(out0),
    .m00_axi_awvalid(m00_axi_awvalid),
    .m00_axi_awready(m00_axi_awready),
    .m00_axi_awaddr(m00_axi_awaddr),
    .m00_axi_awlen(m00_axi_awlen),
    .m00_axi_wvalid(m00_axi_wvalid),
    .m00_axi_wready(m00_axi_wready),
    .m00_axi_wdata(m00_axi_wdata),
    .m00_axi_wstrb(m00_axi_wstrb),
    .m00_axi_wlast(m00_axi_wlast),
    .m00_axi_bvalid(m00_axi_bvalid),
    .m00_axi_bready(m00_axi_bready),
    .m00_axi_arvalid(m00_axi_arvalid),
    .m00_axi_arready(m00_axi_arready),
    .m00_axi_araddr(m00_axi_araddr),
    .m00_axi_arlen(m00_axi_arlen),
    .m00_axi_rvalid(m00_axi_rvalid),
    .m00_axi_rready(m00_axi_rready),
    .m00_axi_rdata(m00_axi_rdata),
    .m00_axi_rlast(m00_axi_rlast)
  );


  initial begin
    areset = 1'b1;
  end


endmodule



module control_s_axi_1 #
(
  parameter C_S_AXI_ADDR_WIDTH = 6,
  parameter C_S_AXI_DATA_WIDTH = 32
)
(
  input aclk,
  input areset,
  input aclk_en,
  input [C_S_AXI_ADDR_WIDTH-1:0] awaddr,
  input awvalid,
  output awready,
  input [C_S_AXI_DATA_WIDTH-1:0] wdata,
  input [C_S_AXI_DATA_WIDTH/8-1:0] wstrb,
  input wvalid,
  output wready,
  output [2-1:0] bresp,
  output bvalid,
  input bready,
  input [C_S_AXI_ADDR_WIDTH-1:0] araddr,
  input arvalid,
  output arready,
  output [C_S_AXI_DATA_WIDTH-1:0] rdata,
  output [2-1:0] rresp,
  output rvalid,
  input rready,
  output interrupt,
  output ap_start,
  input ap_done,
  input ap_ready,
  input ap_idle,
  output [32-1:0] in_s0,
  output [32-1:0] out_s0,
  output [64-1:0] in0,
  output [64-1:0] out0
);

  localparam ADDR_AP_CTRL = 6'h0;
  localparam ADDR_GIE = 6'h4;
  localparam ADDR_IER = 6'h8;
  localparam ADDR_ISR = 6'hc;
  localparam ADDR_IN_S0_DATA_0 = 6'h10;
  localparam ADDR_IN_S0_CTRL = 6'h14;
  localparam ADDR_OUT_S0_DATA_0 = 6'h18;
  localparam ADDR_OUT_S0_CTRL = 6'h1c;
  localparam ADDR_IN0_DATA_0 = 6'h20;
  localparam ADDR_IN0_DATA_1 = 6'h24;
  localparam ADDR_IN0_CTRL = 6'h28;
  localparam ADDR_OUT0_DATA_0 = 6'h2c;
  localparam ADDR_OUT0_DATA_1 = 6'h30;
  localparam ADDR_OUT0_CTRL = 6'h34;
  localparam WRIDLE = 2'd0;
  localparam WRDATA = 2'd1;
  localparam WRRESP = 2'd2;
  localparam WRRESET = 2'd3;
  localparam RDIDLE = 2'd0;
  localparam RDDATA = 2'd1;
  localparam RDRESET = 2'd2;
  localparam ADDR_BITS = 6;
  reg [2-1:0] wstate;
  reg [2-1:0] wnext;
  reg [ADDR_BITS-1:0] waddr;
  wire [32-1:0] wmask;
  wire aw_hs;
  wire w_hs;
  reg [2-1:0] rstate;
  reg [2-1:0] rnext;
  reg [32-1:0] rrdata;
  wire ar_hs;
  wire [ADDR_BITS-1:0] raddr;
  reg int_ap_idle;
  reg int_ap_ready;
  reg int_ap_done;
  reg int_ap_start;
  reg int_auto_restart;
  reg int_gie;
  reg [2-1:0] int_ier;
  reg [2-1:0] int_isr;
  reg [32-1:0] int_in_s0;
  reg [32-1:0] int_out_s0;
  reg [64-1:0] int_in0;
  reg [64-1:0] int_out0;
  assign awready = wstate == WRIDLE;
  assign wready = wstate == WRDATA;
  assign bresp = 2'b0;
  assign bvalid = wstate == WRRESP;
  assign wmask = { { 8{ wstrb[3] } }, { 8{ wstrb[2] } }, { 8{ wstrb[1] } }, { 8{ wstrb[0] } } };
  assign aw_hs = awvalid & awready;
  assign w_hs = wvalid & wready;

  always @(posedge aclk) begin
    if(areset) begin
      wstate <= WRRESET;
    end else begin
      if(aclk_en) begin
        wstate <= wnext;
      end 
    end
  end


  always @(*) begin
    case(wstate)
      WRIDLE: begin
        if(awvalid) begin
          wnext <= WRDATA;
        end else begin
          wnext <= WRIDLE;
        end
      end
      WRDATA: begin
        if(wvalid) begin
          wnext <= WRRESP;
        end else begin
          wnext <= WRDATA;
        end
      end
      WRRESP: begin
        if(bready) begin
          wnext <= WRIDLE;
        end else begin
          wnext <= WRRESP;
        end
      end
      default: begin
        wnext <= WRIDLE;
      end
    endcase
  end


  always @(posedge aclk) begin
    if(aclk_en) begin
      if(aw_hs) begin
        waddr <= awaddr[ADDR_BITS-1:0];
      end 
    end 
  end

  assign arready = rstate == RDIDLE;
  assign rdata = rrdata;
  assign rresp = 2'b0;
  assign rvalid = rstate == RDDATA;
  assign ar_hs = arvalid & arready;
  assign raddr = araddr[ADDR_BITS-1:0];

  always @(posedge aclk) begin
    if(areset) begin
      rstate <= RDRESET;
    end else begin
      if(aclk_en) begin
        rstate <= rnext;
      end 
    end
  end


  always @(*) begin
    case(rstate)
      RDIDLE: begin
        if(arvalid) begin
          rnext <= RDDATA;
        end else begin
          rnext <= RDIDLE;
        end
      end
      RDDATA: begin
        if(rready & rvalid) begin
          rnext <= RDIDLE;
        end else begin
          rnext <= RDDATA;
        end
      end
      default: begin
        rnext <= RDIDLE;
      end
    endcase
  end


  always @(posedge aclk) begin
    if(aclk_en) begin
      if(ar_hs) begin
        rrdata <= 1'b0;
        case(raddr)
          ADDR_AP_CTRL: begin
            rrdata[0] <= int_ap_start;
            rrdata[1] <= int_ap_done;
            rrdata[2] <= int_ap_idle;
            rrdata[3] <= int_ap_ready;
            rrdata[7] <= int_auto_restart;
          end
          ADDR_GIE: begin
            rrdata <= int_gie;
          end
          ADDR_IER: begin
            rrdata <= int_ier;
          end
          ADDR_ISR: begin
            rrdata <= int_isr;
          end
          ADDR_IN_S0_DATA_0: begin
            rrdata <= int_in_s0[31:0];
          end
          ADDR_OUT_S0_DATA_0: begin
            rrdata <= int_out_s0[31:0];
          end
          ADDR_IN0_DATA_0: begin
            rrdata <= int_in0[31:0];
          end
          ADDR_IN0_DATA_1: begin
            rrdata <= int_in0[63:32];
          end
          ADDR_OUT0_DATA_0: begin
            rrdata <= int_out0[31:0];
          end
          ADDR_OUT0_DATA_1: begin
            rrdata <= int_out0[63:32];
          end
        endcase
      end 
    end 
  end

  assign interrupt = int_gie & |int_isr;
  assign ap_start = int_ap_start;
  assign in_s0 = int_in_s0;
  assign out_s0 = int_out_s0;
  assign in0 = int_in0;
  assign out0 = int_out0;

  always @(posedge aclk) begin
    if(areset) begin
      int_ap_start <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_AP_CTRL) && wstrb[0] && wdata[0]) begin
          int_ap_start <= 1'b1;
        end else if(ap_ready) begin
          int_ap_start <= int_auto_restart;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_ap_done <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(ap_done) begin
          int_ap_done <= 1'b1;
        end else if(ar_hs && (raddr == ADDR_AP_CTRL)) begin
          int_ap_done <= 1'b0;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_ap_idle <= 1'b1;
    end else begin
      if(aclk_en) begin
        int_ap_idle <= ap_idle;
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_ap_ready <= 1'b0;
    end else begin
      if(aclk_en) begin
        int_ap_ready <= ap_ready;
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_auto_restart <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_AP_CTRL) && wstrb[0]) begin
          int_auto_restart <= wdata[7];
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_gie <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_GIE) && wstrb[0]) begin
          int_gie <= wdata[0];
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_ier <= 2'b0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_IER) && wstrb[0]) begin
          int_ier <= wdata[1:0];
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_isr[0] <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(int_ier[0] & ap_done) begin
          int_isr[0] <= 1'b1;
        end else if(w_hs && (waddr == ADDR_ISR) && wstrb[0]) begin
          int_isr[0] <= int_isr[0] ^ wdata[0];
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_isr[1] <= 1'b0;
    end else begin
      if(aclk_en) begin
        if(int_ier[1] & ap_ready) begin
          int_isr[1] <= 1'b1;
        end else if(w_hs && (waddr == ADDR_ISR) && wstrb[0]) begin
          int_isr[1] <= int_isr[1] ^ wdata[1];
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_in_s0[31:0] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_IN_S0_DATA_0)) begin
          int_in_s0[31:0] <= wdata[31:0] & wmask | int_in_s0[31:0] & ~wmask;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_out_s0[31:0] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_OUT_S0_DATA_0)) begin
          int_out_s0[31:0] <= wdata[31:0] & wmask | int_out_s0[31:0] & ~wmask;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_in0[31:0] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_IN0_DATA_0)) begin
          int_in0[31:0] <= wdata[31:0] & wmask | int_in0[31:0] & ~wmask;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_in0[63:32] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_IN0_DATA_1)) begin
          int_in0[63:32] <= wdata[31:0] & wmask | int_in0[63:32] & ~wmask;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_out0[31:0] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_OUT0_DATA_0)) begin
          int_out0[31:0] <= wdata[31:0] & wmask | int_out0[31:0] & ~wmask;
        end 
      end 
    end
  end


  always @(posedge aclk) begin
    if(areset) begin
      int_out0[63:32] <= 32'd0;
    end else begin
      if(aclk_en) begin
        if(w_hs && (waddr == ADDR_OUT0_DATA_1)) begin
          int_out0[63:32] <= wdata[31:0] & wmask | int_out0[63:32] & ~wmask;
        end 
      end 
    end
  end


  initial begin
    wstate = WRRESET;
    wnext = 0;
    waddr = 0;
    rstate = RDRESET;
    rnext = 0;
    rrdata = 0;
    int_ap_idle = 1'b1;
    int_ap_ready = 0;
    int_ap_done = 0;
    int_ap_start = 0;
    int_auto_restart = 0;
    int_gie = 0;
    int_ier = 0;
    int_isr = 0;
    int_in_s0 = 0;
    int_out_s0 = 0;
    int_in0 = 0;
    int_out0 = 0;
  end


endmodule



module app_top #
(
  parameter C_M_AXI_ADDR_WIDTH = 64,
  parameter C_M_AXI_DATA_WIDTH = 32
)
(
  input ap_clk,
  input ap_rst_n,
  output m00_axi_awvalid,
  input m00_axi_awready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr,
  output [8-1:0] m00_axi_awlen,
  output m00_axi_wvalid,
  input m00_axi_wready,
  output [C_M_AXI_DATA_WIDTH-1:0] m00_axi_wdata,
  output [C_M_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb,
  output m00_axi_wlast,
  input m00_axi_bvalid,
  output m00_axi_bready,
  output m00_axi_arvalid,
  input m00_axi_arready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m00_axi_araddr,
  output [8-1:0] m00_axi_arlen,
  input m00_axi_rvalid,
  output m00_axi_rready,
  input [C_M_AXI_DATA_WIDTH-1:0] m00_axi_rdata,
  input m00_axi_rlast,
  input ap_start,
  output ap_idle,
  output ap_done,
  output ap_ready,
  input [32-1:0] in_s0,
  input [32-1:0] out_s0,
  input [64-1:0] in0,
  input [64-1:0] out0
);

  localparam LP_NUM_EXAMPLES = 1;
  localparam LP_RD_MAX_OUTSTANDING = 16;
  localparam LP_WR_MAX_OUTSTANDING = 16;
  (* KEEP = "yes" *)
  reg reset;
  reg ap_idle_r;
  reg ap_done_r;
  wire [LP_NUM_EXAMPLES-1:0] rd_ctrl_done;
  wire [LP_NUM_EXAMPLES-1:0] wr_ctrl_done;
  reg [LP_NUM_EXAMPLES-1:0] acc_user_done_rd_data;
  reg [LP_NUM_EXAMPLES-1:0] acc_user_done_wr_data;
  wire [LP_NUM_EXAMPLES-1:0] acc_user_request_read;
  wire [LP_NUM_EXAMPLES-1:0] acc_user_read_data_valid;
  wire [C_M_AXI_DATA_WIDTH*LP_NUM_EXAMPLES-1:0] acc_user_read_data;
  wire [LP_NUM_EXAMPLES-1:0] acc_user_available_write;
  wire [LP_NUM_EXAMPLES-1:0] acc_user_request_write;
  wire [C_M_AXI_DATA_WIDTH*LP_NUM_EXAMPLES-1:0] acc_user_write_data;
  wire acc_user_done;
  wire rd_tvalid0;
  wire rd_tready0;
  wire rd_tlast0;
  wire [C_M_AXI_DATA_WIDTH-1:0] rd_tdata0;
  wire wr_tvalid0;
  wire wr_tready0;
  wire [C_M_AXI_DATA_WIDTH-1:0] wr_tdata0;
  reg [2-1:0] fsm_reset;
  reg areset;
  reg ap_start_pulse;
  localparam FSM_STATE_START = 2'b0;
  localparam FSM_STATE_RESET = 2'b1;
  localparam FSM_STATE_RUNNING = 2'b10;

  always @(posedge ap_clk) begin
    reset <= ~ap_rst_n;
  end


  always @(posedge ap_clk) begin
    if(reset) begin
      areset <= 1'b0;
      fsm_reset <= FSM_STATE_START;
      ap_start_pulse <= 1'b0;
    end else begin
      areset <= 1'b0;
      ap_start_pulse <= 1'b0;
      case(fsm_reset)
        FSM_STATE_START: begin
          if(ap_start) begin
            areset <= 1'b1;
            fsm_reset <= FSM_STATE_RESET;
          end 
        end
        FSM_STATE_RESET: begin
          ap_start_pulse <= 1'b1;
          fsm_reset <= FSM_STATE_RUNNING;
        end
        FSM_STATE_RUNNING: begin
          if(~ap_start) begin
            fsm_reset <= FSM_STATE_START;
          end 
        end
      endcase
    end
  end


  always @(posedge ap_clk) begin
    if(areset) begin
      ap_idle_r <= 1'b1;
    end else begin
      ap_idle_r <= (ap_done)? 1'b1 : 
                   (ap_start_pulse)? 1'b0 : ap_idle;
    end
  end

  assign ap_idle = ap_idle_r;

  always @(posedge ap_clk) begin
    if(areset) begin
      ap_done_r <= 1'b0;
    end else begin
      ap_done_r <= (ap_done)? 1'b0 : ap_done_r | acc_user_done;
    end
  end

  assign ap_done = ap_done_r;
  assign ap_ready = ap_done;
  integer i;

  always @(posedge ap_clk) begin
    if(areset) begin
      acc_user_done_rd_data <= { LP_NUM_EXAMPLES{ 1'b0 } };
      acc_user_done_wr_data <= { LP_NUM_EXAMPLES{ 1'b0 } };
    end else begin
      for(i=0; i<LP_NUM_EXAMPLES; i=i+1) begin
        acc_user_done_rd_data[i] <= (rd_ctrl_done[i])? 1'b1 : acc_user_done_rd_data[i];
        acc_user_done_wr_data[i] <= (wr_ctrl_done[i])? 1'b1 : acc_user_done_wr_data[i];
      end
    end
  end

  assign rd_tready0 = acc_user_request_read[0];
  assign acc_user_read_data_valid = {rd_tvalid0};
  assign acc_user_read_data = {rd_tdata0};

  assign acc_user_available_write = {wr_tready0};
  assign wr_tvalid0 = acc_user_request_write[0];
  assign wr_tdata0 = acc_user_write_data[1*C_M_AXI_DATA_WIDTH-1:0*C_M_AXI_DATA_WIDTH];

  axi_reader_wrapper
  #(
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
    .C_XFER_SIZE_WIDTH(32),
    .C_MAX_OUTSTANDING(LP_RD_MAX_OUTSTANDING),
    .C_INCLUDE_DATA_FIFO(1)
  )
  axi_reader_0
  (
    .aclk(ap_clk),
    .areset(areset),
    .ctrl_start(ap_start_pulse),
    .ctrl_done(rd_ctrl_done[0]),
    .ctrl_addr_offset(in0),
    .ctrl_xfer_size_in_bytes(in_s0),
    .m_axi_arvalid(m00_axi_arvalid),
    .m_axi_arready(m00_axi_arready),
    .m_axi_araddr(m00_axi_araddr),
    .m_axi_arlen(m00_axi_arlen),
    .m_axi_rvalid(m00_axi_rvalid),
    .m_axi_rready(m00_axi_rready),
    .m_axi_rdata(m00_axi_rdata),
    .m_axi_rlast(m00_axi_rlast),
    .m_axis_aclk(ap_clk),
    .m_axis_areset(areset),
    .m_axis_tvalid(rd_tvalid0),
    .m_axis_tready(rd_tready0),
    .m_axis_tlast(rd_tlast0),
    .m_axis_tdata(rd_tdata0)
  );


  axi_writer_wrapper
  #(
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
    .C_XFER_SIZE_WIDTH(32),
    .C_MAX_OUTSTANDING(LP_WR_MAX_OUTSTANDING),
    .C_INCLUDE_DATA_FIFO(1)
  )
  axi_writer_0
  (
    .aclk(ap_clk),
    .areset(areset),
    .ctrl_start(ap_start_pulse),
    .ctrl_done(wr_ctrl_done[0]),
    .ctrl_addr_offset(out0),
    .ctrl_xfer_size_in_bytes(out_s0),
    .m_axi_awvalid(m00_axi_awvalid),
    .m_axi_awready(m00_axi_awready),
    .m_axi_awaddr(m00_axi_awaddr),
    .m_axi_awlen(m00_axi_awlen),
    .m_axi_wvalid(m00_axi_wvalid),
    .m_axi_wready(m00_axi_wready),
    .m_axi_wdata(m00_axi_wdata),
    .m_axi_wstrb(m00_axi_wstrb),
    .m_axi_wlast(m00_axi_wlast),
    .m_axi_bvalid(m00_axi_bvalid),
    .m_axi_bready(m00_axi_bready),
    .s_axis_aclk(ap_clk),
    .s_axis_areset(areset),
    .s_axis_tvalid(wr_tvalid0),
    .s_axis_tready(wr_tready0),
    .s_axis_tdata(wr_tdata0)
  );


  grn_acc
  acc
  (
    .clk(ap_clk),
    .rst(areset),
    .start(ap_start_pulse),
    .acc_user_done_rd_data(acc_user_done_rd_data),
    .acc_user_done_wr_data(acc_user_done_wr_data),
    .acc_user_request_read(acc_user_request_read),
    .acc_user_read_data_valid(acc_user_read_data_valid),
    .acc_user_read_data(acc_user_read_data),
    .acc_user_available_write(acc_user_available_write),
    .acc_user_request_write(acc_user_request_write),
    .acc_user_write_data(acc_user_write_data),
    .acc_user_done(acc_user_done)
  );


  initial begin
    reset = 1'b1;
    ap_idle_r = 1'b1;
    ap_done_r = 0;
    acc_user_done_rd_data = 0;
    acc_user_done_wr_data = 0;
    fsm_reset = FSM_STATE_START;
    areset = 1'b1;
    ap_start_pulse = 0;
  end


endmodule



module axi_reader_wrapper #
(
  parameter C_M_AXI_ADDR_WIDTH = 64,
  parameter C_M_AXI_DATA_WIDTH = 32,
  parameter C_XFER_SIZE_WIDTH = 64,
  parameter C_MAX_OUTSTANDING = 16,
  parameter C_INCLUDE_DATA_FIFO = 1
)
(
  input aclk,
  input areset,
  input ctrl_start,
  output ctrl_done,
  input [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset,
  input [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes,
  output m_axi_arvalid,
  input m_axi_arready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
  output [8-1:0] m_axi_arlen,
  input m_axi_rvalid,
  output m_axi_rready,
  input [C_M_AXI_DATA_WIDTH-1:0] m_axi_rdata,
  input m_axi_rlast,
  input m_axis_aclk,
  input m_axis_areset,
  output m_axis_tvalid,
  input m_axis_tready,
  output [C_M_AXI_DATA_WIDTH-1:0] m_axis_tdata,
  output m_axis_tlast
);

  axi_reader #(
            .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH  ) ,
            .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH  ) ,
            .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH   ) ,
            .C_MAX_OUTSTANDING   ( C_MAX_OUTSTANDING   ) ,
            .C_INCLUDE_DATA_FIFO ( C_INCLUDE_DATA_FIFO )
          )
          inst_axi_reader (
            .aclk                    ( aclk                   ) ,
            .areset                  ( areset                 ) ,
            .ctrl_start              ( ctrl_start             ) ,
            .ctrl_done               ( ctrl_done              ) ,
            .ctrl_addr_offset        ( ctrl_addr_offset       ) ,
            .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes) ,
            .m_axi_arvalid           ( m_axi_arvalid          ) ,
            .m_axi_arready           ( m_axi_arready          ) ,
            .m_axi_araddr            ( m_axi_araddr           ) ,
            .m_axi_arlen             ( m_axi_arlen            ) ,
            .m_axi_rvalid            ( m_axi_rvalid           ) ,
            .m_axi_rready            ( m_axi_rready           ) ,
            .m_axi_rdata             ( m_axi_rdata            ) ,
            .m_axi_rlast             ( m_axi_rlast            ) ,
            .m_axis_aclk             ( m_axis_aclk            ) ,
            .m_axis_areset           ( m_axis_areset          ) ,
            .m_axis_tvalid           ( m_axis_tvalid          ) ,
            .m_axis_tready           ( m_axis_tready          ) ,
            .m_axis_tlast            ( m_axis_tlast           ) ,
            .m_axis_tdata            ( m_axis_tdata           )
          );

endmodule



module axi_writer_wrapper #
(
  parameter C_M_AXI_ADDR_WIDTH = 64,
  parameter C_M_AXI_DATA_WIDTH = 32,
  parameter C_XFER_SIZE_WIDTH = 64,
  parameter C_MAX_OUTSTANDING = 16,
  parameter C_INCLUDE_DATA_FIFO = 1
)
(
  input aclk,
  input areset,
  input ctrl_start,
  output ctrl_done,
  input [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset,
  input [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes,
  output m_axi_awvalid,
  input m_axi_awready,
  output [C_M_AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
  output [8-1:0] m_axi_awlen,
  output m_axi_wvalid,
  input m_axi_wready,
  output [C_M_AXI_DATA_WIDTH-1:0] m_axi_wdata,
  output [C_M_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
  output m_axi_wlast,
  input m_axi_bvalid,
  output m_axi_bready,
  input s_axis_aclk,
  input s_axis_areset,
  input s_axis_tvalid,
  output s_axis_tready,
  input [C_M_AXI_DATA_WIDTH-1:0] s_axis_tdata
);

  axi_writer #(
            .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH ) ,
            .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH ) ,
            .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH  ) ,
            .C_MAX_OUTSTANDING   ( C_MAX_OUTSTANDING  ) ,
            .C_INCLUDE_DATA_FIFO ( C_INCLUDE_DATA_FIFO)
          )
          inst_axi_writer (
            .aclk                    ( aclk                   ) ,
            .areset                  ( areset                 ) ,
            .ctrl_start              ( ctrl_start             ) ,
            .ctrl_done               ( ctrl_done              ) ,
            .ctrl_addr_offset        ( ctrl_addr_offset       ) ,
            .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes) ,
            .m_axi_awvalid           ( m_axi_awvalid) ,
            .m_axi_awready           ( m_axi_awready) ,
            .m_axi_awaddr            ( m_axi_awaddr ) ,
            .m_axi_awlen             ( m_axi_awlen  ) ,
            .m_axi_wvalid            ( m_axi_wvalid ) ,
            .m_axi_wready            ( m_axi_wready ) ,
            .m_axi_wdata             ( m_axi_wdata  ) ,
            .m_axi_wstrb             ( m_axi_wstrb  ) ,
            .m_axi_wlast             ( m_axi_wlast  ) ,
            .m_axi_bvalid            ( m_axi_bvalid ) ,
            .m_axi_bready            ( m_axi_bready ) ,
            .s_axis_aclk             ( s_axis_aclk  ) ,
            .s_axis_areset           ( s_axis_areset) ,
            .s_axis_tvalid           (s_axis_tvalid ) ,
            .s_axis_tready           (s_axis_tready ) ,
            .s_axis_tdata            (s_axis_tdata  )
          );

endmodule



module grn_acc
(
  input clk,
  input rst,
  input start,
  input [1-1:0] acc_user_done_rd_data,
  input [1-1:0] acc_user_done_wr_data,
  output [1-1:0] acc_user_request_read,
  input [1-1:0] acc_user_read_data_valid,
  input [32-1:0] acc_user_read_data,
  input [1-1:0] acc_user_available_write,
  output [1-1:0] acc_user_request_write,
  output [32-1:0] acc_user_write_data,
  output acc_user_done
);

  reg start_reg;
  wire [1-1:0] grn_aws_done;
  assign acc_user_done = &grn_aws_done;

  always @(posedge clk) begin
    if(rst) begin
      start_reg <= 0;
    end else begin
      start_reg <= start_reg | start;
    end
  end


  grn_aws_1
  grn_aws_1_0
  (
    .clk(clk),
    .rst(rst),
    .start(start_reg),
    .grn_aws_done_rd_data(acc_user_done_rd_data[0]),
    .grn_aws_done_wr_data(acc_user_done_wr_data[0]),
    .grn_aws_request_read(acc_user_request_read[0]),
    .grn_aws_read_data_valid(acc_user_read_data_valid[0]),
    .grn_aws_read_data(acc_user_read_data[31:0]),
    .grn_aws_available_write(acc_user_available_write[0]),
    .grn_aws_request_write(acc_user_request_write[0]),
    .grn_aws_write_data(acc_user_write_data[31:0]),
    .grn_aws_done(grn_aws_done[0])
  );


  initial begin
    start_reg = 0;
  end


endmodule



module grn_aws_1
(
  input clk,
  input rst,
  input start,
  input grn_aws_done_rd_data,
  input grn_aws_done_wr_data,
  output reg grn_aws_request_read,
  input grn_aws_read_data_valid,
  input [32-1:0] grn_aws_read_data,
  input grn_aws_available_write,
  output reg grn_aws_request_write,
  output reg [32-1:0] grn_aws_write_data,
  output grn_aws_done
);

  assign grn_aws_done = &{ grn_aws_done_wr_data, grn_aws_done_rd_data };

  // grn pe instantiation regs and wires - Begin
  wire [1-1:0] grn_pe_config_output_done;
  wire [1-1:0] grn_pe_config_output_valid;
  wire [32-1:0] grn_pe_config_output [0:1-1];
  wire [1-1:0] grn_pe_output_read_enable;
  wire [1-1:0] grn_pe_output_valid;
  wire [32-1:0] grn_pe_output_data [0:1-1];
  wire [1-1:0] grn_pe_output_available;
  // grn pe instantiation regs and wires - end

  //Config wires and regs - Begin
  localparam [2-1:0] fsm_sd_idle = 0;
  localparam [2-1:0] fsm_sd_send_data = 1;
  localparam [2-1:0] fsm_sd_done = 2;
  reg [2-1:0] fms_cs;
  reg config_valid;
  reg [32-1:0] config_data;
  reg config_done;
  reg flag;
  //Config wires and regs - End

  //Data Reading - Begin

  always @(posedge clk) begin
    if(rst) begin
      grn_aws_request_read <= 0;
      config_valid <= 0;
      fms_cs <= fsm_sd_idle;
      config_done <= 0;
      flag <= 0;
    end else begin
      if(start) begin
        config_valid <= 0;
        grn_aws_request_read <= 0;
        flag <= 0;
        case(fms_cs)
          fsm_sd_idle: begin
            if(grn_aws_read_data_valid) begin
              grn_aws_request_read <= 1;
              flag <= 1;
              fms_cs <= fsm_sd_send_data;
            end else if(grn_aws_done_rd_data) begin
              fms_cs <= fsm_sd_done;
            end 
          end
          fsm_sd_send_data: begin
            if(grn_aws_read_data_valid | flag) begin
              config_data <= grn_aws_read_data;
              config_valid <= 1;
              grn_aws_request_read <= 1;
            end else if(grn_aws_done_rd_data) begin
              fms_cs <= fsm_sd_done;
            end else begin
              fms_cs <= fsm_sd_idle;
            end
          end
          fsm_sd_done: begin
            config_done <= 1;
          end
        endcase
      end 
    end
  end

  //Data Reading - End

  //Data Consumer - Begin
  reg consume_rd_enable;
  wire consume_rd_available;
  wire consume_rd_valid;
  wire [32-1:0] consume_rd_data;
  reg [2-1:0] fsm_consume_data;
  localparam fsm_consume_data_rq_rd = 0;
  localparam fsm_consume_data_rd = 1;
  localparam fsm_consume_data_wr = 2;

  always @(posedge clk) begin
    if(rst) begin
      consume_rd_enable <= 0;
      grn_aws_request_write <= 0;
      fsm_consume_data <= fsm_consume_data_rq_rd;
    end else begin
      consume_rd_enable <= 0;
      grn_aws_request_write <= 0;
      case(fsm_consume_data)
        fsm_consume_data_rq_rd: begin
          if(consume_rd_available) begin
            consume_rd_enable <= 1;
            fsm_consume_data <= fsm_consume_data_rd;
          end 
        end
        fsm_consume_data_rd: begin
          if(consume_rd_valid) begin
            grn_aws_write_data <= consume_rd_data;
            fsm_consume_data <= fsm_consume_data_wr;
          end 
        end
        fsm_consume_data_wr: begin
          if(grn_aws_available_write) begin
            grn_aws_request_write <= 1;
            fsm_consume_data <= fsm_consume_data_rq_rd;
          end 
        end
      endcase
    end
  end

  //Data Consumer - Begin

  //Assigns to the last PE
  assign grn_pe_output_valid[0] = 0;
  assign grn_pe_output_data[0] = 0;
  assign grn_pe_output_available[0] = 0;

  //PE modules instantiation - Begin

  grn_naive_pe
  grn_naive_pe_0
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(config_done),
    .config_input_valid(config_valid),
    .config_input(config_data),
    .config_output_done(grn_pe_config_output_done[0]),
    .config_output_valid(grn_pe_config_output_valid[0]),
    .config_output(grn_pe_config_output[0]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[0]),
    .pe_bypass_valid(grn_pe_output_valid[0]),
    .pe_bypass_data(grn_pe_output_data[0]),
    .pe_bypass_available(grn_pe_output_available[0]),
    .pe_output_read_enable(consume_rd_enable),
    .pe_output_valid(consume_rd_valid),
    .pe_output_data(consume_rd_data),
    .pe_output_available(consume_rd_available)
  );

  //PE modules instantiation - End

  initial begin
    grn_aws_request_read = 0;
    grn_aws_request_write = 0;
    grn_aws_write_data = 0;
    fms_cs = 0;
    config_valid = 0;
    config_data = 0;
    config_done = 0;
    flag = 0;
    consume_rd_enable = 0;
    fsm_consume_data = 0;
  end


endmodule



module grn_naive_pe
(
  input clk,
  input rst,
  input config_input_done,
  input config_input_valid,
  input [32-1:0] config_input,
  output reg config_output_done,
  output reg config_output_valid,
  output reg [32-1:0] config_output,
  output reg pe_bypass_read_enable,
  input pe_bypass_valid,
  input [32-1:0] pe_bypass_data,
  input pe_bypass_available,
  input pe_output_read_enable,
  output pe_output_valid,
  output [32-1:0] pe_output_data,
  output pe_output_available
);


  //configuration wires and regs - begin
  reg is_configured;
  wire [32-1:0] pe_init_conf;
  wire [32-1:0] pe_end_conf;
  reg [64-1:0] pe_data_conf;
  assign pe_init_conf = pe_data_conf[31:0];
  assign pe_end_conf = pe_data_conf[63:32];
  reg [1-1:0] config_counter;
  //configuration wires and regs - end

  // regs and wires to control the grn core
  reg start_grn;
  wire [5-1:0] grn_initial_state;
  wire [5-1:0] grn_final_state;
  reg grn_output_read_enable;
  wire grn_output_valid;
  wire [32-1:0] grn_output_data;
  wire grn_output_available;
  reg [3-1:0] fsm_pe_jo;
  localparam fsm_pe_jo_look_grn = 0;
  localparam fsm_pe_jo_rd_grn = 1;
  localparam fsm_pe_jo_wr_grn = 2;
  localparam fsm_pe_jo_look_pe = 3;
  localparam fsm_pe_jo_rd_pe = 4;
  localparam fsm_pe_jo_wr_pe = 5;
  reg [2-1:0] rd_wr_counter;

  //Fifo out wires and regs
  reg fifo_out_write_enable;
  reg [32-1:0] fifo_out_input_data;
  wire fifo_out_empty;
  wire fifo_out_full;

  //configuration sector - begin

  always @(posedge clk) begin
    config_output_valid <= 0;
    config_output_done <= config_input_done;
    if(rst) begin
      is_configured <= 0;
      config_counter <= 0;
    end else begin
      if(config_input_valid) begin
        config_counter <= config_counter + 1;
        if(config_counter == 1) begin
          is_configured <= 1;
        end 
        if(~is_configured) begin
          pe_data_conf <= { config_input, pe_data_conf[63:32] };
        end else begin
          config_output_valid <= config_input_valid;
          config_output <= config_input;
        end
      end 
    end
  end

  //configuration sector - end

  //execution sector - begin

  always @(posedge clk) begin
    if(rst) begin
      start_grn <= 0;
      grn_output_read_enable <= 0;
      fifo_out_write_enable <= 0;
      pe_bypass_read_enable <= 0;
      fsm_pe_jo <= fsm_pe_jo_look_grn;
    end else begin
      if(is_configured) begin
        start_grn <= 1;
        grn_output_read_enable <= 0;
        fifo_out_write_enable <= 0;
        pe_bypass_read_enable <= 0;
        case(fsm_pe_jo)
          fsm_pe_jo_look_grn: begin
            fsm_pe_jo <= fsm_pe_jo_look_pe;
            if(grn_output_available) begin
              rd_wr_counter <= 0;
              fsm_pe_jo <= fsm_pe_jo_rd_grn;
            end 
          end
          fsm_pe_jo_rd_grn: begin
            if(grn_output_available && ~fifo_out_full) begin
              grn_output_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_grn;
            end 
          end
          fsm_pe_jo_wr_grn: begin
            if(grn_output_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_grn;
              if(rd_wr_counter == 3) begin
                fsm_pe_jo <= fsm_pe_jo_look_pe;
              end 
              fifo_out_input_data <= grn_output_data;
              rd_wr_counter <= rd_wr_counter + 1;
              fifo_out_write_enable <= 1;
            end 
          end
          fsm_pe_jo_look_pe: begin
            fsm_pe_jo <= fsm_pe_jo_look_grn;
            if(pe_bypass_available) begin
              rd_wr_counter <= 0;
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
            end 
          end
          fsm_pe_jo_rd_pe: begin
            if(pe_bypass_available && ~fifo_out_full) begin
              pe_bypass_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_pe;
            end 
          end
          fsm_pe_jo_wr_pe: begin
            if(pe_bypass_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
              if(rd_wr_counter == 3) begin
                fsm_pe_jo <= fsm_pe_jo_look_grn;
              end 
              fifo_out_input_data <= pe_bypass_data;
              fifo_out_write_enable <= 1;
              rd_wr_counter <= rd_wr_counter + 1;
            end 
          end
        endcase
      end 
    end
  end

  // Grn core instantiation
  assign grn_initial_state = pe_init_conf[4:0];
  assign grn_final_state = pe_end_conf[4:0];

  grn_naive_core
  grn_naive_core
  (
    .clk(clk),
    .rst(rst),
    .start(start_grn),
    .initial_state(grn_initial_state),
    .final_state(grn_final_state),
    .output_read_enable(grn_output_read_enable),
    .output_valid(grn_output_valid),
    .output_data(grn_output_data),
    .output_available(grn_output_available)
  );

  assign pe_output_available = ~fifo_out_empty;

  fifo
  #(
    .FIFO_WIDTH(32),
    .FIFO_DEPTH_BITS(5)
  )
  pe_naive_fifo_out
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_out_write_enable),
    .input_data(fifo_out_input_data),
    .output_read_enable(pe_output_read_enable),
    .output_valid(pe_output_valid),
    .output_data(pe_output_data),
    .empty(fifo_out_empty),
    .almostfull(fifo_out_full)
  );


  initial begin
    config_output_done = 0;
    config_output_valid = 0;
    config_output = 0;
    pe_bypass_read_enable = 0;
    is_configured = 0;
    pe_data_conf = 0;
    config_counter = 0;
    start_grn = 0;
    grn_output_read_enable = 0;
    fsm_pe_jo = 0;
    rd_wr_counter = 0;
    fifo_out_write_enable = 0;
    fifo_out_input_data = 0;
  end


endmodule



module grn_naive_core
(
  input clk,
  input rst,
  input start,
  input [5-1:0] initial_state,
  input [5-1:0] final_state,
  input output_read_enable,
  output output_valid,
  output [32-1:0] output_data,
  output output_available
);

  // The grn core naive configuration consists in two buses with the initial state and the final 
  // state to be searched.
  //The naive kernel output data is the FIFO data output that contains all the data found.

  //Fifo wires and regs
  reg fifo_write_enable;
  reg [32-1:0] fifo_input_data;
  wire fifo_full;
  wire fifo_empty;

  // Wires and regs to be used in control and execution of the grn naive
  reg [5-1:0] actual_state_s1;
  wire [5-1:0] next_state_s1;
  reg [5-1:0] actual_state_s2;
  wire [5-1:0] next_state_s2;
  reg [5-1:0] exec_state;
  reg flag_pulse;
  reg flag_first_it;
  reg [32-1:0] transient_counter;
  reg [32-1:0] period_counter;
  reg [128-1:0] data_to_write;
  reg [2-1:0] write_counter;

  //State machine to control the grn algorithm execution
  reg [3-1:0] fsm_naive;
  localparam fsm_naive_set = 0;
  localparam fsm_naive_init = 1;
  localparam fsm_naive_transient_finder = 2;
  localparam fsm_naive_period_finder = 3;
  localparam fsm_naive_prepare_to_write = 4;
  localparam fsm_naive_write = 5;
  localparam fsm_naive_verify = 6;
  localparam fsm_naive_done = 7;

  always @(posedge clk) begin
    if(rst) begin
      fifo_write_enable <= 0;
      fsm_naive <= fsm_naive_set;
    end else begin
      if(start) begin
        fifo_write_enable <= 0;
        case(fsm_naive)
          fsm_naive_set: begin
            exec_state <= initial_state;
            fsm_naive <= fsm_naive_init;
          end
          fsm_naive_init: begin
            actual_state_s1 <= exec_state;
            actual_state_s2 <= exec_state;
            transient_counter <= 0;
            period_counter <= 0;
            flag_first_it <= 1;
            flag_pulse <= 0;
            fsm_naive <= fsm_naive_transient_finder;
          end
          fsm_naive_transient_finder: begin
            flag_first_it <= 0;
            if((actual_state_s1 == actual_state_s2) && ~flag_first_it && ~flag_pulse) begin
              flag_first_it <= 1;
              fsm_naive <= fsm_naive_period_finder;
            end else begin
              actual_state_s2 <= next_state_s2;
              if(flag_pulse) begin
                transient_counter <= transient_counter + 1;
                flag_pulse <= 0;
              end else begin
                flag_pulse <= 1;
                actual_state_s1 <= next_state_s1;
              end
            end
          end
          fsm_naive_period_finder: begin
            flag_first_it <= 0;
            if((actual_state_s1 == actual_state_s2) && ~flag_first_it) begin
              period_counter <= period_counter - 1;
              fsm_naive <= fsm_naive_prepare_to_write;
            end else begin
              actual_state_s2 <= next_state_s2;
              period_counter <= period_counter + 1;
            end
          end
          fsm_naive_prepare_to_write: begin
            data_to_write <= { 27'b0, exec_state, 27'b0, actual_state_s1, transient_counter, period_counter };
            fsm_naive <= fsm_naive_write;
            write_counter <= 0;
          end
          fsm_naive_write: begin
            if(write_counter == 3) begin
              fsm_naive <= fsm_naive_verify;
            end 
            if(~fifo_full) begin
              write_counter <= write_counter + 1;
              fifo_write_enable <= 1;
              data_to_write <= { 32'b0, data_to_write[127:32] };
              fifo_input_data <= data_to_write[31:0];
            end 
          end
          fsm_naive_verify: begin
            if(exec_state == final_state) begin
              fsm_naive <= fsm_naive_done;
            end else begin
              exec_state <= exec_state + 1;
              fsm_naive <= fsm_naive_init;
            end
          end
          fsm_naive_done: begin
          end
        endcase
      end 
    end
  end

  //Output data fifo instantiation
  assign output_available = ~fifo_empty;

  fifo
  #(
    .FIFO_WIDTH(32),
    .FIFO_DEPTH_BITS(5)
  )
  grn_naive_core_output_fifo
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_write_enable),
    .input_data(fifo_input_data),
    .output_read_enable(output_read_enable),
    .output_valid(output_valid),
    .output_data(output_data),
    .empty(fifo_empty),
    .almostfull(fifo_full)
  );


  // Here are the GRN equations to be used in the core execution are created
  // For S1 pointer
  assign next_state_s1[0] =    (actual_state_s1[0]||actual_state_s1[1])   &&   (   !actual_state_s1[4])   &&   (   !actual_state_s1[2])   ;
  assign next_state_s1[1] = actual_state_s1[3]&&   !actual_state_s1[0];
  assign next_state_s1[2] = actual_state_s1[0]&&   !actual_state_s1[3];
  assign next_state_s1[3] = actual_state_s1[0]&&actual_state_s1[4]&&   (   !actual_state_s1[1])   &&   (   !actual_state_s1[3])   ;
  assign next_state_s1[4] = actual_state_s1[0]&&   (   !actual_state_s1[4])   &&   (   !actual_state_s1[2])   ;

  // For S2 pointer
  assign next_state_s2[0] =    (actual_state_s2[0]||actual_state_s2[1])   &&   (   !actual_state_s2[4])   &&   (   !actual_state_s2[2])   ;
  assign next_state_s2[1] = actual_state_s2[3]&&   !actual_state_s2[0];
  assign next_state_s2[2] = actual_state_s2[0]&&   !actual_state_s2[3];
  assign next_state_s2[3] = actual_state_s2[0]&&actual_state_s2[4]&&   (   !actual_state_s2[1])   &&   (   !actual_state_s2[3])   ;
  assign next_state_s2[4] = actual_state_s2[0]&&   (   !actual_state_s2[4])   &&   (   !actual_state_s2[2])   ;


  initial begin
    fifo_write_enable = 0;
    fifo_input_data = 0;
    actual_state_s1 = 0;
    actual_state_s2 = 0;
    exec_state = 0;
    flag_pulse = 0;
    flag_first_it = 0;
    transient_counter = 0;
    period_counter = 0;
    data_to_write = 0;
    write_counter = 0;
    fsm_naive = 0;
  end


endmodule



module fifo #
(
  parameter FIFO_WIDTH = 32,
  parameter FIFO_DEPTH_BITS = 8,
  parameter FIFO_ALMOSTFULL_THRESHOLD = 2 ** FIFO_DEPTH_BITS - 4,
  parameter FIFO_ALMOSTEMPTY_THRESHOLD = 2
)
(
  input clk,
  input rst,
  input write_enable,
  input [FIFO_WIDTH-1:0] input_data,
  input output_read_enable,
  output reg output_valid,
  output reg [FIFO_WIDTH-1:0] output_data,
  output reg empty,
  output reg almostempty,
  output reg full,
  output reg almostfull,
  output reg [FIFO_DEPTH_BITS+1-1:0] data_count
);

  reg [FIFO_DEPTH_BITS-1:0] read_pointer;
  reg [FIFO_DEPTH_BITS-1:0] write_pointer;
  (* ramstyle = "AUTO, no_rw_check" *) reg  [FIFO_WIDTH-1:0] mem[0:2**FIFO_DEPTH_BITS-1];
  /*
  reg [FIFO_WIDTH-1:0] mem [0:2**FIFO_DEPTH_BITS-1];
  */

  always @(posedge clk) begin
    if(rst) begin
      empty <= 1;
      almostempty <= 1;
      full <= 0;
      almostfull <= 0;
      read_pointer <= 0;
      write_pointer <= 0;
      data_count <= 0;
    end else begin
      case({ write_enable, output_read_enable })
        3: begin
          read_pointer <= read_pointer + 1;
          write_pointer <= write_pointer + 1;
        end
        2: begin
          if(~full) begin
            write_pointer <= write_pointer + 1;
            data_count <= data_count + 1;
            empty <= 0;
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD - 1) begin
              almostempty <= 0;
            end 
            if(data_count == 2 ** FIFO_DEPTH_BITS - 1) begin
              full <= 1;
            end 
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD - 1) begin
              almostfull <= 1;
            end 
          end 
        end
        1: begin
          if(~empty) begin
            read_pointer <= read_pointer + 1;
            data_count <= data_count - 1;
            full <= 0;
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD) begin
              almostfull <= 0;
            end 
            if(data_count == 1) begin
              empty <= 1;
            end 
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD) begin
              almostempty <= 1;
            end 
          end 
        end
      endcase
    end
  end


  always @(posedge clk) begin
    if(rst) begin
      output_valid <= 0;
    end else begin
      output_valid <= 0;
      if(write_enable == 1) begin
        mem[write_pointer] <= input_data;
      end 
      if(output_read_enable == 1) begin
        output_data <= mem[read_pointer];
        output_valid <= 1;
      end 
    end
  end


endmodule

