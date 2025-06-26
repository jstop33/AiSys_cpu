module uart_transmitter (
    input uart_sampling_clk,
    input reset,

    output reg RsTx,

    //Basic valid & ready handshake
    input valid,
    output ready,

    input [7:0] data_to_xmit
);

reg r_ready;
reg [7:0] data_reg;
reg [7:0] next_data_reg;
reg [1:0] state;
reg [1:0] next_state;
reg next_RsTx; 
parameter IDLE = 2'b00;
parameter XMIT = 2'b01;
parameter END_XMIT = 2'b10;
reg [9:0] counter_bit;
reg [9:0] next_counter_bit;
reg [3:0] counter_data;
reg [3:0] next_counter_data;


assign ready = r_ready;
always @(*) begin // next_state_logic
    next_state = state;
    next_counter_data  = counter_data;
    next_data_reg = data_reg;
    next_RsTx = RsTx;
    next_counter_bit = counter_bit;
        case(state)
            IDLE: begin 
                next_RsTx = RsTx;
                next_counter_data = 4'd0;
                if(valid == 1 && ready == 1) begin 
                    next_state = XMIT;
                    next_data_reg = data_to_xmit;
                    next_RsTx = 0;
                end  
                else begin 
                    next_state = state;
                end
            end
            XMIT: begin 
                if(counter_bit == 10'd867) begin 
                     next_counter_bit  = 10'd0;
                    if (counter_data == 4'd8) begin 
                        next_counter_data = 4'd0;
                        next_state = END_XMIT;
                        next_RsTx = 1;
                    end
                    else begin 
                        next_counter_data = counter_data + 4'd1;
                        case(counter_data)
                            4'd0: next_RsTx = data_reg[0];
                            4'd1: next_RsTx = data_reg[1];
                            4'd2: next_RsTx = data_reg[2];
                            4'd3: next_RsTx = data_reg[3];
                            4'd4: next_RsTx = data_reg[4];
                            4'd5: next_RsTx = data_reg[5];
                            4'd6: next_RsTx = data_reg[6];
                            4'd7: next_RsTx = data_reg[7];
                        endcase
                    end
                end 
                else begin 
                    next_counter_bit = counter_bit + 10'd1; 
                end
            end
            END_XMIT: begin 
                next_state = IDLE;    
            end              
        endcase
end
always @(*) begin // output logic 
    case(state)
        IDLE: begin 
            r_ready = 1;   
        end
        XMIT: begin 
            r_ready = 0;    
        end
        END_XMIT: begin
            r_ready = 0;
        end
    endcase
end
always @(posedge uart_sampling_clk) begin 
    if (reset) begin
        state <= IDLE;
        RsTx <= 1;
        counter_data = 10'd0;
        counter_bit = 10'd0;
    end
    else begin 
        state <= next_state;
        counter_data <= next_counter_data;
        data_reg <= next_data_reg;
        RsTx <= next_RsTx;
        counter_bit <= next_counter_bit;
    end
end

endmodule