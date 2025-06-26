`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/25 18:19:50
// Design Name: 
// Module Name: cpu_io
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_io(
    input clk,
    input reset,
    output RsTx
    );
        
    reg rx_valid;
    reg [7:0] data_to_xmit; // treat it as output for core
    reg [7:0] next_data_to_xmit;
    reg tx_valid; // treat it as output for core
    reg next_tx_valid;
    wire tx_ready; // treat it as input for core 
    reg buffer_decrease;
    reg [15:0] data_reg [51:0];
    reg [15:0] next_data_reg [51:0];
    reg [7:0] num_q;
    reg [7:0] next_num_q;
    reg tx_started;
    reg [1:0] tx_counter;
    reg [1:0] next_tx_counter;
    wire [15:0] output_port;
    wire output_valid;
    wire [15:0] num_inst;
    reg [15:0] last_num_inst;
    integer i;

    uart_transmitter UART_T (.uart_sampling_clk(clk), .reset(reset), .RsTx(RsTx), .valid(tx_valid), .ready(tx_ready), .data_to_xmit(data_to_xmit)); 
    cpu_top CPU(clk, !reset, output_port, output_valid, num_inst);
      
    always @(*) begin // receiver ´Ü¿¡¼­
       buffer_decrease = 0;
       rx_valid = output_valid && (num_inst != last_num_inst);
       next_tx_counter = tx_counter;
       next_num_q = num_q;
       if (tx_valid && tx_ready) begin 
          if(tx_counter == 2'd1) begin 
             next_tx_counter = 2'd0;
             buffer_decrease = 1;
          end
          else begin 
             next_tx_counter = tx_counter + 2'd1;
          end
       end          
       if (buffer_decrease) begin 
           for(i = 0; i < 51; i = i + 1) begin 
               next_data_reg[i] = data_reg[i+1];
           end 
       end
       else begin 
           for(i = 0; i < 52; i = i + 1) begin 
               next_data_reg[i] = data_reg[i];
           end 
       end
       next_num_q = num_q + rx_valid - buffer_decrease;
       if (rx_valid == 1) begin 
           next_data_reg [next_num_q - 1] = output_port;
       end
   end
   
   always @(*) begin // output decode 
      if(num_q >= 8'd1) begin
         case(tx_counter) 
            2'd1: data_to_xmit = data_reg[0][7:0];
            2'd0: data_to_xmit = data_reg[0][15:8];
         endcase         
         tx_valid = 1;
      end
      else begin 
         tx_valid = 0;      
       end
    end    
    always @(posedge clk) begin 
        if(reset) begin  
            num_q <= 8'd0; 
            tx_counter <= 2'd0;          
        end
        else begin 
            num_q <= next_num_q;
            for(i = 0; i < 52; i = i + 1) begin 
               data_reg[i] <= next_data_reg[i];
            end 
            tx_counter <= next_tx_counter;
            last_num_inst <= num_inst;
        end 
    end
endmodule
