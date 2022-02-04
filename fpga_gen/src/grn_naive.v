

module grn_core_naive
(
  input clk,
  input rst,
  input start,
  input [5-1:0] initial_state,
  input [5-1:0] final_state,
  input output_read_enable,
  output output_data_valid,
  output output_data,
  output output_data_available
);

  // The grn core naive configuration consists in two buses with the initial state and the final 
  // state to be searched.
  //The naive kernel output data is the FIFO data output that contains all the data found.

  // Wires and regs to be used in control and execution of the grn naive
  reg [5-1:0] actual_state_s1;
  wire [5-1:0] next_state_s1;
  reg [5-1:0] actual_state_s2;
  wire [5-1:0] next_state_s2;
  reg [5-1:0] exec_state;

  // In here the GRN equations to be used in the core execution are created
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

  //State machine to control the grn algorithm execution
  reg [3-1:0] fsm_naive;
  localparam fsm_naive_set = 0;
  localparam fsm_naive_init = 1;
  localparam fsm_naive_transient_finder = 2;
  localparam fsm_naive_period_finder = 3;
  localparam fsm_naive_wait_init_write = 4;
  localparam fsm_naive_verify = 5;
  localparam fsm_naive_done = 6;
  reg flag_pulse;
  reg flag_first_it;
  reg [32-1:0] transient_counter;
  reg [32-1:0] period_counter;

  always @(posedge clk) begin
    if(rst) begin
      fsm_naive <= fsm_naive_set;
    end else begin
      if(start) begin
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
              fsm_naive <= fsm_naive_wait_init_write;
            end else begin
              actual_state_s2 <= next_state_s2;
              period_counter <= period_counter + 1;
            end
          end
          fsm_naive_wait_init_write: begin
          end
          fsm_naive_verify: begin
          end
          fsm_naive_done: begin
          end
        endcase
      end 
    end
  end

  reg next_exec;
  reg [96-1:0] data_to_write;
  reg [1.584962500721156-1:0] write_counter;
  State machine to control the data generation from the core
  reg [3-1:0] fsm_fifo_writer;
  localparam fsm_fifo_writer_wait_data = 0;
  localparam fsm_fifo_writer_write = 1;

  always @(posedge clk) begin
    if(rst) begin
      fsm_fifo_writer <= fsm_fifo_writer_wait_data;
    end else begin
      case(fsm_fifo_writer)
        fsm_fifo_writer_wait_data: begin
          if(fsm_naive == fsm_naive_wait_init_write) begin
            data_to_write <= { 22'b0, exec_state, actual_state_s1, transient_counter, period_counter };
            fsm_fifo_writer <= fsm_fifo_writer_write;
          end 
        end
        fsm_fifo_writer_write: begin
        end
      endcase
    end
  end


  initial begin
    actual_state_s1 = 0;
    actual_state_s2 = 0;
    exec_state = 0;
    fsm_naive = 0;
    flag_pulse = 0;
    flag_first_it = 0;
    transient_counter = 0;
    period_counter = 0;
    next_exec = 0;
    data_to_write = 0;
    write_counter = 0;
    fsm_fifo_writer = 0;
  end


endmodule

