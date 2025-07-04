`timescale 1ns/1ns
`define PERIOD1 100
`define MEMORY_SIZE 256	//	size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16	//	instead of 2^16 words to reduce memory
			//	requirements in the Active-HDL simulator 

module Memory(clk, reset_n, i_readM, i_writeM, i_address, i_data, d_readM, d_writeM, d_address, d_data);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;
	
	// Instruction memory interface
	input i_readM;
	wire i_readM;
	input i_writeM;
	wire i_writeM;
	input [`WORD_SIZE-1:0] i_address;
	wire [`WORD_SIZE-1:0] i_address;
	inout i_data;
	wire [4*`WORD_SIZE-1:0] i_data;
	
	// Data memory interface
	input d_readM;
	wire d_readM;
	input d_writeM;
	wire d_writeM;
	input [`WORD_SIZE-1:0] d_address;
	wire [`WORD_SIZE-1:0] d_address;
	inout d_data;
	wire [4*`WORD_SIZE-1:0] d_data;
    //output i_data_valid;
	//output d_data_valid;
	
	reg [`WORD_SIZE-1:0] memory [0:`MEMORY_SIZE-1];
	reg [4*`WORD_SIZE-1:0] i_outputData;
	reg [4*`WORD_SIZE-1:0] d_outputData;
	
	assign i_data = i_readM? i_outputData: {4{`WORD_SIZE'bz}};
	assign d_data = d_readM? d_outputData: {4{`WORD_SIZE'bz}};
	reg [1:0] i_mem_latency;
	reg [1:0] next_i_mem_latency;
	
	reg [1:0] d_mem_latency;
	reg [1:0] next_d_mem_latency;
	reg r_d_data_valid;
	reg r_i_data_valid;
	assign d_data_valid = r_d_data_valid;
	assign i_data_valid = r_i_data_valid;
	
	always @(*) begin
	   if(i_readM || i_writeM) begin 
           if(i_mem_latency < 2'b11) begin 
               next_i_mem_latency = i_mem_latency + 1;        
           end
           else begin 
               next_i_mem_latency = 2'b00;
           end 
       end 
	end 	
	
	always @(*) begin
	   if(d_readM || d_writeM) begin 
           if(d_mem_latency < 2'b11) begin 
               next_d_mem_latency = d_mem_latency + 1;        
           end
           else begin 
               next_d_mem_latency = 2'b00;
           end 
       end 
	end 
	
	always@(posedge clk)
		if(!reset_n)
			begin
				memory[16'h0] <= 16'h9023; 
				memory[16'h1] <= 16'h1;
				memory[16'h2] <= 16'hffff;
				memory[16'h3] <= 16'h0;
				memory[16'h4] <= 16'h0;
				memory[16'h5] <= 16'h0;
				memory[16'h6] <= 16'h0;
				memory[16'h7] <= 16'h0;
				memory[16'h8] <= 16'h0;
				memory[16'h9] <= 16'h0;
				memory[16'ha] <= 16'h0;
				memory[16'hb] <= 16'h0;
				memory[16'hc] <= 16'h0;
				memory[16'hd] <= 16'h0;
				memory[16'he] <= 16'h0;
				memory[16'hf] <= 16'h0;
				memory[16'h10] <= 16'h0;
				memory[16'h11] <= 16'h0;
				memory[16'h12] <= 16'h0;
				memory[16'h13] <= 16'h0;
				memory[16'h14] <= 16'h0;
				memory[16'h15] <= 16'h0;
				memory[16'h16] <= 16'h0;
				memory[16'h17] <= 16'h0;
				memory[16'h18] <= 16'h0;
				memory[16'h19] <= 16'h0;
				memory[16'h1a] <= 16'h0;
				memory[16'h1b] <= 16'h0;
				memory[16'h1c] <= 16'h0;
				memory[16'h1d] <= 16'h0;
				memory[16'h1e] <= 16'h0;
				memory[16'h1f] <= 16'h0;
				memory[16'h20] <= 16'h0;
				memory[16'h21] <= 16'h0;
				memory[16'h22] <= 16'h0;
				memory[16'h23] <= 16'h6000;
				memory[16'h24] <= 16'hf01c;
				memory[16'h25] <= 16'h6100;
				memory[16'h26] <= 16'hf41c;
				memory[16'h27] <= 16'h6200;
				memory[16'h28] <= 16'hf81c;
				memory[16'h29] <= 16'h6300;
				memory[16'h2a] <= 16'hfc1c;
				memory[16'h2b] <= 16'h4401;
				memory[16'h2c] <= 16'hf01c;
				memory[16'h2d] <= 16'h4001;
				memory[16'h2e] <= 16'hf01c;
				memory[16'h2f] <= 16'h5901;
				memory[16'h30] <= 16'hf41c;
				memory[16'h31] <= 16'h5502;
				memory[16'h32] <= 16'hf41c;
				memory[16'h33] <= 16'h5503;
				memory[16'h34] <= 16'hf41c;
				memory[16'h35] <= 16'hf2c0;
				memory[16'h36] <= 16'hfc1c;
				memory[16'h37] <= 16'hf6c0;
				memory[16'h38] <= 16'hfc1c;
				memory[16'h39] <= 16'hf1c0;
				memory[16'h3a] <= 16'hfc1c;
				memory[16'h3b] <= 16'hf2c1;
				memory[16'h3c] <= 16'hfc1c;
				memory[16'h3d] <= 16'hf8c1;
				memory[16'h3e] <= 16'hfc1c;
				memory[16'h3f] <= 16'hf6c1;
				memory[16'h40] <= 16'hfc1c;
				memory[16'h41] <= 16'hf9c1;
				memory[16'h42] <= 16'hfc1c;
				memory[16'h43] <= 16'hf1c1;
				memory[16'h44] <= 16'hfc1c;
				memory[16'h45] <= 16'hf4c1;
				memory[16'h46] <= 16'hfc1c;
				memory[16'h47] <= 16'hf2c2;
				memory[16'h48] <= 16'hfc1c;
				memory[16'h49] <= 16'hf6c2;
				memory[16'h4a] <= 16'hfc1c;
				memory[16'h4b] <= 16'hf1c2;
				memory[16'h4c] <= 16'hfc1c;
				memory[16'h4d] <= 16'hf2c3;
				memory[16'h4e] <= 16'hfc1c;
				memory[16'h4f] <= 16'hf6c3;
				memory[16'h50] <= 16'hfc1c;
				memory[16'h51] <= 16'hf1c3;
				memory[16'h52] <= 16'hfc1c;
				memory[16'h53] <= 16'hf0c4;
				memory[16'h54] <= 16'hfc1c;
				memory[16'h55] <= 16'hf4c4;
				memory[16'h56] <= 16'hfc1c;
				memory[16'h57] <= 16'hf8c4;
				memory[16'h58] <= 16'hfc1c;
				memory[16'h59] <= 16'hf0c5;
				memory[16'h5a] <= 16'hfc1c;
				memory[16'h5b] <= 16'hf4c5;
				memory[16'h5c] <= 16'hfc1c;
				memory[16'h5d] <= 16'hf8c5;
				memory[16'h5e] <= 16'hfc1c;
				memory[16'h5f] <= 16'hf0c6;
				memory[16'h60] <= 16'hfc1c;
				memory[16'h61] <= 16'hf4c6;
				memory[16'h62] <= 16'hfc1c;
				memory[16'h63] <= 16'hf8c6;
				memory[16'h64] <= 16'hfc1c;
				memory[16'h65] <= 16'hf0c7;
				memory[16'h66] <= 16'hfc1c;
				memory[16'h67] <= 16'hf4c7;
				memory[16'h68] <= 16'hfc1c;
				memory[16'h69] <= 16'hf8c7;
				memory[16'h6a] <= 16'hfc1c;
				memory[16'h6b] <= 16'h7801;
				memory[16'h6c] <= 16'hf01c;
				memory[16'h6d] <= 16'h7902;
				memory[16'h6e] <= 16'hf41c;
				memory[16'h6f] <= 16'h8901;
				memory[16'h70] <= 16'h8802;
				memory[16'h71] <= 16'h7801;
				memory[16'h72] <= 16'hf01c;
				memory[16'h73] <= 16'h7902;
				memory[16'h74] <= 16'hf41c;
				memory[16'h75] <= 16'h9076;
				memory[16'h76] <= 16'hf01c;
				memory[16'h77] <= 16'h9079;
				memory[16'h78] <= 16'hf01d;
				memory[16'h79] <= 16'hf41c;
				memory[16'h7a] <= 16'hb01; 
				memory[16'h7b] <= 16'h907d; 
				memory[16'h7c] <= 16'hf01d;
				memory[16'h7d] <= 16'hf01c; 
				memory[16'h7e] <= 16'h601;
				memory[16'h7f] <= 16'hf01d;
				memory[16'h80] <= 16'hf41c; 
				memory[16'h81] <= 16'h1601; 
				memory[16'h82] <= 16'h9084; 
				memory[16'h83] <= 16'hf01d;
				memory[16'h84] <= 16'hf01c; 
				memory[16'h85] <= 16'h1b01; 
				memory[16'h86] <= 16'hf01d;
				memory[16'h87] <= 16'hf41c; 
				memory[16'h88] <= 16'h2001; 
				memory[16'h89] <= 16'h908b; 
				memory[16'h8a] <= 16'hf01d;
				memory[16'h8b] <= 16'hf01c; 
				memory[16'h8c] <= 16'h2401; 
				memory[16'h8d] <= 16'hf01d;
				memory[16'h8e] <= 16'hf41c; 
				memory[16'h8f] <= 16'h2801; 
				memory[16'h90] <= 16'h9092; 
				memory[16'h91] <= 16'hf01d;
				memory[16'h92] <= 16'hf01c; 
				memory[16'h93] <= 16'h3001;
				memory[16'h94] <= 16'hf01d;
				memory[16'h95] <= 16'hf41c; 
				memory[16'h96] <= 16'h3401; 
				memory[16'h97] <= 16'h9099; 
				memory[16'h98] <= 16'hf01d;
				memory[16'h99] <= 16'hf01c; 
				memory[16'h9a] <= 16'h3801; 
				memory[16'h9b] <= 16'h909d; 
				memory[16'h9c] <= 16'hf01d;
				memory[16'h9d] <= 16'hf41c; 
				memory[16'h9e] <= 16'ha0af; 
				memory[16'h9f] <= 16'hf01c; 
				memory[16'ha0] <= 16'ha0ae; 
				memory[16'ha1] <= 16'hf01d;
				memory[16'ha2] <= 16'hf41c; 
				memory[16'ha3] <= 16'h6300; 
				memory[16'ha4] <= 16'h5f03; 
				memory[16'ha5] <= 16'h6000; 
				memory[16'ha6] <= 16'h4005; 
				memory[16'ha7] <= 16'ha0b2; 
				memory[16'ha8] <= 16'hf01c;
				memory[16'ha9] <= 16'h90b1;
				memory[16'haa] <= 16'h4900;
				memory[16'hab] <= 16'hf41a;
				memory[16'hac] <= 16'hf01c;
				memory[16'had] <= 16'h90c7;
				memory[16'hae] <= 16'h4a01; 
				memory[16'haf] <= 16'hf819; 
				memory[16'hb0] <= 16'hf01d;
				memory[16'hb1] <= 16'ha0aa;
				memory[16'hb2] <= 16'h41ff; 
				memory[16'hb3] <= 16'h2404; 
				memory[16'hb4] <= 16'h6000; 
				memory[16'hb5] <= 16'h5001; 
				memory[16'hb6] <= 16'hf819; 
				memory[16'hb7] <= 16'hf01d; 
				memory[16'hb8] <= 16'h8e00; 
				memory[16'hb9] <= 16'h8c01; 
				memory[16'hba] <= 16'h4f02; 
				memory[16'hbb] <= 16'h40fe; 
				memory[16'hbc] <= 16'ha0b2; 
				memory[16'hbd] <= 16'h7dff;  
				memory[16'hbe] <= 16'h8cff;   
				memory[16'hbf] <= 16'h44ff; 
				memory[16'hc0] <= 16'ha0b2; 
				memory[16'hc1] <= 16'h7dff;
				memory[16'hc2] <= 16'h7efe;
				memory[16'hc3] <= 16'hf100;
				memory[16'hc4] <= 16'h4ffe;
				memory[16'hc5] <= 16'hf819;
				memory[16'hc6] <= 16'hf01d;
				memory[16'hc7] <= 16'h6301;
				memory[16'hc8] <= 16'h6000;
				memory[16'hc9] <= 16'h4610;
				memory[16'hca] <= 16'h7800;
				memory[16'hcb] <= 16'hf440;
				memory[16'hcc] <= 16'h4a01;
				memory[16'hcd] <= 16'h6000;
				memory[16'hce] <= 16'h4017;
				memory[16'hcf] <= 16'hf882;
				memory[16'hd0] <= 16'h4fff;
				memory[16'hd1] <= 16'h2cf8;
				memory[16'hd2] <= 16'hf41c;
				memory[16'hd3] <= 16'h6000;
				memory[16'hd4] <= 16'hf81c;
				memory[16'hd5] <= 16'hf01d;
			end
		else // width ����
			begin 
			    i_mem_latency <= next_i_mem_latency;
			    d_mem_latency <= next_d_mem_latency;
			    
				if(i_mem_latency == 2'b10) begin 
				    //r_i_data_valid <= 1;
				    i_outputData[`WORD_SIZE-1:0]  <= memory[i_address];
				    i_outputData[2*`WORD_SIZE-1:`WORD_SIZE]  <= memory[i_address + 1];
				    i_outputData[3*`WORD_SIZE-1: 2*`WORD_SIZE]  <= memory[i_address + 2];
				    i_outputData[4*`WORD_SIZE-1: 3*`WORD_SIZE]  <= memory[i_address + 3];
				end 
				else begin 
				    //r_i_data_valid <= 0;
				    i_outputData <= {4{`WORD_SIZE'bz}};
				end
				if(i_writeM) begin 
				    //r_i_data_valid <= 1;
				    memory[i_address] <= i_data[`WORD_SIZE-1:0];
				    memory[i_address+1] <= i_data[2*`WORD_SIZE-1:`WORD_SIZE];
				    memory[i_address+2] <= i_data[3*`WORD_SIZE-1:2*`WORD_SIZE];
				    memory[i_address+3] <= i_data[4*`WORD_SIZE-1:3*`WORD_SIZE];
				end 
				if(d_mem_latency == 2'b10) begin 
				    //r_d_data_valid <= 1;
				    d_outputData[`WORD_SIZE-1:0]  <= memory[d_address];
				    d_outputData[2*`WORD_SIZE-1:`WORD_SIZE]  <= memory[d_address + 1];
				    d_outputData[3*`WORD_SIZE-1: 2*`WORD_SIZE]  <= memory[d_address + 2];
				    d_outputData[4*`WORD_SIZE-1: 3*`WORD_SIZE]  <= memory[d_address + 3];
				end 
				else begin 
				    //r_d_data_valid <= 0;
				    d_outputData <= {4{`WORD_SIZE'bz}};
				end
				if(d_writeM) begin 				    
				    memory[d_address] <= d_data[`WORD_SIZE-1:0];
				    memory[d_address+1] <= d_data[2*`WORD_SIZE-1:`WORD_SIZE];
				    memory[d_address+2] <= d_data[3*`WORD_SIZE-1:2*`WORD_SIZE];
				    memory[d_address+3] <= d_data[4*`WORD_SIZE-1:3*`WORD_SIZE];
				end 
			end
endmodule