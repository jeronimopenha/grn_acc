

module grn_mem_core
(
  input clk,
  input rst,
  input start,
  input [5-1:0] initial_state,
  input [5-1:0] final_state,
  input [15-1:0] equations_config,
  input output_read_enable,
  output output_valid,
  output [32-1:0] output_data,
  output output_available
);

  // The grn mem core configuration consists in two buses with the initial state and the final state to be
  // searched and the content of a 1 bit memory for each equation.
  // The mem kernel output data is the FIFO data output that contains all the data found.

  //Fifo wires and regs
  reg fifo_write_enable;
  reg [32-1:0] fifo_input_data;
  wire fifo_full;
  wire fifo_empty;

  // Wires and regs to be used in control and execution of the grn mem
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

  // Here are the GRN eq_wires to be used in the core execution are created
  wire [4-1:0] eq_CtrA;
  wire [2-1:0] eq_GcrA;
  wire [2-1:0] eq_SciP;
  wire [4-1:0] eq_DnaA;
  wire [3-1:0] eq_CcrM;
  assign eq_CtrA = equations_config[3:0];
  assign eq_GcrA = equations_config[5:4];
  assign eq_SciP = equations_config[7:6];
  assign eq_DnaA = equations_config[11:8];
  assign eq_CcrM = equations_config[14:12];

  // State machine to control the grn algorithm execution
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


  // Assigns to define each bit is used on each equation memory
  assign next_state_s1[0] = eq_CtrA[{actual_state_s1[4],actual_state_s1[2],actual_state_s1[1],actual_state_s1[0]}]
  assign next_state_s2[0] = eq_CtrA[{actual_state_s2[4],actual_state_s2[2],actual_state_s2[1],actual_state_s2[0]}]
  assign next_state_s1[1] = eq_GcrA[{actual_state_s1[3],actual_state_s1[0]}]
  assign next_state_s2[1] = eq_GcrA[{actual_state_s2[3],actual_state_s2[0]}]
  assign next_state_s1[2] = eq_SciP[{actual_state_s1[3],actual_state_s1[0]}]
  assign next_state_s2[2] = eq_SciP[{actual_state_s2[3],actual_state_s2[0]}]
  assign next_state_s1[3] = eq_DnaA[{actual_state_s1[4],actual_state_s1[3],actual_state_s1[1],actual_state_s1[0]}]
  assign next_state_s2[3] = eq_DnaA[{actual_state_s2[4],actual_state_s2[3],actual_state_s2[1],actual_state_s2[0]}]
  assign next_state_s1[4] = eq_CcrM[{actual_state_s1[4],actual_state_s1[2],actual_state_s1[0]}]
  assign next_state_s2[4] = eq_CcrM[{actual_state_s2[4],actual_state_s2[2],actual_state_s2[0]}]

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

