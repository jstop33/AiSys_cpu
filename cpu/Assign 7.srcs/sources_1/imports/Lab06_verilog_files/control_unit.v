//`timescale 1ns / 1ps
`include "opcodes.v" 
`include "ALUopcodes.v" 

module control_unit(

    input [3:0] opcode,
    input [5:0] func_code,
    input branch,
    
    output ctrl_is_halted,
    
    output IFflush,
    output [4:0] ALUOperation,
    output ALUSrc,
    output[1:0] whichtoReg,
    output [1:0] PCSource,
    output [1:0] RegDest,
    output RegWrite,
    output d_MemWrite,
    output d_MemRead,
    //output i_ReadM,
    //output i_WriteM,
    output isWWD
    );
    
    reg [4:0] r_ALUOperation;
    
    reg r_PCWriteCond;
    reg [1:0] r_ALUSrc;
    reg [1:0] r_PCSource;
    reg [1:0] r_RegWrite;
    reg [1:0] r_RegDest;
    reg [1:0] r_whichtoReg;
    reg r_isWWD; 
    reg r_ctrl_is_halted; 
    reg r_d_MemRead;
    reg r_d_MemWrite;
    reg r_i_ReadM ;
    reg r_i_WriteM; 
    reg r_IFflush; 
    
    assign ctrl_is_halted = r_ctrl_is_halted;
    
    assign ALUOperation = r_ALUOperation;
    assign ALUSrc =  r_ALUSrc;
    assign PCSource =  r_PCSource;
    assign RegDest =  r_RegDest;
    assign whichtoReg = r_whichtoReg;
    assign RegWrite =  r_RegWrite;
    assign isWWD = r_isWWD;  
    assign d_MemRead = r_d_MemRead;
    assign d_MemWrite = r_d_MemWrite;
    assign i_ReadM = r_i_ReadM;
    assign i_WriteM = r_i_WriteM; 
    assign IFflush = r_IFflush;

always @(*) begin // next stage에 필요한 control signal 
    if (opcode == 4'd15) begin 
        if(func_code == `FUNC_JRL) begin 
            r_RegDest = 2'b10;// $2
        end 
        else begin 
            r_RegDest = 2'b01;
        end       
    end
    else if (opcode == `OPCODE_JAL) begin 
        r_RegDest = 2'b10; // $2
    end 
    else begin 
        r_RegDest = 2'b00;
    end
    //ALUSrc
    case(opcode) 
        `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ: begin 
            r_ALUSrc = 0;
         end
         4'd15: begin 
            r_ALUSrc = 0;
         end
         default: begin 
            r_ALUSrc = 1;
         end
    endcase 
    
    //whichtoReg
    case(opcode)
        `OPCODE_JAL: r_whichtoReg = 2'b10; // $pc
         4'd15: begin 
            if(func_code == `FUNC_JRL) begin 
                r_whichtoReg = 2'b10; // $pc
            end 
            else begin 
                r_whichtoReg = 2'b00; // 다른건 기본적으로 ALUOut
            end 
         end
        `OPCODE_LWD: r_whichtoReg = 2'b01;// Memory에서 받아옴
         default: r_whichtoReg = 2'b00;
    endcase
    //RegWrite - opcode에 따라 제어해줘야
    //if(IFflush) begin 
        //r_RegWrite = 0;
    //end
    //else begin 
        case(opcode)
            `OPCODE_SWD: r_RegWrite = 0;  
            `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ:  r_RegWrite = 0;
            `OPCODE_JMP: r_RegWrite = 0;  
            4'd15: begin 
                case(func_code)
                    `FUNC_WWD,`FUNC_JPR,`FUNC_HLT: r_RegWrite = 0;
                    default: r_RegWrite = 1;
                endcase
            end 
            default: r_RegWrite = 1;          
        endcase
    //end 
    
    r_d_MemRead = 0;
    r_d_MemWrite = 0;
    // default로 읽고, 쓰는 건 안되게
    r_i_ReadM = 1;
    r_i_WriteM = 0;
    if(opcode == `OPCODE_SWD) begin
       r_d_MemWrite = 1;   
    end
    if(opcode == `OPCODE_LWD) begin 
       r_d_MemRead = 1;
    end
    // PCSource 
    // Control hazard -> IF Flush
    r_PCSource = 2'b00; 
    r_IFflush = 0;
    //end
    //else begin 
        case(opcode) 
            `OPCODE_JMP, `OPCODE_JAL: begin 
                r_PCSource = 2'b10; //
                r_IFflush = 1;
            end
            `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ: begin 
                if (branch) begin 
                    r_PCSource = 2'b01;
                    r_IFflush = 1;
                end
                else begin 
                    r_PCSource = 2'b00;// pc + 1
                    r_IFflush = 0;
                end
            end
            4'd15: begin 
                case(func_code) 
                    `FUNC_JPR, `FUNC_JRL: begin 
                        r_PCSource = 2'b11; // $rs
                        r_IFflush = 1;
                    end
                endcase
            end
            default: begin 
                r_PCSource = 2'b00; // pc + 4가 기본
                r_IFflush = 0;
            end
        endcase
        // ALUOperation
        r_ALUOperation = `OP_ADD;
        case(opcode)
            4'd15: begin
                case(func_code)
                    `FUNC_ADD: r_ALUOperation = `OP_ADD;
                    `FUNC_SUB: r_ALUOperation = `OP_SUB;
                    `FUNC_AND: r_ALUOperation = `OP_AND;
                    `FUNC_ORR: r_ALUOperation = `OP_OR;
                    `FUNC_NOT: r_ALUOperation = `OP_NOT;
                    `FUNC_TCP: r_ALUOperation = `OP_TCP; 
                    `FUNC_SHL: r_ALUOperation = `OP_ALS;
                    `FUNC_SHR: r_ALUOperation = `OP_ARS; 
                endcase
            end
            `OPCODE_ADI: r_ALUOperation = `OP_ADD;
            `OPCODE_ORI: r_ALUOperation = `OP_OR;
            `OPCODE_LHI: r_ALUOperation = `OP_BLLS8;
            // branch

            `OPCODE_BNE: r_ALUOperation = `OP_NEQ; 
            `OPCODE_BEQ: r_ALUOperation = `OP_EQ;
            `OPCODE_BGZ: r_ALUOperation = `OP_GZ;
            `OPCODE_BLZ: r_ALUOperation = `OP_LZ;

        endcase
    
    //isWWD
    r_ctrl_is_halted = 0;
    if (opcode == 4'd15) begin 
        if(func_code == `FUNC_HLT) begin 
            r_ctrl_is_halted = 1;   
        end
    end
    r_isWWD = 0;
    //if(next_stage == `ID) begin 
        if (opcode == 4'd15) begin 
            if(func_code == `FUNC_WWD) begin
                 r_isWWD = 1;
            end
        end
    //end 
end

endmodule
