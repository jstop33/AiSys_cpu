`timescale 1ns / 1ns
`include "opcodes.v"
module datapath #(parameter WORD_SIZE = 16)(
        input clk,
        input reset_n,
        //input inputReady,
        
        output [WORD_SIZE-1:0] address,
        output [WORD_SIZE-1:0] num_inst,
        output [WORD_SIZE-1:0]  output_port,
        output IR_Ready,
        output [3:0] opcode,
        output [5:0] func_code,
        output d_ReadM,
        output d_WriteM,
        output i_ReadM,
        output i_WriteM,
        output is_halted,
        output branch,
                
        output [WORD_SIZE-1:0] i_address, 
        inout [WORD_SIZE-1:0] i_data, 
        input i_data_valid,
        
        output [WORD_SIZE-1:0] d_address, 
        inout [WORD_SIZE-1:0] d_data, 
        input d_data_valid,
        
        output RegWrite1,
        output [1:0] writeReg1,
        output RegWrite2,
        output [1:0] writeReg2,
        output RegWrite3, 
        output [1:0] writeReg3,
        output [1:0] rs, 
        output [1:0] rt,
        
        input dataStall,
        
        input ctrl_is_halted,
        input IFflush,
        input [4:0] ALUOperation,
        input ALUSrc,
        input[1:0] whichtoReg,
        input [1:0] PCSource,
        input [1:0] RegDest,
        input RegWrite,
        input d_MemWrite,
        input d_MemRead,

        input isWWD
        
        
    );
    reg [WORD_SIZE-1:0] ALUOut;
    wire  ALU_Cout;
    reg [WORD_SIZE-1:0] pc;
    reg [WORD_SIZE-1:0] next_pc;
    reg [WORD_SIZE-1:0] IR;
    reg [WORD_SIZE-1:0] next_IR; 
    reg [WORD_SIZE-1:0] A;
    wire [WORD_SIZE-1:0] next_A;
    reg [WORD_SIZE-1:0] B;
    wire [WORD_SIZE-1:0] next_B;
    wire brCond;
    wire [WORD_SIZE-1:0] ALU; // clock에 맞춰서만 ALU에서 ALUOut으로
    

    reg next_r_writeM;
    reg [WORD_SIZE-1:0] r_d_address;
    reg [WORD_SIZE-1:0] r_i_address;
    reg [WORD_SIZE-1:0] r_num_inst;
    reg [WORD_SIZE-1:0] r_output_port;
    reg [WORD_SIZE-1:0] next_r_output_port;
    reg r_IR_Ready;
    reg next_r_IR_Ready;
    reg [3:0] r_opcode;
    reg [5:0] r_func_code;
    reg r_i_WriteM;
    reg r_i_ReadM;
    reg r_d_WriteM;
    reg r_d_ReadM;
    reg r_RegWrite1;
    reg [1:0] r_writeReg1;
    reg r_RegWrite2;
    reg [1:0] r_writeReg2;
    reg r_RegWrite3; 
    reg [1:0] r_writeReg3;
    reg [1:0] r_rs; 
    reg [1:0] r_rt;
    reg r_is_halted;
   
    
    reg [1:0] MEM_in_addr3;
    // rs
    reg [WORD_SIZE - 1 :0] EX_rs_data;
    reg [WORD_SIZE - 1 :0] MEM_rs_data;
    //
    reg [1:0] ID_rt;
    reg [WORD_SIZE - 1 :0] EX_rt_data;
    reg [1:0] ID_rd;
    reg [WORD_SIZE - 1 :0] ID_immediate;
    reg [WORD_SIZE - 1 :0] IF_pc;
    reg [WORD_SIZE - 1 :0] next_IF_pc;
    reg [WORD_SIZE - 1 :0] ID_pc;
    reg [WORD_SIZE - 1 :0] EX_pc;
    reg [WORD_SIZE - 1 :0] MEM_pc;
    reg [WORD_SIZE - 1 :0] next_ID_immediate;
    reg [1:0] ID_RegDest; // EX
    reg [4:0] ID_ALUOperation; // EX
    reg [1:0] ID_ALUSrc; // EX
    reg ID_d_MemWrite; // MEM
    reg EX_d_MemWrite;
    reg ID_d_MemRead; // MEM
    reg EX_d_MemRead;
    reg [1:0] ID_whichtoReg; // WB
    reg [1:0] EX_whichtoReg;
    reg [1:0] MEM_whichtoReg;
    reg  ID_RegWrite; // WB;
    reg  EX_RegWrite; 
    reg  MEM_RegWrite; 
    // num_inst 쪽 조작 -> valid 00이면 flush나 stall 된 명령어, valid 01이면 valid한 명령어, valid 10 이면 isWWD
    reg  [1:0] IF_valid;
    reg  [1:0] ID_valid;
    reg  [1:0] EX_valid; 
    reg  [1:0] MEM_valid;
    reg  [1:0] next_IF_valid;
    reg  [1:0] next_ID_valid;
    reg  ID_is_halted;
    reg  EX_is_halted;
    reg  MEM_is_halted;
    
    reg [1:0] EX_w_addr;
    reg [1:0] MEM_w_addr;
    reg [1:0] next_EX_w_addr;
    
    reg next_ID_RegWrite;
    reg next_ID_d_MemWrite;
    
    reg [WORD_SIZE-1:0] MEM_ReadData;
    reg [WORD_SIZE-1:0] next_MEM_ReadData;
    
    reg [WORD_SIZE-1:0] MEM_ALUOut;
    
    reg [WORD_SIZE-1:0] r_num_inst;
    reg [WORD_SIZE-1:0] next_r_num_inst;
    
    wire ALU_Cout_branch;
    wire bool_alu;
    wire [WORD_SIZE-1:0] ALUOut_branch;
   
    assign i_data = 16'bz; // 기본적으로 읽어올 예정 -> i data 쓸 일 있으면 재고함. 
    assign d_data = d_WriteM ? EX_rt_data: 16'bz;

    
    assign IR_Ready = r_IR_Ready;
    assign d_address = r_d_address;
    assign i_address = r_i_address;
    assign num_inst = next_r_num_inst;
    assign output_port = r_output_port; 
    assign opcode = r_opcode;
    assign func_code = r_func_code;
    assign d_WriteM = r_d_WriteM;
    assign d_ReadM = r_d_ReadM; 
    assign i_WriteM = r_i_WriteM;
    assign i_ReadM = r_i_ReadM;
    assign is_halted = r_is_halted;
    
    assign RegWrite1 = r_RegWrite1;
    assign RegWrite2 = r_RegWrite2;
    assign RegWrite3 = r_RegWrite3;
    assign writeReg1 = r_writeReg1;
    assign writeReg2 = r_writeReg2;
    assign writeReg3 = r_writeReg3;
    assign rs = r_rs;
    assign rt = r_rt;
    
    reg [WORD_SIZE-1:0] ALU_input1;
    reg [WORD_SIZE-1:0] ALU_input2;
    ALU alu(
        .A(ALU_input1),
        .B(ALU_input2), 
        .Cin(16'b0),
        .OP(ID_ALUOperation),
        .C(ALU),
        .Cout(ALU_Cout),
        .bool(bool_alu)
    );
    ALU branch_alu(
        .A(next_A),
        .B(next_B), 
        .Cin(16'b0),
        .OP(ALUOperation),
        .C(ALUOut_branch),
        .Cout(ALU_Cout_branch),
        .bool(branch)
    );
    reg [1:0] in_addr1;
    reg [1:0] in_addr2;
    reg [1:0] in_addr3;
    reg in_RegWrite;
    reg [WORD_SIZE-1:0] in_writeData;
    reg [1:0] AS_WB_valid;
    reg [1:0] AS_WB_RegWrite;
    RF rf (
        .write(in_RegWrite), // drop과 함께 쓰임
        .clk(clk),
        .reset_n(reset_n),
        .addr1(in_addr1),
        .addr2(in_addr2),
        .addr3(in_addr3),
        .data1(next_A),
        .data2(next_B),
        .data3(in_writeData)
    );
    always @(*) begin 
        r_i_ReadM = 1;
        r_i_WriteM = 0;
    end
    always @(*) begin // 메모리 쪽 access
            //r_d_address = ALUOut;       
            r_i_address = pc;
    end
    // MDR 쪽은 그냥 data 넣어주기만 하면 됨. 
    always @(*) begin // 그대로 IR에 넣어주기만 하면 됨.  
        next_IR = i_data; 
        next_IF_valid = 2'b01;
        if (IFflush) begin 
            next_IR = 16'bx;
            next_IF_valid = 2'b00;
        end
        if( !i_data_valid) begin 
            next_IR = 16'bx;
            next_IF_valid = 2'b00;
        end
    end
    
    always @(*) begin 
        next_IF_pc = pc + 1;
        if( !i_data_valid) begin 
            next_IF_pc = pc;
        end
    end
    
    always @(*) begin 
        r_opcode = IR[15:12];
        r_func_code = IR[5:0];
    end
    // ID
    always @(*) begin // register 쪽 조작
        in_addr1 = IR[11:10]; 
        in_addr2 = IR[9:8];
    end
    // ID 단계의 branch decode -> branch_alu가 자동 판단함
    // ID valid 처리
    always @(*) begin 
        if(IF_valid == 2'b01 && isWWD) begin 
            next_ID_valid = 2'b10;
        end
        else begin 
            next_ID_valid = IF_valid;
        end
    end
    // ID PCSource 계산
    always @(*) begin 
        next_ID_immediate = {{8{IR[7]}},IR[7:0]};
    end
    always @(*) begin // pc쪽 조작 -> nextPC를 준비해놓고 drop -> 여기 drop 여부는 mux를 
        next_pc = next_IF_pc;
        case(PCSource) 
            2'b00: next_pc = next_IF_pc;
            2'b01: next_pc = IF_pc + next_ID_immediate;// ID_pc + immediate
            2'b10: next_pc = {pc[15:12],IR[11:0]}; // jump
            2'b11: next_pc = next_A; // $rs  
        endcase    
    end 
    // control signal 저장
    always @(*) begin 
       next_ID_RegWrite = RegWrite;
       next_ID_d_MemWrite = d_MemWrite;
    end 
    // nextA, nextB는 바로 register output으로 연결해있음 -> clk에 맞춰서 A,B에 넣으면 됨.
    always @(*) begin // ALU Input 
        ALU_input1 = A;
        if(ID_ALUSrc) begin 
            ALU_input2 = ID_immediate;
        end
        else begin 
            ALU_input2 = B;
        end
    end
   // RegDest select
    always @(*) begin 
        case(ID_RegDest) 
            2'b00: next_EX_w_addr = ID_rt;
            2'b01: next_EX_w_addr = ID_rd;
            2'b10: next_EX_w_addr = 2'b10;
        endcase     
    end
    // MEM 쪽
    always @(*) begin 
        r_d_WriteM = EX_d_MemWrite;
        r_d_ReadM = EX_d_MemRead;
        if (r_d_WriteM === 1 || r_d_ReadM === 1) begin 
            r_d_address = ALUOut;
        end
        else begin 
            r_d_address = 16'bx;
        end 
        
        // write data는 앞에서 처리
        next_MEM_ReadData = d_data;
        
    end
    // WB 쪽
    always @(*) begin 
        in_RegWrite = (MEM_RegWrite && (MEM_valid != 2'b00));
        in_addr3 = MEM_w_addr;
        case(MEM_whichtoReg)
            2'b00: in_writeData = MEM_ALUOut;
            2'b01: in_writeData = MEM_ReadData;
            2'b10: in_writeData = MEM_pc;
        endcase         
    end
    // dataStall wires
    always @(*) begin 
        r_RegWrite1 = ID_RegWrite;
        r_RegWrite2 = EX_RegWrite;
        r_RegWrite3 = MEM_RegWrite;
        r_writeReg1 = next_EX_w_addr;
        r_writeReg2 = EX_w_addr;
        r_writeReg3 = MEM_w_addr; 
        r_rs = IR[11:10];
        r_rt = IR[9:8];
    end
    // 끝단에서 MEM_valid 처리 -> WB_valid같은 것이 만들어지면 좋을 듯. 그런데 얘는 asychronous하게 받아야함

    always @(*) begin 
        case(MEM_valid) 
            2'b00: begin 
                next_r_num_inst = r_num_inst;
            end
            2'b01: begin 
                next_r_num_inst = r_num_inst + 1;
                r_output_port = 16'bx;
            end
            2'b10: begin 
                next_r_num_inst = r_num_inst + 1;
                r_output_port = MEM_rs_data;
            end       
        endcase 
    end 
    always @(*) begin 
        r_is_halted = MEM_is_halted;
    end
    always @(posedge clk) begin 
       if(!reset_n) begin
            pc <= 16'b0;
            //IR <= 16'b0;
            ID_d_MemWrite <= 0; // MEM
            EX_d_MemWrite <= 0;
            ID_d_MemRead <= 0; // MEM
            EX_d_MemRead <= 0;
            
            ID_RegWrite <= 0; // WB;
            EX_RegWrite <= 0; 
            MEM_RegWrite <= 0; 
            
            ID_is_halted <= 0;
            EX_is_halted <= 0;
            MEM_is_halted <= 0;

            r_num_inst <= 16'b0;
            
            IF_valid <= 2'b00;
            ID_valid <= 2'b00;
            EX_valid <= 2'b00;
            MEM_valid <= 2'b00;
            
            r_i_ReadM <= 1;
            r_i_WriteM <= 0;
       end     
       else begin 
           // IF
           if((d_ReadM)|| (d_data_valid)) begin               
               if(!dataStall) begin
                   IF_valid <= next_IF_valid;
                   IR <= next_IR;
                   IF_pc <= next_IF_pc;
                   pc <= next_pc;
                   A <= next_A;
                   B <= next_B;
                   ID_pc <= IF_pc;
                   ID_rt <= IR[9:8];
                   ID_rd <= IR[7:6];
                   ID_immediate <= next_ID_immediate;
                   // ID - EX control signal
                   ID_RegDest <= RegDest;
                   ID_ALUOperation <= ALUOperation;
                   ID_ALUSrc <= ALUSrc;
                   ID_d_MemWrite <= next_ID_d_MemWrite;
                   ID_d_MemRead <= d_MemRead;
                   ID_whichtoReg <= whichtoReg;
                   ID_RegWrite <= next_ID_RegWrite;
                   ID_valid <= next_ID_valid;
                   ID_is_halted <= ctrl_is_halted;
               end    
               else begin 
                   ID_valid <= 2'b00;
                   ID_d_MemWrite <= 0;
                   ID_d_MemRead <= 0;
                   ID_RegWrite <= 0;
                   ID_is_halted <= 0;
               end   
               // valid 
               EX_valid <= ID_valid;
               MEM_valid <= EX_valid;  
               // halted
               EX_is_halted <= ID_is_halted;
               MEM_is_halted <= EX_is_halted;
               //EX
               
               EX_pc <= ID_pc;
               ALUOut <= ALU;
               EX_rs_data <= A;
               EX_rt_data <= B;
               EX_w_addr <= next_EX_w_addr;
               //control signal
               EX_d_MemWrite <= ID_d_MemWrite;
               EX_d_MemRead <= ID_d_MemRead;
               //
               
               EX_whichtoReg <= ID_whichtoReg;
               EX_RegWrite <= ID_RegWrite;
               // MEM
               MEM_rs_data <= EX_rs_data;
               MEM_pc <= EX_pc;
               MEM_ALUOut <= ALUOut;
               MEM_ReadData <= next_MEM_ReadData;
               MEM_whichtoReg <= EX_whichtoReg;
               MEM_w_addr <= EX_w_addr;
               MEM_RegWrite <= EX_RegWrite;           
           end
           else begin 
               MEM_valid <= 2'b00;
               MEM_RegWrite <= 0;
           end 
           r_num_inst <= next_r_num_inst;
       end    
    end
endmodule
