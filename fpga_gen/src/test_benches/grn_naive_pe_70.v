

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
  wire [96-1:0] pe_init_conf;
  wire [96-1:0] pe_end_conf;
  reg [192-1:0] pe_data_conf;
  assign pe_init_conf = pe_data_conf[95:0];
  assign pe_end_conf = pe_data_conf[191:96];
  reg [3-1:0] config_counter;
  //configuration wires and regs - end

  // regs and wires to control the grn core
  reg start_grn;
  wire [70-1:0] grn_initial_state;
  wire [70-1:0] grn_final_state;
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
  reg [3-1:0] rd_wr_counter;

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
        if(config_counter == 5) begin
          is_configured <= 1;
        end 
        if(~is_configured) begin
          pe_data_conf <= { config_input, pe_data_conf[191:32] };
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
            if(grn_output_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_grn;
              if(rd_wr_counter == 6) begin
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
            if(&{ pe_bypass_available, ~fifo_out_full }) begin
              pe_bypass_read_enable <= 1;
              fsm_pe_jo <= fsm_pe_jo_wr_pe;
            end 
          end
          fsm_pe_jo_wr_pe: begin
            if(pe_bypass_valid) begin
              fsm_pe_jo <= fsm_pe_jo_rd_pe;
              if(rd_wr_counter == 6) begin
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
  assign grn_initial_state = pe_init_conf[69:0];
  assign grn_final_state = pe_end_conf[69:0];

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
  input [70-1:0] initial_state,
  input [70-1:0] final_state,
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
  reg [70-1:0] actual_state_s1;
  wire [70-1:0] next_state_s1;
  reg [70-1:0] actual_state_s2;
  wire [70-1:0] next_state_s2;
  reg [70-1:0] exec_state;
  reg flag_pulse;
  reg flag_first_it;
  reg [32-1:0] transient_counter;
  reg [32-1:0] period_counter;
  reg [224-1:0] data_to_write;
  reg [3-1:0] write_counter;

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
            data_to_write <= { 20'b0, exec_state, actual_state_s1, transient_counter, period_counter };
            fsm_naive <= fsm_naive_write;
            write_counter <= 0;
          end
          fsm_naive_write: begin
            if(write_counter == 6) begin
              fsm_naive <= fsm_naive_verify;
            end 
            if(~fifo_full) begin
              write_counter <= write_counter + 1;
              fifo_write_enable <= 1;
              data_to_write <= { 32'b0, data_to_write[223:32] };
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
  assign next_state_s1[0] = actual_state_s1[41];
  assign next_state_s1[1] = actual_state_s1[41]&&  !actual_state_s1[33];
  assign next_state_s1[2] = actual_state_s1[36]&&  !  (actual_state_s1[37]||actual_state_s1[7])  ;
  assign next_state_s1[3] =   (  (actual_state_s1[51]||actual_state_s1[34])  &&actual_state_s1[37])  &&  !actual_state_s1[2];
  assign next_state_s1[4] = actual_state_s1[4];
  assign next_state_s1[5] =   !  (actual_state_s1[21]&&actual_state_s1[4])  ;
  assign next_state_s1[6] =   (actual_state_s1[49]||actual_state_s1[32])  &&  !  (actual_state_s1[34]||actual_state_s1[37])  ;
  assign next_state_s1[7] =   (actual_state_s1[8]||actual_state_s1[9])  &&  !actual_state_s1[22];
  assign next_state_s1[8] = actual_state_s1[18]&&  !  (actual_state_s1[11]||actual_state_s1[33])  ;
  assign next_state_s1[9] = actual_state_s1[14]&&  !  (actual_state_s1[22]||actual_state_s1[33])  ;
  assign next_state_s1[10] = actual_state_s1[47]&&  !actual_state_s1[48];
  assign next_state_s1[11] = actual_state_s1[32];
  assign next_state_s1[12] = actual_state_s1[43]&&actual_state_s1[53];
  assign next_state_s1[13] =   (actual_state_s1[5]||actual_state_s1[49]||actual_state_s1[27])  &&  !actual_state_s1[21];
  assign next_state_s1[14] = actual_state_s1[31];
  assign next_state_s1[15] = actual_state_s1[35];
  assign next_state_s1[16] = actual_state_s1[29];
  assign next_state_s1[17] = actual_state_s1[65];
  assign next_state_s1[18] = actual_state_s1[53]||actual_state_s1[17];
  assign next_state_s1[19] = actual_state_s1[16];
  assign next_state_s1[20] = actual_state_s1[60];
  assign next_state_s1[21] =   !  (actual_state_s1[15]||actual_state_s1[2])  ;
  assign next_state_s1[22] =   (actual_state_s1[32]||actual_state_s1[49])  &&  !actual_state_s1[44];
  assign next_state_s1[23] =   !actual_state_s1[24];
  assign next_state_s1[24] =   (actual_state_s1[2]||  (actual_state_s1[43]&&actual_state_s1[53])  )  ;
  assign next_state_s1[25] = actual_state_s1[20]&&  !actual_state_s1[50];
  assign next_state_s1[26] = actual_state_s1[1]||actual_state_s1[30];
  assign next_state_s1[27] =   (  (actual_state_s1[5]||actual_state_s1[16])  &&actual_state_s1[26])  &&  !actual_state_s1[21];
  assign next_state_s1[28] =   (actual_state_s1[34]&&actual_state_s1[2])  &&  !  (actual_state_s1[21]||actual_state_s1[0])  ;
  assign next_state_s1[29] = actual_state_s1[39]||actual_state_s1[41];
  assign next_state_s1[30] = actual_state_s1[10]||actual_state_s1[52]||actual_state_s1[53];
  assign next_state_s1[31] =   (actual_state_s1[3]||actual_state_s1[51]||actual_state_s1[10])  &&  !actual_state_s1[6];
  assign next_state_s1[32] =   !actual_state_s1[23];
  assign next_state_s1[33] =   (actual_state_s1[34]||actual_state_s1[45])  &&  !  (actual_state_s1[21]||actual_state_s1[7])  ;
  assign next_state_s1[34] =   (actual_state_s1[38]||actual_state_s1[26]||actual_state_s1[0])  &&  !actual_state_s1[28];
  assign next_state_s1[35] = actual_state_s1[12];
  assign next_state_s1[36] =   (actual_state_s1[15]||actual_state_s1[40])  &&  !actual_state_s1[38];
  assign next_state_s1[37] = actual_state_s1[10]&&  !actual_state_s1[2];
  assign next_state_s1[38] = actual_state_s1[34]&&  !  (actual_state_s1[32]||actual_state_s1[27])  ;
  assign next_state_s1[39] = actual_state_s1[10]||actual_state_s1[40];
  assign next_state_s1[40] = actual_state_s1[15]||actual_state_s1[20];
  assign next_state_s1[41] = actual_state_s1[53]&&  !actual_state_s1[42];
  assign next_state_s1[42] = actual_state_s1[32]||actual_state_s1[49];
  assign next_state_s1[43] = actual_state_s1[48];
  assign next_state_s1[44] = actual_state_s1[31];
  assign next_state_s1[45] = actual_state_s1[52]&&  !actual_state_s1[27];
  assign next_state_s1[46] = actual_state_s1[45]||actual_state_s1[32];
  assign next_state_s1[47] = actual_state_s1[34]||actual_state_s1[18];
  assign next_state_s1[48] = actual_state_s1[16]||actual_state_s1[53];
  assign next_state_s1[49] = actual_state_s1[25];
  assign next_state_s1[50] = actual_state_s1[49];
  assign next_state_s1[51] = actual_state_s1[8]&&  !actual_state_s1[6];
  assign next_state_s1[52] = actual_state_s1[58]&&  !actual_state_s1[46];
  assign next_state_s1[53] = actual_state_s1[55];
  assign next_state_s1[54] =   (actual_state_s1[63]||actual_state_s1[66])  &&  !actual_state_s1[60];
  assign next_state_s1[55] = actual_state_s1[59];
  assign next_state_s1[56] = actual_state_s1[61]&&  !  (actual_state_s1[64]||actual_state_s1[58])  ;
  assign next_state_s1[57] =   (actual_state_s1[62]||actual_state_s1[64])  &&  !  (actual_state_s1[63]||actual_state_s1[58]||actual_state_s1[61])  ;
  assign next_state_s1[58] = actual_state_s1[54];
  assign next_state_s1[59] =   (actual_state_s1[64]||actual_state_s1[67])  &&  !actual_state_s1[63];
  assign next_state_s1[60] = actual_state_s1[59]||actual_state_s1[66]||actual_state_s1[32];
  assign next_state_s1[61] = actual_state_s1[66]||actual_state_s1[56];
  assign next_state_s1[62] = actual_state_s1[66]||actual_state_s1[59];
  assign next_state_s1[63] = actual_state_s1[54]||actual_state_s1[56];
  assign next_state_s1[64] = actual_state_s1[57]||actual_state_s1[65];
  assign next_state_s1[65] = actual_state_s1[64]&&  !actual_state_s1[58];
  assign next_state_s1[66] =   (actual_state_s1[67]||actual_state_s1[55])  &&  !actual_state_s1[63];
  assign next_state_s1[67] = actual_state_s1[32];
  assign next_state_s1[68] =   (actual_state_s1[19]&&actual_state_s1[13])  &&  !  (actual_state_s1[33]||actual_state_s1[7])  ;
  assign next_state_s1[69] = actual_state_s1[7];

  // For S2 pointer
  assign next_state_s2[0] = actual_state_s2[41];
  assign next_state_s2[1] = actual_state_s2[41]&&  !actual_state_s2[33];
  assign next_state_s2[2] = actual_state_s2[36]&&  !  (actual_state_s2[37]||actual_state_s2[7])  ;
  assign next_state_s2[3] =   (  (actual_state_s2[51]||actual_state_s2[34])  &&actual_state_s2[37])  &&  !actual_state_s2[2];
  assign next_state_s2[4] = actual_state_s2[4];
  assign next_state_s2[5] =   !  (actual_state_s2[21]&&actual_state_s2[4])  ;
  assign next_state_s2[6] =   (actual_state_s2[49]||actual_state_s2[32])  &&  !  (actual_state_s2[34]||actual_state_s2[37])  ;
  assign next_state_s2[7] =   (actual_state_s2[8]||actual_state_s2[9])  &&  !actual_state_s2[22];
  assign next_state_s2[8] = actual_state_s2[18]&&  !  (actual_state_s2[11]||actual_state_s2[33])  ;
  assign next_state_s2[9] = actual_state_s2[14]&&  !  (actual_state_s2[22]||actual_state_s2[33])  ;
  assign next_state_s2[10] = actual_state_s2[47]&&  !actual_state_s2[48];
  assign next_state_s2[11] = actual_state_s2[32];
  assign next_state_s2[12] = actual_state_s2[43]&&actual_state_s2[53];
  assign next_state_s2[13] =   (actual_state_s2[5]||actual_state_s2[49]||actual_state_s2[27])  &&  !actual_state_s2[21];
  assign next_state_s2[14] = actual_state_s2[31];
  assign next_state_s2[15] = actual_state_s2[35];
  assign next_state_s2[16] = actual_state_s2[29];
  assign next_state_s2[17] = actual_state_s2[65];
  assign next_state_s2[18] = actual_state_s2[53]||actual_state_s2[17];
  assign next_state_s2[19] = actual_state_s2[16];
  assign next_state_s2[20] = actual_state_s2[60];
  assign next_state_s2[21] =   !  (actual_state_s2[15]||actual_state_s2[2])  ;
  assign next_state_s2[22] =   (actual_state_s2[32]||actual_state_s2[49])  &&  !actual_state_s2[44];
  assign next_state_s2[23] =   !actual_state_s2[24];
  assign next_state_s2[24] =   (actual_state_s2[2]||  (actual_state_s2[43]&&actual_state_s2[53])  )  ;
  assign next_state_s2[25] = actual_state_s2[20]&&  !actual_state_s2[50];
  assign next_state_s2[26] = actual_state_s2[1]||actual_state_s2[30];
  assign next_state_s2[27] =   (  (actual_state_s2[5]||actual_state_s2[16])  &&actual_state_s2[26])  &&  !actual_state_s2[21];
  assign next_state_s2[28] =   (actual_state_s2[34]&&actual_state_s2[2])  &&  !  (actual_state_s2[21]||actual_state_s2[0])  ;
  assign next_state_s2[29] = actual_state_s2[39]||actual_state_s2[41];
  assign next_state_s2[30] = actual_state_s2[10]||actual_state_s2[52]||actual_state_s2[53];
  assign next_state_s2[31] =   (actual_state_s2[3]||actual_state_s2[51]||actual_state_s2[10])  &&  !actual_state_s2[6];
  assign next_state_s2[32] =   !actual_state_s2[23];
  assign next_state_s2[33] =   (actual_state_s2[34]||actual_state_s2[45])  &&  !  (actual_state_s2[21]||actual_state_s2[7])  ;
  assign next_state_s2[34] =   (actual_state_s2[38]||actual_state_s2[26]||actual_state_s2[0])  &&  !actual_state_s2[28];
  assign next_state_s2[35] = actual_state_s2[12];
  assign next_state_s2[36] =   (actual_state_s2[15]||actual_state_s2[40])  &&  !actual_state_s2[38];
  assign next_state_s2[37] = actual_state_s2[10]&&  !actual_state_s2[2];
  assign next_state_s2[38] = actual_state_s2[34]&&  !  (actual_state_s2[32]||actual_state_s2[27])  ;
  assign next_state_s2[39] = actual_state_s2[10]||actual_state_s2[40];
  assign next_state_s2[40] = actual_state_s2[15]||actual_state_s2[20];
  assign next_state_s2[41] = actual_state_s2[53]&&  !actual_state_s2[42];
  assign next_state_s2[42] = actual_state_s2[32]||actual_state_s2[49];
  assign next_state_s2[43] = actual_state_s2[48];
  assign next_state_s2[44] = actual_state_s2[31];
  assign next_state_s2[45] = actual_state_s2[52]&&  !actual_state_s2[27];
  assign next_state_s2[46] = actual_state_s2[45]||actual_state_s2[32];
  assign next_state_s2[47] = actual_state_s2[34]||actual_state_s2[18];
  assign next_state_s2[48] = actual_state_s2[16]||actual_state_s2[53];
  assign next_state_s2[49] = actual_state_s2[25];
  assign next_state_s2[50] = actual_state_s2[49];
  assign next_state_s2[51] = actual_state_s2[8]&&  !actual_state_s2[6];
  assign next_state_s2[52] = actual_state_s2[58]&&  !actual_state_s2[46];
  assign next_state_s2[53] = actual_state_s2[55];
  assign next_state_s2[54] =   (actual_state_s2[63]||actual_state_s2[66])  &&  !actual_state_s2[60];
  assign next_state_s2[55] = actual_state_s2[59];
  assign next_state_s2[56] = actual_state_s2[61]&&  !  (actual_state_s2[64]||actual_state_s2[58])  ;
  assign next_state_s2[57] =   (actual_state_s2[62]||actual_state_s2[64])  &&  !  (actual_state_s2[63]||actual_state_s2[58]||actual_state_s2[61])  ;
  assign next_state_s2[58] = actual_state_s2[54];
  assign next_state_s2[59] =   (actual_state_s2[64]||actual_state_s2[67])  &&  !actual_state_s2[63];
  assign next_state_s2[60] = actual_state_s2[59]||actual_state_s2[66]||actual_state_s2[32];
  assign next_state_s2[61] = actual_state_s2[66]||actual_state_s2[56];
  assign next_state_s2[62] = actual_state_s2[66]||actual_state_s2[59];
  assign next_state_s2[63] = actual_state_s2[54]||actual_state_s2[56];
  assign next_state_s2[64] = actual_state_s2[57]||actual_state_s2[65];
  assign next_state_s2[65] = actual_state_s2[64]&&  !actual_state_s2[58];
  assign next_state_s2[66] =   (actual_state_s2[67]||actual_state_s2[55])  &&  !actual_state_s2[63];
  assign next_state_s2[67] = actual_state_s2[32];
  assign next_state_s2[68] =   (actual_state_s2[19]&&actual_state_s2[13])  &&  !  (actual_state_s2[33]||actual_state_s2[7])  ;
  assign next_state_s2[69] = actual_state_s2[7];


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

