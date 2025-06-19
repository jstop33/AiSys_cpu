`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 02:01:43
// Design Name: 
// Module Name: datastall_unit
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


module datastall_unit(
    input RegWrite1,
    input [1:0] writeReg1,
    input RegWrite2,
    input [1:0] writeReg2,
    input RegWrite3, 
    input [1:0] writeReg3,
    input [1:0] rs, 
    input [1:0] rt,
    input [3:0] opcode,
    input [5:0] func_code,
    
    output dataStall
    );
    // dataStall
    
    reg useOne;
    reg  useTwo;
    reg r_dataStall;
    assign dataStall = r_dataStall;
    
    always @(*) begin 
        case(opcode) 
            `OPCODE_JMP, `OPCODE_JAL: useOne = 0;
            4'd15: begin 
                case(func_code) 
                    `FUNC_HLT: useOne = 0;
                    default: useOne = 1;
                endcase
            end
            default: useOne = 1;
        endcase
    end
    always @(*) begin 
        case(opcode)
            4'd15: begin 
                case(func_code) 
                    `FUNC_TCP,`FUNC_SHL,`FUNC_SHR: useTwo = 0;
                    `FUNC_WWD, `FUNC_HLT: useTwo = 0;
                    `FUNC_JPR, `FUNC_JRL: useTwo = 0;
                    default: useTwo = 1;
                endcase 
            end
            `OPCODE_BEQ, `OPCODE_BNE: useTwo = 1;
            `OPCODE_SWD: useTwo = 1;
            default: useTwo = 0;
        endcase 
    end
    always @(*) begin 
        if(useOne) begin 
            if( (RegWrite1&& (writeReg1 == rs)) || (RegWrite2&&(writeReg2 == rs)) || (RegWrite3&&(writeReg3 == rs))) begin 
                r_dataStall = 1;    
            end
            else begin 
                if(useTwo) begin 
                    if( (RegWrite1&&(writeReg1 == rt)) || (RegWrite2&&(writeReg2 == rt)) || (RegWrite3&&(writeReg3 == rt))) begin 
                        r_dataStall = 1;    
                    end
                    else begin 
                        r_dataStall = 0;
                    end
                end
                else begin 
                    r_dataStall = 0;  
                end               
            end
        end
        else begin 
            r_dataStall = 0;  
        end
    end
endmodule
