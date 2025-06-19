`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/11 01:28:48
// Design Name: 
// Module Name: RF
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


module RF(
    input write,
    input clk, 
    input reset_n,
    input[1:0] addr1,
    input[1:0] addr2,
    input[1:0] addr3,
    output[15:0] data1,
    output [15:0] data2,
    input[15:0] data3
    );
    
    reg [15:0] r_data1;
    reg [15:0] r_data2;
    reg [15:0] rf [3:0];
    assign data1 = r_data1;
    assign data2 = r_data2;
    always @(*) begin 
            case (addr1)
                2'b00: r_data1 = rf[0];
                2'b01: r_data1 = rf[1];
                2'b10: r_data1 = rf[2];
                2'b11: r_data1 = rf[3];
            endcase
            case (addr2)
                2'b00: r_data2 = rf[0];
                2'b01: r_data2 = rf[1];
                2'b10: r_data2 = rf[2];
                2'b11: r_data2 = rf[3];  
            endcase
    end
    always @(posedge clk) begin
        if (!reset_n) begin
            //rf[0] <= 16'b0;
            //rf[1] <= 16'b0;
            //rf[2] <= 16'b0;
            //rf[3] <= 16'b0;
            r_data1 <= 16'b0;
            r_data2 <= 16'b0;
        end
        else begin
            if (write) begin
                 //$display("data3 %b", data3);
                case (addr3)
                    2'b00: rf[0] <= data3;
                    2'b01: rf[1] <= data3;
                    2'b10: rf[2] <= data3;
                    2'b11: rf[3] <= data3;
                endcase 
            end
        end
    end
endmodule