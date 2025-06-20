`timescale 1ns / 1ps
`define WORD_SIZE 16  
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/24 15:00:20
// Design Name: 
// Module Name: cache
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
// C = 16 words B = 4 words C/B = 4 idx = 2bit, bo = 2bit, G = 1, t = 12

module cache(
    input [15:0] f_cpu_address,
    input f_cpu_Read,
    input f_cpu_Write,
    input clk,
    input reset_n,
   
    output [`WORD_SIZE - 1:0] t_mem_address,
    output t_mem_Read,
    output t_mem_Write,
    
    input [`WORD_SIZE - 1:0] f_cpu_data,
    output [`WORD_SIZE - 1:0] t_cpu_data,
    output t_cpu_data_valid,
    input [4*`WORD_SIZE - 1:0] f_mem_data,
    output [4*`WORD_SIZE - 1:0] t_mem_data,
    input mem_data_valid
    );
    reg [15:0] addr_store [0:5];
    reg [15:0] data_store [0:5];
    
    reg [11:0] tag_bank [0:3];
    reg valid [0:3];
    reg dirty [0:3];
    reg [4*`WORD_SIZE-1:0] data_bank [0:3];
    wire [3:2] idx;
    wire [11:0] tag;
    wire [1:0] bo;
    reg hit;
    reg [4*`WORD_SIZE-1:0] data_line;
    
    reg r_t_mem_Read;
    reg r_t_mem_Write;
    reg [`WORD_SIZE - 1:0] r_cpu_data;
    reg [`WORD_SIZE - 1:0] next_r_cpu_data;
    reg [4*`WORD_SIZE - 1:0] r_mem_data;
    reg [4*`WORD_SIZE - 1:0] next_r_mem_data;
    reg next_t_mem_Write;
    reg next_t_mem_Read;
    reg next_dirty;
    reg [4*`WORD_SIZE - 1:0] next_data_bank;
    reg [11:0] next_tag;
    reg [`WORD_SIZE - 1:0] r_t_mem_address;
    reg [`WORD_SIZE - 1:0] next_r_t_mem_address;
    reg next_valid;
    reg r_f_cpu_Write = 0;
    reg next_r_f_cpu_Write = 0;
    
    reg [2:0] num_q;
    reg [2:0] next_num_q;
    reg [`WORD_SIZE - 1:0] address;
    reg [`WORD_SIZE - 1:0] data;
    reg [`WORD_SIZE - 1:0]  data_store [0:5];
    reg [`WORD_SIZE - 1:0]  addr_store [0:5];
    reg [`WORD_SIZE - 1:0]  next_data_store [0:5];
    reg [`WORD_SIZE - 1:0]  next_addr_store [0:5];
    
    reg block; // 00 block 없음, 01은 read 중, 10 은 write 중 
    reg next_block;
    
    reg [1:0] ls; // 0 -> load, 1 -> store, 2 -> idle 
    //reg writeReady;
    reg push;
    reg append;
    
    reg [15:0] num_access;
    reg [15:0] num_miss;
    reg [15:0] next_num_access;
    reg [15:0] next_num_miss;
    
    reg r_t_cpu_data_valid;
    
    assign tag = address [15:4];
    assign idx = address [3:2];
    assign bo = address [1:0];
    assign t_cpu_data = r_cpu_data;
    assign t_mem_data = r_mem_data;
    assign t_mem_address = r_t_mem_address;
    assign t_mem_Read = r_t_mem_Read;
    assign t_mem_Write = r_t_mem_Write;
    assign t_cpu_data_valid = r_t_cpu_data_valid;
    
    
    // 누구 기준으로 작업하느냐 세팅
    always @(*) begin 
        
        if (block == 0) begin 
            address = 16'bx;
            data = 16'bx;
            ls = 2'b10;
            if(num_q == 3'd0) begin 
                if(f_cpu_Read) begin    
                    address = f_cpu_address;
                    ls = 2'b00;
                end 
            end
            else begin 
                address = addr_store[0];
                data = data_store[0];
                ls = 2'b01;
            end     
        end       
    end
    // next_buffer 조작

    
    
    always @(*) begin 
            hit = (tag_bank[idx] == tag) && valid[idx];
            data_line = data_bank[idx];
            case (bo)
                2'b00: r_cpu_data = data_line[`WORD_SIZE-1:0];
                2'b01: r_cpu_data = data_line[2*`WORD_SIZE-1:`WORD_SIZE];
                2'b10: r_cpu_data = data_line[3*`WORD_SIZE-1:2*`WORD_SIZE];     
                2'b11: r_cpu_data = data_line[4*`WORD_SIZE-1:3*`WORD_SIZE];                 
            endcase
    end 
    // hit && miss 취급 (initial)
    
    always @(*) begin 
        next_num_access = num_access;
        if (hit == 1 ) begin
            next_num_access = num_access + 1;
        end 
    end 
    always @(*) begin 
        next_num_miss = num_miss;
        if (t_mem_Read && mem_data_valid) begin 
            next_num_miss = num_miss + 1;
        end 
    end 
    always @(*) begin 
        next_data_bank = data_line;
        next_dirty = dirty[idx];
        next_t_mem_Write = 0;
        next_t_mem_Read = 0;
        next_valid = valid[idx];
        next_tag = tag_bank[idx];
        next_r_t_mem_address = {address[15:2],2'b00};
        
        next_data_store[0] = data_store[0];
        next_data_store[1] = data_store[1];
        next_data_store[2] = data_store[2];
        next_data_store[3] = data_store[3];
        next_data_store[4] = data_store[4];
        next_data_store[5] = data_store[5];
            
        next_addr_store[0] = addr_store[0];
        next_addr_store[1] = addr_store[1];
        next_addr_store[2] = addr_store[2];
        next_addr_store[3] = addr_store[3];
        next_addr_store[4] = addr_store[4];
        next_addr_store[5] = addr_store[5];

        next_num_q = num_q;
        if (hit) begin          
            if(ls == 1) begin 
                next_dirty = 1;  
                next_data_bank = data_bank[idx];               
               
                case (bo)                  
                    2'b00: next_data_bank[`WORD_SIZE-1:0] = data;
                    2'b01: next_data_bank[2*`WORD_SIZE-1:`WORD_SIZE] = data;
                    2'b10: next_data_bank[3*`WORD_SIZE-1:2*`WORD_SIZE] = data;     
                    2'b11: next_data_bank[4*`WORD_SIZE-1:3*`WORD_SIZE] = data;                 
                endcase
                next_block = 0;
                if(num_q != 3'd0) begin 
                    next_data_store[0] = data_store[1];
                    next_data_store[1] = data_store[2];
                    next_data_store[2] = data_store[3];
                    next_data_store[3] = data_store[4];
                    next_data_store[4] = data_store[5];
                    next_data_store[5] = 16'bx;
                
                    next_addr_store[0] = addr_store[1];
                    next_addr_store[1] = addr_store[2];
                    next_addr_store[2] = addr_store[3];
                    next_addr_store[3] = addr_store[4];
                    next_addr_store[4] = addr_store[5];
                    next_addr_store[5] = 16'bx;
                    next_num_q = next_num_q - 1;
                end 
                
            end
        end
       
        else if (!hit) begin 
           next_block = 1;
           if (dirty[idx]) begin 
                next_r_t_mem_address = {tag_bank[idx],idx,2'b00};
                next_r_mem_data = data_bank[idx];
                next_t_mem_Write = 1;
                next_dirty = 0; 
                next_t_mem_Read = 0;
                
            end
            else begin 
                //next_r_mem_data = 64'bz;
                next_t_mem_Write = 0;
                next_t_mem_Read = 1;
                
            end 
        end
        
        // f_cpu_write 항상 취급
        if(f_cpu_Write == 1) begin 
                    next_data_store[next_num_q] = f_cpu_data;
                    next_addr_store[next_num_q] = f_cpu_address;                  
                    next_num_q = next_num_q + 1;

        end
        
        // read 올라왔을 때 취급
        if (t_mem_Read) begin 
            if(mem_data_valid) begin 
                next_data_bank = f_mem_data;
                next_dirty = 0;
                next_tag = t_mem_address[15:4];
                next_valid = 1;
                next_t_mem_Write = 0;
                next_t_mem_Read = 0;
                if(ls == 2'b00) begin 
                    next_block = 0;                   
                end
            end
        end
    end
    always @(*) begin 
        r_t_cpu_data_valid = (hit&&(!ls));  
    end
    always @(posedge clk) begin 
        if(!reset_n) begin 
            valid[2'b00] <= 12'b0;
            valid[2'b01] <= 12'b0;
            valid[2'b10] <= 12'b0;
            valid[2'b11] <= 12'b0;  
                   
            dirty[2'b00] <= 12'b0;
            dirty[2'b01] <= 12'b0;
            dirty[2'b10] <= 12'b0;
            dirty[2'b11] <= 12'b0;  
            block <= 0;
            next_block <= 0; 
            num_q <= 3'd0; 
            num_miss <= 16'd0;
            num_access <= 16'd0;
        end
        else begin 
                num_access <= next_num_access;
                num_miss <= next_num_miss;
                data_bank[idx] <= next_data_bank;
                r_t_mem_Write <= next_t_mem_Write;
                r_t_mem_Read <= next_t_mem_Read;
                dirty[idx] <= next_dirty; // 이미 적으러 내려감 -> dirty가 필요없음
                tag_bank[idx] <= next_tag;
                r_mem_data <= next_r_mem_data;
                valid[idx] <= next_valid;   
                r_f_cpu_Write <= next_r_f_cpu_Write;  
                block <= next_block;
                num_q <= next_num_q;
                r_t_mem_address <= next_r_t_mem_address;
                data_store[5] <= next_data_store[5];
                data_store[4] <= next_data_store[4];
                data_store[3] <= next_data_store[3];
                data_store[2] <= next_data_store[2];
                data_store[1] <= next_data_store[1];
                data_store[0] <= next_data_store[0];
                                       
                addr_store[5] <= next_addr_store[5];
                addr_store[4] <= next_addr_store[4];
                addr_store[3] <= next_addr_store[3];
                addr_store[2] <= next_addr_store[2];
                addr_store[1] <= next_addr_store[1];
                addr_store[0] <= next_addr_store[0];
        end
    end
endmodule
