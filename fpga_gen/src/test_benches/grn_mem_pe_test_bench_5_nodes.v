

module test_bench_grn_acc_32
(

);


  //Standar I/O signals - Begin
  reg clk;
  reg rst;
  reg start;
  //Standar I/O signals - End

  // grn mem pe instantiation regs and wires - Begin
  reg grn_aws_done_rd_data;
  reg grn_aws_done_wr_data;
  wire grn_aws_request_read;
  reg grn_aws_read_data_valid;
  reg [32-1:0] grn_aws_read_data;
  reg grn_aws_available_write;
  wire grn_aws_request_write;
  wire [32-1:0] grn_aws_write_data;
  wire grn_aws_done;
  // grn mem pe instantiation regs and wires - end

  //Config Rom configuration regs and wires - Begin
  reg [7-1:0] config_counter;
  wire [32-1:0] config_rom [0:64-1];

  //Config Rom configuration - Begin
  assign config_rom[0] = 32'h0;
  assign config_rom[1] = 32'h0;
  assign config_rom[2] = 32'h1;
  assign config_rom[3] = 32'h1;
  assign config_rom[4] = 32'h2;
  assign config_rom[5] = 32'h2;
  assign config_rom[6] = 32'h3;
  assign config_rom[7] = 32'h3;
  assign config_rom[8] = 32'h4;
  assign config_rom[9] = 32'h4;
  assign config_rom[10] = 32'h5;
  assign config_rom[11] = 32'h5;
  assign config_rom[12] = 32'h6;
  assign config_rom[13] = 32'h6;
  assign config_rom[14] = 32'h7;
  assign config_rom[15] = 32'h7;
  assign config_rom[16] = 32'h8;
  assign config_rom[17] = 32'h8;
  assign config_rom[18] = 32'h9;
  assign config_rom[19] = 32'h9;
  assign config_rom[20] = 32'ha;
  assign config_rom[21] = 32'ha;
  assign config_rom[22] = 32'hb;
  assign config_rom[23] = 32'hb;
  assign config_rom[24] = 32'hc;
  assign config_rom[25] = 32'hc;
  assign config_rom[26] = 32'hd;
  assign config_rom[27] = 32'hd;
  assign config_rom[28] = 32'he;
  assign config_rom[29] = 32'he;
  assign config_rom[30] = 32'hf;
  assign config_rom[31] = 32'hf;
  assign config_rom[32] = 32'h10;
  assign config_rom[33] = 32'h10;
  assign config_rom[34] = 32'h11;
  assign config_rom[35] = 32'h11;
  assign config_rom[36] = 32'h12;
  assign config_rom[37] = 32'h12;
  assign config_rom[38] = 32'h13;
  assign config_rom[39] = 32'h13;
  assign config_rom[40] = 32'h14;
  assign config_rom[41] = 32'h14;
  assign config_rom[42] = 32'h15;
  assign config_rom[43] = 32'h15;
  assign config_rom[44] = 32'h16;
  assign config_rom[45] = 32'h16;
  assign config_rom[46] = 32'h17;
  assign config_rom[47] = 32'h17;
  assign config_rom[48] = 32'h18;
  assign config_rom[49] = 32'h18;
  assign config_rom[50] = 32'h19;
  assign config_rom[51] = 32'h19;
  assign config_rom[52] = 32'h1a;
  assign config_rom[53] = 32'h1a;
  assign config_rom[54] = 32'h1b;
  assign config_rom[55] = 32'h1b;
  assign config_rom[56] = 32'h1c;
  assign config_rom[57] = 32'h1c;
  assign config_rom[58] = 32'h1d;
  assign config_rom[59] = 32'h1d;
  assign config_rom[60] = 32'h1e;
  assign config_rom[61] = 32'h1e;
  assign config_rom[62] = 32'h1f;
  assign config_rom[63] = 32'h1f;
  //Config Rom configuration - End
  //Config Rom configuration regs and wires - End

  //Data Producer regs and wires - Begin
  reg [2-1:0] fsm_produce_data;
  localparam fsm_produce = 0;
  localparam fsm_done = 1;

  //Data Producer regs and wires - End

  //Data Producer - Begin

  always @(posedge clk) begin
    if(rst) begin
      start <= 0;
      config_counter <= 0;
      grn_aws_read_data_valid <= 0;
      grn_aws_done_rd_data <= 0;
      grn_aws_done_wr_data <= 0;
      fsm_produce_data <= fsm_produce;
    end else begin
      start <= 1;
      case(fsm_produce_data)
        fsm_produce: begin
          grn_aws_read_data_valid <= 1;
          grn_aws_read_data <= config_rom[config_counter];
          if(grn_aws_request_read && grn_aws_read_data_valid) begin
            config_counter <= config_counter + 1;
            grn_aws_read_data_valid <= 0;
          end 
          if(config_counter == 64) begin
            grn_aws_read_data_valid <= 0;
            fsm_produce_data <= fsm_done;
          end 
        end
        fsm_done: begin
          grn_aws_done_rd_data <= 1;
        end
      endcase
    end
  end

  //Data Producer - End
  reg [6-1:0] max_data_counter;
  reg [3-1:0] rd_counter;
  reg [128-1:0] data;
  wire [32-1:0] period;
  wire [32-1:0] transient;
  wire [5-1:0] i_state;
  wire [5-1:0] s_state;
  assign period = data[31:0];
  assign transient = data[63:32];
  assign s_state = data[68:64];
  assign i_state = data[100:96];
  reg [2-1:0] fsm_consume_data;
  localparam fsm_consume_data_rd = 0;
  localparam fsm_consume_data_show = 1;
  localparam fsm_consume_data_done = 2;

  always @(posedge clk) begin
    if(rst) begin
      rd_counter <= 0;
      max_data_counter <= 0;
      grn_aws_available_write <= 0;
      grn_aws_done_wr_data <= 0;
      fsm_consume_data <= fsm_consume_data_rd;
    end else begin
      case(fsm_consume_data)
        fsm_consume_data_rd: begin
          grn_aws_available_write <= 1;
          if(grn_aws_request_write) begin
            rd_counter <= rd_counter + 1;
            data <= { grn_aws_write_data, data[127:32] };
            if(rd_counter == 3) begin
              grn_aws_available_write <= 0;
              rd_counter <= 0;
              fsm_consume_data <= fsm_consume_data_show;
            end 
          end 
        end
        fsm_consume_data_show: begin
          if(max_data_counter == 31) begin
            fsm_consume_data <= fsm_consume_data_done;
          end else begin
            fsm_consume_data <= fsm_consume_data_rd;
          end
          $display("i_s: %h s_s: %h t: %h p: %h", i_state, s_state, transient, period);
          max_data_counter <= max_data_counter + 1;
        end
        fsm_consume_data_done: begin
          grn_aws_done_wr_data <= 1;
        end
      endcase
    end
  end


  grn_aws_32
  grn_aws_32
  (
    .clk(clk),
    .rst(rst),
    .start(start),
    .grn_aws_done_rd_data(grn_aws_done_rd_data),
    .grn_aws_done_wr_data(grn_aws_done_wr_data),
    .grn_aws_request_read(grn_aws_request_read),
    .grn_aws_read_data_valid(grn_aws_read_data_valid),
    .grn_aws_read_data(grn_aws_read_data),
    .grn_aws_available_write(grn_aws_available_write),
    .grn_aws_request_write(grn_aws_request_write),
    .grn_aws_write_data(grn_aws_write_data),
    .grn_aws_done(grn_aws_done)
  );


  initial begin
    clk = 0;
    rst = 1;
    start = 0;
    grn_aws_done_rd_data = 0;
    grn_aws_done_wr_data = 0;
    grn_aws_read_data_valid = 0;
    grn_aws_read_data = 0;
    grn_aws_available_write = 0;
    config_counter = 0;
    fsm_produce_data = 0;
    max_data_counter = 0;
    rd_counter = 0;
    data = 0;
    fsm_consume_data = 0;
  end


  initial begin
    $dumpfile("uut.vcd");
    $dumpvars(0);
  end


  initial begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 0;
    #1000000;
    $finish;
  end

  always #5clk=~clk;

  always @(posedge clk) begin
    if(grn_aws_done) begin
      $display("ACC DONE!");
      $finish;
    end 
  end


  //Simulation sector - End

endmodule



module grn_aws_32
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
  wire [32-1:0] grn_pe_config_output_done;
  wire [32-1:0] grn_pe_config_output_valid;
  wire [32-1:0] grn_pe_config_output [0:32-1];
  wire [32-1:0] grn_pe_output_read_enable;
  wire [32-1:0] grn_pe_output_valid;
  wire [32-1:0] grn_pe_output_data [0:32-1];
  wire [32-1:0] grn_pe_output_available;
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
  assign grn_pe_output_valid[31] = 0;
  assign grn_pe_output_data[31] = 0;
  assign grn_pe_output_available[31] = 0;

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


  grn_naive_pe
  grn_naive_pe_1
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[0]),
    .config_input_valid(grn_pe_config_output_valid[0]),
    .config_input(grn_pe_config_output[0]),
    .config_output_done(grn_pe_config_output_done[1]),
    .config_output_valid(grn_pe_config_output_valid[1]),
    .config_output(grn_pe_config_output[1]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[1]),
    .pe_bypass_valid(grn_pe_output_valid[1]),
    .pe_bypass_data(grn_pe_output_data[1]),
    .pe_bypass_available(grn_pe_output_available[1]),
    .pe_output_read_enable(grn_pe_output_read_enable[0]),
    .pe_output_valid(grn_pe_output_valid[0]),
    .pe_output_data(grn_pe_output_data[0]),
    .pe_output_available(grn_pe_output_available[0])
  );


  grn_naive_pe
  grn_naive_pe_2
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[1]),
    .config_input_valid(grn_pe_config_output_valid[1]),
    .config_input(grn_pe_config_output[1]),
    .config_output_done(grn_pe_config_output_done[2]),
    .config_output_valid(grn_pe_config_output_valid[2]),
    .config_output(grn_pe_config_output[2]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[2]),
    .pe_bypass_valid(grn_pe_output_valid[2]),
    .pe_bypass_data(grn_pe_output_data[2]),
    .pe_bypass_available(grn_pe_output_available[2]),
    .pe_output_read_enable(grn_pe_output_read_enable[1]),
    .pe_output_valid(grn_pe_output_valid[1]),
    .pe_output_data(grn_pe_output_data[1]),
    .pe_output_available(grn_pe_output_available[1])
  );


  grn_naive_pe
  grn_naive_pe_3
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[2]),
    .config_input_valid(grn_pe_config_output_valid[2]),
    .config_input(grn_pe_config_output[2]),
    .config_output_done(grn_pe_config_output_done[3]),
    .config_output_valid(grn_pe_config_output_valid[3]),
    .config_output(grn_pe_config_output[3]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[3]),
    .pe_bypass_valid(grn_pe_output_valid[3]),
    .pe_bypass_data(grn_pe_output_data[3]),
    .pe_bypass_available(grn_pe_output_available[3]),
    .pe_output_read_enable(grn_pe_output_read_enable[2]),
    .pe_output_valid(grn_pe_output_valid[2]),
    .pe_output_data(grn_pe_output_data[2]),
    .pe_output_available(grn_pe_output_available[2])
  );


  grn_naive_pe
  grn_naive_pe_4
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[3]),
    .config_input_valid(grn_pe_config_output_valid[3]),
    .config_input(grn_pe_config_output[3]),
    .config_output_done(grn_pe_config_output_done[4]),
    .config_output_valid(grn_pe_config_output_valid[4]),
    .config_output(grn_pe_config_output[4]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[4]),
    .pe_bypass_valid(grn_pe_output_valid[4]),
    .pe_bypass_data(grn_pe_output_data[4]),
    .pe_bypass_available(grn_pe_output_available[4]),
    .pe_output_read_enable(grn_pe_output_read_enable[3]),
    .pe_output_valid(grn_pe_output_valid[3]),
    .pe_output_data(grn_pe_output_data[3]),
    .pe_output_available(grn_pe_output_available[3])
  );


  grn_naive_pe
  grn_naive_pe_5
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[4]),
    .config_input_valid(grn_pe_config_output_valid[4]),
    .config_input(grn_pe_config_output[4]),
    .config_output_done(grn_pe_config_output_done[5]),
    .config_output_valid(grn_pe_config_output_valid[5]),
    .config_output(grn_pe_config_output[5]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[5]),
    .pe_bypass_valid(grn_pe_output_valid[5]),
    .pe_bypass_data(grn_pe_output_data[5]),
    .pe_bypass_available(grn_pe_output_available[5]),
    .pe_output_read_enable(grn_pe_output_read_enable[4]),
    .pe_output_valid(grn_pe_output_valid[4]),
    .pe_output_data(grn_pe_output_data[4]),
    .pe_output_available(grn_pe_output_available[4])
  );


  grn_naive_pe
  grn_naive_pe_6
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[5]),
    .config_input_valid(grn_pe_config_output_valid[5]),
    .config_input(grn_pe_config_output[5]),
    .config_output_done(grn_pe_config_output_done[6]),
    .config_output_valid(grn_pe_config_output_valid[6]),
    .config_output(grn_pe_config_output[6]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[6]),
    .pe_bypass_valid(grn_pe_output_valid[6]),
    .pe_bypass_data(grn_pe_output_data[6]),
    .pe_bypass_available(grn_pe_output_available[6]),
    .pe_output_read_enable(grn_pe_output_read_enable[5]),
    .pe_output_valid(grn_pe_output_valid[5]),
    .pe_output_data(grn_pe_output_data[5]),
    .pe_output_available(grn_pe_output_available[5])
  );


  grn_naive_pe
  grn_naive_pe_7
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[6]),
    .config_input_valid(grn_pe_config_output_valid[6]),
    .config_input(grn_pe_config_output[6]),
    .config_output_done(grn_pe_config_output_done[7]),
    .config_output_valid(grn_pe_config_output_valid[7]),
    .config_output(grn_pe_config_output[7]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[7]),
    .pe_bypass_valid(grn_pe_output_valid[7]),
    .pe_bypass_data(grn_pe_output_data[7]),
    .pe_bypass_available(grn_pe_output_available[7]),
    .pe_output_read_enable(grn_pe_output_read_enable[6]),
    .pe_output_valid(grn_pe_output_valid[6]),
    .pe_output_data(grn_pe_output_data[6]),
    .pe_output_available(grn_pe_output_available[6])
  );


  grn_naive_pe
  grn_naive_pe_8
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[7]),
    .config_input_valid(grn_pe_config_output_valid[7]),
    .config_input(grn_pe_config_output[7]),
    .config_output_done(grn_pe_config_output_done[8]),
    .config_output_valid(grn_pe_config_output_valid[8]),
    .config_output(grn_pe_config_output[8]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[8]),
    .pe_bypass_valid(grn_pe_output_valid[8]),
    .pe_bypass_data(grn_pe_output_data[8]),
    .pe_bypass_available(grn_pe_output_available[8]),
    .pe_output_read_enable(grn_pe_output_read_enable[7]),
    .pe_output_valid(grn_pe_output_valid[7]),
    .pe_output_data(grn_pe_output_data[7]),
    .pe_output_available(grn_pe_output_available[7])
  );


  grn_naive_pe
  grn_naive_pe_9
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[8]),
    .config_input_valid(grn_pe_config_output_valid[8]),
    .config_input(grn_pe_config_output[8]),
    .config_output_done(grn_pe_config_output_done[9]),
    .config_output_valid(grn_pe_config_output_valid[9]),
    .config_output(grn_pe_config_output[9]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[9]),
    .pe_bypass_valid(grn_pe_output_valid[9]),
    .pe_bypass_data(grn_pe_output_data[9]),
    .pe_bypass_available(grn_pe_output_available[9]),
    .pe_output_read_enable(grn_pe_output_read_enable[8]),
    .pe_output_valid(grn_pe_output_valid[8]),
    .pe_output_data(grn_pe_output_data[8]),
    .pe_output_available(grn_pe_output_available[8])
  );


  grn_naive_pe
  grn_naive_pe_10
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[9]),
    .config_input_valid(grn_pe_config_output_valid[9]),
    .config_input(grn_pe_config_output[9]),
    .config_output_done(grn_pe_config_output_done[10]),
    .config_output_valid(grn_pe_config_output_valid[10]),
    .config_output(grn_pe_config_output[10]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[10]),
    .pe_bypass_valid(grn_pe_output_valid[10]),
    .pe_bypass_data(grn_pe_output_data[10]),
    .pe_bypass_available(grn_pe_output_available[10]),
    .pe_output_read_enable(grn_pe_output_read_enable[9]),
    .pe_output_valid(grn_pe_output_valid[9]),
    .pe_output_data(grn_pe_output_data[9]),
    .pe_output_available(grn_pe_output_available[9])
  );


  grn_naive_pe
  grn_naive_pe_11
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[10]),
    .config_input_valid(grn_pe_config_output_valid[10]),
    .config_input(grn_pe_config_output[10]),
    .config_output_done(grn_pe_config_output_done[11]),
    .config_output_valid(grn_pe_config_output_valid[11]),
    .config_output(grn_pe_config_output[11]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[11]),
    .pe_bypass_valid(grn_pe_output_valid[11]),
    .pe_bypass_data(grn_pe_output_data[11]),
    .pe_bypass_available(grn_pe_output_available[11]),
    .pe_output_read_enable(grn_pe_output_read_enable[10]),
    .pe_output_valid(grn_pe_output_valid[10]),
    .pe_output_data(grn_pe_output_data[10]),
    .pe_output_available(grn_pe_output_available[10])
  );


  grn_naive_pe
  grn_naive_pe_12
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[11]),
    .config_input_valid(grn_pe_config_output_valid[11]),
    .config_input(grn_pe_config_output[11]),
    .config_output_done(grn_pe_config_output_done[12]),
    .config_output_valid(grn_pe_config_output_valid[12]),
    .config_output(grn_pe_config_output[12]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[12]),
    .pe_bypass_valid(grn_pe_output_valid[12]),
    .pe_bypass_data(grn_pe_output_data[12]),
    .pe_bypass_available(grn_pe_output_available[12]),
    .pe_output_read_enable(grn_pe_output_read_enable[11]),
    .pe_output_valid(grn_pe_output_valid[11]),
    .pe_output_data(grn_pe_output_data[11]),
    .pe_output_available(grn_pe_output_available[11])
  );


  grn_naive_pe
  grn_naive_pe_13
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[12]),
    .config_input_valid(grn_pe_config_output_valid[12]),
    .config_input(grn_pe_config_output[12]),
    .config_output_done(grn_pe_config_output_done[13]),
    .config_output_valid(grn_pe_config_output_valid[13]),
    .config_output(grn_pe_config_output[13]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[13]),
    .pe_bypass_valid(grn_pe_output_valid[13]),
    .pe_bypass_data(grn_pe_output_data[13]),
    .pe_bypass_available(grn_pe_output_available[13]),
    .pe_output_read_enable(grn_pe_output_read_enable[12]),
    .pe_output_valid(grn_pe_output_valid[12]),
    .pe_output_data(grn_pe_output_data[12]),
    .pe_output_available(grn_pe_output_available[12])
  );


  grn_naive_pe
  grn_naive_pe_14
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[13]),
    .config_input_valid(grn_pe_config_output_valid[13]),
    .config_input(grn_pe_config_output[13]),
    .config_output_done(grn_pe_config_output_done[14]),
    .config_output_valid(grn_pe_config_output_valid[14]),
    .config_output(grn_pe_config_output[14]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[14]),
    .pe_bypass_valid(grn_pe_output_valid[14]),
    .pe_bypass_data(grn_pe_output_data[14]),
    .pe_bypass_available(grn_pe_output_available[14]),
    .pe_output_read_enable(grn_pe_output_read_enable[13]),
    .pe_output_valid(grn_pe_output_valid[13]),
    .pe_output_data(grn_pe_output_data[13]),
    .pe_output_available(grn_pe_output_available[13])
  );


  grn_naive_pe
  grn_naive_pe_15
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[14]),
    .config_input_valid(grn_pe_config_output_valid[14]),
    .config_input(grn_pe_config_output[14]),
    .config_output_done(grn_pe_config_output_done[15]),
    .config_output_valid(grn_pe_config_output_valid[15]),
    .config_output(grn_pe_config_output[15]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[15]),
    .pe_bypass_valid(grn_pe_output_valid[15]),
    .pe_bypass_data(grn_pe_output_data[15]),
    .pe_bypass_available(grn_pe_output_available[15]),
    .pe_output_read_enable(grn_pe_output_read_enable[14]),
    .pe_output_valid(grn_pe_output_valid[14]),
    .pe_output_data(grn_pe_output_data[14]),
    .pe_output_available(grn_pe_output_available[14])
  );


  grn_naive_pe
  grn_naive_pe_16
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[15]),
    .config_input_valid(grn_pe_config_output_valid[15]),
    .config_input(grn_pe_config_output[15]),
    .config_output_done(grn_pe_config_output_done[16]),
    .config_output_valid(grn_pe_config_output_valid[16]),
    .config_output(grn_pe_config_output[16]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[16]),
    .pe_bypass_valid(grn_pe_output_valid[16]),
    .pe_bypass_data(grn_pe_output_data[16]),
    .pe_bypass_available(grn_pe_output_available[16]),
    .pe_output_read_enable(grn_pe_output_read_enable[15]),
    .pe_output_valid(grn_pe_output_valid[15]),
    .pe_output_data(grn_pe_output_data[15]),
    .pe_output_available(grn_pe_output_available[15])
  );


  grn_naive_pe
  grn_naive_pe_17
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[16]),
    .config_input_valid(grn_pe_config_output_valid[16]),
    .config_input(grn_pe_config_output[16]),
    .config_output_done(grn_pe_config_output_done[17]),
    .config_output_valid(grn_pe_config_output_valid[17]),
    .config_output(grn_pe_config_output[17]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[17]),
    .pe_bypass_valid(grn_pe_output_valid[17]),
    .pe_bypass_data(grn_pe_output_data[17]),
    .pe_bypass_available(grn_pe_output_available[17]),
    .pe_output_read_enable(grn_pe_output_read_enable[16]),
    .pe_output_valid(grn_pe_output_valid[16]),
    .pe_output_data(grn_pe_output_data[16]),
    .pe_output_available(grn_pe_output_available[16])
  );


  grn_naive_pe
  grn_naive_pe_18
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[17]),
    .config_input_valid(grn_pe_config_output_valid[17]),
    .config_input(grn_pe_config_output[17]),
    .config_output_done(grn_pe_config_output_done[18]),
    .config_output_valid(grn_pe_config_output_valid[18]),
    .config_output(grn_pe_config_output[18]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[18]),
    .pe_bypass_valid(grn_pe_output_valid[18]),
    .pe_bypass_data(grn_pe_output_data[18]),
    .pe_bypass_available(grn_pe_output_available[18]),
    .pe_output_read_enable(grn_pe_output_read_enable[17]),
    .pe_output_valid(grn_pe_output_valid[17]),
    .pe_output_data(grn_pe_output_data[17]),
    .pe_output_available(grn_pe_output_available[17])
  );


  grn_naive_pe
  grn_naive_pe_19
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[18]),
    .config_input_valid(grn_pe_config_output_valid[18]),
    .config_input(grn_pe_config_output[18]),
    .config_output_done(grn_pe_config_output_done[19]),
    .config_output_valid(grn_pe_config_output_valid[19]),
    .config_output(grn_pe_config_output[19]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[19]),
    .pe_bypass_valid(grn_pe_output_valid[19]),
    .pe_bypass_data(grn_pe_output_data[19]),
    .pe_bypass_available(grn_pe_output_available[19]),
    .pe_output_read_enable(grn_pe_output_read_enable[18]),
    .pe_output_valid(grn_pe_output_valid[18]),
    .pe_output_data(grn_pe_output_data[18]),
    .pe_output_available(grn_pe_output_available[18])
  );


  grn_naive_pe
  grn_naive_pe_20
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[19]),
    .config_input_valid(grn_pe_config_output_valid[19]),
    .config_input(grn_pe_config_output[19]),
    .config_output_done(grn_pe_config_output_done[20]),
    .config_output_valid(grn_pe_config_output_valid[20]),
    .config_output(grn_pe_config_output[20]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[20]),
    .pe_bypass_valid(grn_pe_output_valid[20]),
    .pe_bypass_data(grn_pe_output_data[20]),
    .pe_bypass_available(grn_pe_output_available[20]),
    .pe_output_read_enable(grn_pe_output_read_enable[19]),
    .pe_output_valid(grn_pe_output_valid[19]),
    .pe_output_data(grn_pe_output_data[19]),
    .pe_output_available(grn_pe_output_available[19])
  );


  grn_naive_pe
  grn_naive_pe_21
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[20]),
    .config_input_valid(grn_pe_config_output_valid[20]),
    .config_input(grn_pe_config_output[20]),
    .config_output_done(grn_pe_config_output_done[21]),
    .config_output_valid(grn_pe_config_output_valid[21]),
    .config_output(grn_pe_config_output[21]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[21]),
    .pe_bypass_valid(grn_pe_output_valid[21]),
    .pe_bypass_data(grn_pe_output_data[21]),
    .pe_bypass_available(grn_pe_output_available[21]),
    .pe_output_read_enable(grn_pe_output_read_enable[20]),
    .pe_output_valid(grn_pe_output_valid[20]),
    .pe_output_data(grn_pe_output_data[20]),
    .pe_output_available(grn_pe_output_available[20])
  );


  grn_naive_pe
  grn_naive_pe_22
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[21]),
    .config_input_valid(grn_pe_config_output_valid[21]),
    .config_input(grn_pe_config_output[21]),
    .config_output_done(grn_pe_config_output_done[22]),
    .config_output_valid(grn_pe_config_output_valid[22]),
    .config_output(grn_pe_config_output[22]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[22]),
    .pe_bypass_valid(grn_pe_output_valid[22]),
    .pe_bypass_data(grn_pe_output_data[22]),
    .pe_bypass_available(grn_pe_output_available[22]),
    .pe_output_read_enable(grn_pe_output_read_enable[21]),
    .pe_output_valid(grn_pe_output_valid[21]),
    .pe_output_data(grn_pe_output_data[21]),
    .pe_output_available(grn_pe_output_available[21])
  );


  grn_naive_pe
  grn_naive_pe_23
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[22]),
    .config_input_valid(grn_pe_config_output_valid[22]),
    .config_input(grn_pe_config_output[22]),
    .config_output_done(grn_pe_config_output_done[23]),
    .config_output_valid(grn_pe_config_output_valid[23]),
    .config_output(grn_pe_config_output[23]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[23]),
    .pe_bypass_valid(grn_pe_output_valid[23]),
    .pe_bypass_data(grn_pe_output_data[23]),
    .pe_bypass_available(grn_pe_output_available[23]),
    .pe_output_read_enable(grn_pe_output_read_enable[22]),
    .pe_output_valid(grn_pe_output_valid[22]),
    .pe_output_data(grn_pe_output_data[22]),
    .pe_output_available(grn_pe_output_available[22])
  );


  grn_naive_pe
  grn_naive_pe_24
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[23]),
    .config_input_valid(grn_pe_config_output_valid[23]),
    .config_input(grn_pe_config_output[23]),
    .config_output_done(grn_pe_config_output_done[24]),
    .config_output_valid(grn_pe_config_output_valid[24]),
    .config_output(grn_pe_config_output[24]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[24]),
    .pe_bypass_valid(grn_pe_output_valid[24]),
    .pe_bypass_data(grn_pe_output_data[24]),
    .pe_bypass_available(grn_pe_output_available[24]),
    .pe_output_read_enable(grn_pe_output_read_enable[23]),
    .pe_output_valid(grn_pe_output_valid[23]),
    .pe_output_data(grn_pe_output_data[23]),
    .pe_output_available(grn_pe_output_available[23])
  );


  grn_naive_pe
  grn_naive_pe_25
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[24]),
    .config_input_valid(grn_pe_config_output_valid[24]),
    .config_input(grn_pe_config_output[24]),
    .config_output_done(grn_pe_config_output_done[25]),
    .config_output_valid(grn_pe_config_output_valid[25]),
    .config_output(grn_pe_config_output[25]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[25]),
    .pe_bypass_valid(grn_pe_output_valid[25]),
    .pe_bypass_data(grn_pe_output_data[25]),
    .pe_bypass_available(grn_pe_output_available[25]),
    .pe_output_read_enable(grn_pe_output_read_enable[24]),
    .pe_output_valid(grn_pe_output_valid[24]),
    .pe_output_data(grn_pe_output_data[24]),
    .pe_output_available(grn_pe_output_available[24])
  );


  grn_naive_pe
  grn_naive_pe_26
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[25]),
    .config_input_valid(grn_pe_config_output_valid[25]),
    .config_input(grn_pe_config_output[25]),
    .config_output_done(grn_pe_config_output_done[26]),
    .config_output_valid(grn_pe_config_output_valid[26]),
    .config_output(grn_pe_config_output[26]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[26]),
    .pe_bypass_valid(grn_pe_output_valid[26]),
    .pe_bypass_data(grn_pe_output_data[26]),
    .pe_bypass_available(grn_pe_output_available[26]),
    .pe_output_read_enable(grn_pe_output_read_enable[25]),
    .pe_output_valid(grn_pe_output_valid[25]),
    .pe_output_data(grn_pe_output_data[25]),
    .pe_output_available(grn_pe_output_available[25])
  );


  grn_naive_pe
  grn_naive_pe_27
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[26]),
    .config_input_valid(grn_pe_config_output_valid[26]),
    .config_input(grn_pe_config_output[26]),
    .config_output_done(grn_pe_config_output_done[27]),
    .config_output_valid(grn_pe_config_output_valid[27]),
    .config_output(grn_pe_config_output[27]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[27]),
    .pe_bypass_valid(grn_pe_output_valid[27]),
    .pe_bypass_data(grn_pe_output_data[27]),
    .pe_bypass_available(grn_pe_output_available[27]),
    .pe_output_read_enable(grn_pe_output_read_enable[26]),
    .pe_output_valid(grn_pe_output_valid[26]),
    .pe_output_data(grn_pe_output_data[26]),
    .pe_output_available(grn_pe_output_available[26])
  );


  grn_naive_pe
  grn_naive_pe_28
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[27]),
    .config_input_valid(grn_pe_config_output_valid[27]),
    .config_input(grn_pe_config_output[27]),
    .config_output_done(grn_pe_config_output_done[28]),
    .config_output_valid(grn_pe_config_output_valid[28]),
    .config_output(grn_pe_config_output[28]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[28]),
    .pe_bypass_valid(grn_pe_output_valid[28]),
    .pe_bypass_data(grn_pe_output_data[28]),
    .pe_bypass_available(grn_pe_output_available[28]),
    .pe_output_read_enable(grn_pe_output_read_enable[27]),
    .pe_output_valid(grn_pe_output_valid[27]),
    .pe_output_data(grn_pe_output_data[27]),
    .pe_output_available(grn_pe_output_available[27])
  );


  grn_naive_pe
  grn_naive_pe_29
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[28]),
    .config_input_valid(grn_pe_config_output_valid[28]),
    .config_input(grn_pe_config_output[28]),
    .config_output_done(grn_pe_config_output_done[29]),
    .config_output_valid(grn_pe_config_output_valid[29]),
    .config_output(grn_pe_config_output[29]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[29]),
    .pe_bypass_valid(grn_pe_output_valid[29]),
    .pe_bypass_data(grn_pe_output_data[29]),
    .pe_bypass_available(grn_pe_output_available[29]),
    .pe_output_read_enable(grn_pe_output_read_enable[28]),
    .pe_output_valid(grn_pe_output_valid[28]),
    .pe_output_data(grn_pe_output_data[28]),
    .pe_output_available(grn_pe_output_available[28])
  );


  grn_naive_pe
  grn_naive_pe_30
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[29]),
    .config_input_valid(grn_pe_config_output_valid[29]),
    .config_input(grn_pe_config_output[29]),
    .config_output_done(grn_pe_config_output_done[30]),
    .config_output_valid(grn_pe_config_output_valid[30]),
    .config_output(grn_pe_config_output[30]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[30]),
    .pe_bypass_valid(grn_pe_output_valid[30]),
    .pe_bypass_data(grn_pe_output_data[30]),
    .pe_bypass_available(grn_pe_output_available[30]),
    .pe_output_read_enable(grn_pe_output_read_enable[29]),
    .pe_output_valid(grn_pe_output_valid[29]),
    .pe_output_data(grn_pe_output_data[29]),
    .pe_output_available(grn_pe_output_available[29])
  );


  grn_naive_pe
  grn_naive_pe_31
  (
    .clk(clk),
    .rst(rst),
    .config_input_done(grn_pe_config_output_done[30]),
    .config_input_valid(grn_pe_config_output_valid[30]),
    .config_input(grn_pe_config_output[30]),
    .config_output_done(grn_pe_config_output_done[31]),
    .config_output_valid(grn_pe_config_output_valid[31]),
    .config_output(grn_pe_config_output[31]),
    .pe_bypass_read_enable(grn_pe_output_read_enable[31]),
    .pe_bypass_valid(grn_pe_output_valid[31]),
    .pe_bypass_data(grn_pe_output_data[31]),
    .pe_bypass_available(grn_pe_output_available[31]),
    .pe_output_read_enable(grn_pe_output_read_enable[30]),
    .pe_output_valid(grn_pe_output_valid[30]),
    .pe_output_data(grn_pe_output_data[30]),
    .pe_output_available(grn_pe_output_available[30])
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
    .FIFO_DEPTH_BITS(4)
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
    .FIFO_DEPTH_BITS(4)
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

