`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/20 12:36:34
// Design Name: 
// Module Name: cpu_top
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


module cpu_top(
    input CLK100MHZ,
    input [1:0] btn,
    output uart_txd_in
    );
    
    wire i_readM;
	wire i_writeM;
	wire [`WORD_SIZE-1:0] i_address;
	wire [4*`WORD_SIZE-1:0] f_cpu_i_data;		
	wire [4*`WORD_SIZE-1:0] t_cpu_i_data;	
	
	// Data memory interface
	wire d_readM;
	wire d_writeM;
	wire [`WORD_SIZE-1:0] d_address;
	wire [4*`WORD_SIZE-1:0] f_cpu_d_data;
	wire [4*`WORD_SIZE-1:0] t_cpu_d_data;
    wire i_data_valid;
    wire d_data_valid; 
    wire slow_clock;
    
	// for debuging purpose
	wire [`WORD_SIZE-1:0] num_inst;		// number of instruction during execution
	wire [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	wire is_halted;				// set if the cpu is halted

	// instantiate the unit under test
	cpu UUT (slow_clock, btn[0], i_readM, i_writeM, i_address, t_cpu_i_data, f_cpu_i_data, i_data_valid, d_readM, d_writeM, d_address, t_cpu_d_data,f_cpu_d_data, d_data_valid, num_inst, output_port, is_halted);
	Memory NUUT(slow_clock, btn[0], i_readM, i_writeM, i_address, f_cpu_i_data, t_cpu_i_data, i_data_valid, d_readM, d_writeM, d_address, f_cpu_d_data, t_cpu_d_data, d_data_valid);		   
	test TEST(slow_clock, btn[0], num_inst,output_port,is_halted, uart_txd_in);
	clock_divider DIVIDER (CLK100MHZ, slow_clock);
	
endmodule
