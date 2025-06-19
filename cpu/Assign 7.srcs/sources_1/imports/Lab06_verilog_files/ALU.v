`include "ALUopcodes.v"

module ALU (
input [15:0] A
, 
input [15:0] B, 
input Cin,
input [4:0] OP,
output [15:0] 
C,
output bool,
output Cout
   );
   reg [16:0] r_C;
   reg r_bool;
   reg r_Cout;
   reg [16:0] r_BCin;
   assign Cout = r_Cout;
   assign bool = r_bool;
   assign C = r_C[15:0];
    always @(*) begin
        r_bool = 1'bx;
        r_C = 16'bx;
        r_Cout = 0;  
        case (OP)
        `OP_ADD : begin
            r_C = A + B + Cin;
            r_Cout = r_C[16];
        end
        `OP_SUB: begin
            r_BCin = B + Cin;
            if (A < r_BCin) begin
                r_C = (1 << 16) + A - B - Cin; 
                r_Cout = 1;
            end 
            else begin
                r_C = A - B - Cin;   
                r_Cout = 0;     
            end            
        end
        `OP_ID: begin
            r_C[15:0] = A;
        end
        `OP_NAND: begin
            r_C[15:0] = ~(A & B);
        end
        `OP_NOR: begin
            r_C[15:0] = ~(A | B);
        end
        `OP_XNOR: begin
            r_C[15:0] = ~(A ^ B);
        end
        `OP_NOT: begin
            r_C[15:0] = ~ A;
        end
        `OP_AND: begin
            r_C[15:0] = A & B;
        end
        `OP_OR: begin
            r_C[15:0] = A | B;
        end
        `OP_XOR: begin
            r_C[15:0] = A^B;
        end
        `OP_LRS: begin
            r_C[14:0] = A[15:1];
            r_C[15] = 0;
        end
        `OP_ARS: begin
            r_C[14:0] = A[15:1];
            r_C[15] = A[15];
        end
        `OP_RR: begin
            r_C[14:0] = A[15:1];
            r_C[15] = A[0];
        end
        `OP_LLS: begin
            r_C[15:1] = A[14:0];
            r_C[0] = 0;
        end
        `OP_ALS: begin
            r_C[15:1] = A[14:0];
            r_C[0] = 0;
        end
        `OP_RL: begin
            r_C[15:1] = A[14:0];
            r_C[0] = A[15];
        end
        // 추가 연산
        `OP_BLLS8: begin
            r_C = {B[8:0],8'b0};
        end
        `OP_TCP: begin 
            r_C = ~ A + 1;
            r_Cout = r_C[16];
        end
        // 논리 명령어
        `OP_NEQ: begin 
            if(A^B == 16'b0) begin 
                r_bool = 0;
            end
            else begin 
                r_bool = 1;
            end
        end 
        `OP_EQ: begin 
            if(A^B == 16'b0) begin 
                r_bool = 1;
            end
            else begin 
                r_bool = 0;
            end
        end
        `OP_GZ: begin 
            if(A[15] == 0 && A!=16'b0) begin 
                r_bool = 1;
            end
            else begin 
                r_bool = 0;
            end
        end
        `OP_LZ: begin 
            if(A[15] == 1) begin 
                r_bool = 1;
            end
            else begin 
                r_bool = 0;
            end    
        end       
     endcase  
    end  
endmodule