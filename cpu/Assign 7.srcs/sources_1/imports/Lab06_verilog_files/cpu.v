`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"

module cpu(
        input Clk, 
        input Reset_N, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [4*`WORD_SIZE-1:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [4*`WORD_SIZE-1:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output is_halted
);
    // Datapath - control Unit
    wire [3:0] opcode;
    wire [5:0] func_code;
    wire isWWD;
    wire [1:0] PCSource;
    wire IR_Ready;
    wire [4:0] ALUOp;
    wire ALUSrc;
    wire [1:0] RegDest;
    wire [1:0] whichtoReg;
    wire d_MemWrite;
    wire d_MemRead;
    wire RegWrite1;
    wire [1:0] writeReg1;
    wire RegWrite2;
    wire [1:0] writeReg2;
    wire RegWrite3;
    wire [1:0] writeReg3;
    wire [1:0] rs;
    wire [1:0] rt;
    wire dataStall; 
    wire ctrl_is_halted;
    wire branch;
    wire [15:0] c_i_data;
    wire [15:0] c_i_address;
    wire [15:0] c_d_data;
    wire [15:0] c_d_address;
    wire c_d_readM;
    wire c_d_writeM;
    wire c_i_readM;
    wire c_i_writeM;
    
 control_unit Control(

    .opcode(opcode),
    .func_code(func_code),
    .branch(branch),
    
    .ctrl_is_halted(ctrl_is_halted),
    
    .IFflush(IFflush),
    .ALUOperation(ALUOp),
    .ALUSrc(ALUSrc),
    .whichtoReg(whichtoReg),
    .PCSource(PCSource),
    .RegDest(RegDest),
    .RegWrite(RegWrite),
    .d_MemRead(d_MemRead),
    .d_MemWrite(d_MemWrite),
    //.i_ReadM(i_readM),
    //.i_WriteM(i_writeM),
    .isWWD(isWWD)
    );
        
    datapath #(.WORD_SIZE (`WORD_SIZE)) 
        DP (
        .clk(Clk),
        .reset_n (Reset_N),
        .IR_Ready(IR_Ready),
        .num_inst(num_inst),
        .output_port (output_port),
        .d_ReadM(c_d_readM),
        .d_WriteM(c_d_writeM),
        .i_ReadM(c_i_readM),
        .i_WriteM(c_i_writeM),
        .is_halted(is_halted),
        
        
        .ctrl_is_halted(ctrl_is_halted),
        
        .IFflush(IFflush),
        .ALUOperation(ALUOp),
        .ALUSrc(ALUSrc),
        .whichtoReg(whichtoReg),
        .PCSource(PCSource),
        .RegDest(RegDest),
        .RegWrite(RegWrite),
        .d_MemRead(d_MemRead),
        .d_MemWrite(d_MemWrite),
        .isWWD(isWWD),

        
        .opcode(opcode),
        .func_code (func_code),
        .branch(branch),
        
        .i_address(c_i_address),
        .i_data(c_i_data),
        .d_address(c_d_address),
        .d_data(c_d_data),
        
        .RegWrite1(RegWrite1),
        .writeReg1(writeReg1),
        .RegWrite2(RegWrite2),
        .writeReg2(writeReg2),
        .RegWrite3(RegWrite3), 
        .writeReg3(writeReg3),
        .rs(rs), 
        .rt(rt),
        
        .dataStall(dataStall)
        );    
    datastall_unit 
        DS_UNIT(
        .RegWrite1(RegWrite1),
        .writeReg1(writeReg1),
        .RegWrite2(RegWrite2),
        .writeReg2(writeReg2),
        .RegWrite3(RegWrite3), 
        .writeReg3(writeReg3),
        .rs(rs), 
        .rt(rt),
        .opcode(opcode),
        .func_code(func_code),
        
        .dataStall(dataStall)
        );
    cache 
        I_CACHE(
            .f_cpu_address(c_i_address),
            .f_cpu_Read(c_i_readM),
            .f_cpu_Write(c_i_writeM),
            .clk(Clk),
            .reset_n(Reset_N),
            .t_mem_address(i_address),
            .t_mem_Read(i_readM),
            .t_mem_Write(i_writeM),
            
            .cpu_data(c_i_data),
            .mem_data(i_data)
        );
    cache 
        D_CACHE(
            .f_cpu_address(c_d_address),
            .f_cpu_Read(c_d_readM),
            .f_cpu_Write(c_d_writeM),
            .clk(Clk),
            .reset_n(Reset_N),
            .t_mem_address(d_address),
            .t_mem_Read(d_readM),
            .t_mem_Write(d_writeM),
            
            .cpu_data(c_d_data),
            .mem_data(d_data)    
        );
endmodule
