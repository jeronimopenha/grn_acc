

module grn_naive_pe
(
  input clk,
  input rst,
  input start,
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
  reg [32-1:0] pe_init_conf;
  reg [32-1:0] pe_end_conf;
  reg [1-1:0] config_counter;
  wire [32-1:0] config_forward;
  //configuration wires and regs - end

  // regs and wires to control the grn core
  reg start_grn;
  wire grn_done;
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
  assign config_forward = pe_end_conf;

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
          pe_end_conf <= config_input;
          pe_init_conf <= config_forward;
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
            if(&{ grn_output_available, ~fifo_out_full }) begin
              grn_output_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_grn;
            end 
          end
          fsm_pe_jo_wr_grn: begin
            if(rd_wr_counter == 2) begin
              fsm_pe_jo <= fsm_pe_jo_look_pe;
            end 
            fifo_out_input_data <= grn_output_data;
            fifo_out_write_enable <= 1;
            rd_wr_counter <= rd_wr_counter + 1;
            fsm_pe_jo <= fsm_pe_jo_rd_grn;
          end
          fsm_pe_jo_look_pe: begin
            fsm_pe_jo <= fsm_pe_jo_look_grn;
            if(pe_bypass_available) begin
              rd_wr_counter <= 0;
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
            end 
          end
          fsm_pe_jo_rd_pe: begin
            if(&{ pe_bypass_available, ~fifo_out_full }) begin
              pe_bypass_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_pe;
            end 
          end
          fsm_pe_jo_wr_pe: begin
            if(rd_wr_counter == 2) begin
              fsm_pe_jo <= fsm_pe_jo_look_grn;
            end 
            fifo_out_input_data <= grn_output_data;
            fifo_out_write_enable <= 1;
            rd_wr_counter <= rd_wr_counter + 1;
            fsm_pe_jo <= fsm_pe_jo_rd_pe;
          end
        endcase
      end 
    end
  end

  // Grn core instantiation
  assign grn_initial_state = pe_init_conf[4:0];
  assign grn_final_state = pe_init_conf[4:0];

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


  fifo_
  #(
    .FIFO_WIDTH(32),
    .FIFO_DEPTH_BITS(4)
  )
  fifo
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_out_write_enable),
    .input_data(fifo_out_input_data),
    .output_read_enable(pe_output_read_enable),
    .output_valid(pe_output_valid),
    .output_data(pe_output_data),
    .empty(fifo_out_empty),
    .full(fifo_out_full)
  );


  initial begin
    config_output_done = 0;
    config_output_valid = 0;
    config_output = 0;
    pe_bypass_read_enable = 0;
    is_configured = 0;
    pe_init_conf = 0;
    pe_end_conf = 0;
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
  reg [96-1:0] data_to_write;
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
            data_to_write <= { 22'b0, exec_state, actual_state_s1, transient_counter, period_counter };
            fsm_naive <= fsm_naive_write;
            write_counter <= 0;
          end
          fsm_naive_write: begin
            if(write_counter == 2) begin
              fsm_naive <= fsm_naive_verify;
            end 
            if(~fifo_full) begin
              write_counter <= write_counter + 1;
              fifo_write_enable <= 1;
              data_to_write <= { 32'b0, data_to_write[95:32] };
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
  fifo
  (
    .clk(clk),
    .rst(rst),
    .write_enable(fifo_write_enable),
    .input_data(fifo_input_data),
    .output_read_enable(output_read_enable),
    .output_valid(output_valid),
    .output_data(output_data),
    .empty(fifo_empty),
    .full(fifo_full)
  );


  // Here are the GRN equations to be used in the core execution are created
  // For S1 pointer
  assign next_state_s1[0] = (actual_state_s1[0] || actual_state_s1[1]) && (!actual_state_s1[4]) && (!actual_state_s1[2]);
  assign next_state_s1[1] = actual_state_s1[3] && !actual_state_s1[0];
  assign next_state_s1[2] = actual_state_s1[0] && !actual_state_s1[3];
  assign next_state_s1[3] = actual_state_s1[0] && actual_state_s1[4] && (!actual_state_s1[1]) && (!actual_state_s1[3]);
  assign next_state_s1[4] = actual_state_s1[0] && (!actual_state_s1[4]) && (!actual_state_s1[2]);

  // For S2 pointer
  assign next_state_s2[0] = (actual_state_s2[0] || actual_state_s2[1]) && (!actual_state_s2[4]) && (!actual_state_s2[2]);
  assign next_state_s2[1] = actual_state_s2[3] && !actual_state_s2[0];
  assign next_state_s2[2] = actual_state_s2[0] && !actual_state_s2[3];
  assign next_state_s2[3] = actual_state_s2[0] && actual_state_s2[4] && (!actual_state_s2[1]) && (!actual_state_s2[3]);
  assign next_state_s2[4] = actual_state_s2[0] && (!actual_state_s2[4]) && (!actual_state_s2[2]);


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
  reg [FIFO_WIDTH-1:0] mem [0:2**FIFO_DEPTH_BITS-1];

  always @(posedge clk) begin
    if(rst) begin
      empty <= 1'b1;
      almostempty <= 1'b1;
      full <= 1'b0;
      almostfull <= 1'b0;
      read_pointer <= 0;
      write_pointer <= 0;
      data_count <= 0;
    end else begin
      case({ write_enable, output_read_enable })
        2'b11: begin
          read_pointer <= read_pointer + 1;
          write_pointer <= write_pointer + 1;
        end
        2'b10: begin
          if(~full) begin
            write_pointer <= write_pointer + 1;
            data_count <= data_count + 1;
            empty <= 1'b0;
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD - 1) begin
              almostempty <= 1'b0;
            end 
            if(data_count == 2 ** FIFO_DEPTH_BITS - 1) begin
              full <= 1'b1;
            end 
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD - 1) begin
              almostfull <= 1'b1;
            end 
          end 
        end
        2'b1: begin
          if(~empty) begin
            read_pointer <= read_pointer + 1;
            data_count <= data_count - 1;
            full <= 1'b0;
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD) begin
              almostfull <= 1'b0;
            end 
            if(data_count == 1) begin
              empty <= 1'b1;
            end 
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD) begin
              almostempty <= 1'b1;
            end 
          end 
        end
      endcase
    end
  end


  always @(posedge clk) begin
    if(rst) begin
      output_valid <= 1'b0;
    end else begin
      output_valid <= 1'b0;
      if(write_enable == 1'b1) begin
        mem[write_pointer] <= input_data;
      end 
      if(output_read_enable == 1'b1) begin
        output_data <= mem[read_pointer];
        output_valid <= 1'b1;
      end 
    end
  end


endmodule



module fifo_ #
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
  reg [FIFO_WIDTH-1:0] mem [0:2**FIFO_DEPTH_BITS-1];

  always @(posedge clk) begin
    if(rst) begin
      empty <= 1'b1;
      almostempty <= 1'b1;
      full <= 1'b0;
      almostfull <= 1'b0;
      read_pointer <= 0;
      write_pointer <= 0;
      data_count <= 0;
    end else begin
      case({ write_enable, output_read_enable })
        2'b11: begin
          read_pointer <= read_pointer + 1;
          write_pointer <= write_pointer + 1;
        end
        2'b10: begin
          if(~full) begin
            write_pointer <= write_pointer + 1;
            data_count <= data_count + 1;
            empty <= 1'b0;
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD - 1) begin
              almostempty <= 1'b0;
            end 
            if(data_count == 2 ** FIFO_DEPTH_BITS - 1) begin
              full <= 1'b1;
            end 
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD - 1) begin
              almostfull <= 1'b1;
            end 
          end 
        end
        2'b1: begin
          if(~empty) begin
            read_pointer <= read_pointer + 1;
            data_count <= data_count - 1;
            full <= 1'b0;
            if(data_count == FIFO_ALMOSTFULL_THRESHOLD) begin
              almostfull <= 1'b0;
            end 
            if(data_count == 1) begin
              empty <= 1'b1;
            end 
            if(data_count == FIFO_ALMOSTEMPTY_THRESHOLD) begin
              almostempty <= 1'b1;
            end 
          end 
        end
      endcase
    end
  end


  always @(posedge clk) begin
    if(rst) begin
      output_valid <= 1'b0;
    end else begin
      output_valid <= 1'b0;
      if(write_enable == 1'b1) begin
        mem[write_pointer] <= input_data;
      end 
      if(output_read_enable == 1'b1) begin
        output_data <= mem[read_pointer];
        output_valid <= 1'b1;
      end 
    end
  end


endmodule

