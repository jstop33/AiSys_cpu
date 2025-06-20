`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 13:59:26
// Design Name: 
// Module Name: clock_divider
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


module clock_divider(
    input clk,
    output slow_clock
    );
    
    reg r_slow_clock = 1'b0; 
    reg [19:0] counter = 20'd0;
    assign slow_clock = r_slow_clock;
    
    always @(posedge clk) begin 
        if (counter == 20'd14999) begin
                counter <= 26'd0;
                r_slow_clock <= ~ r_slow_clock;
        end 
        else begin
           counter <= counter + 1'd1;
        end
    end
endmodule
