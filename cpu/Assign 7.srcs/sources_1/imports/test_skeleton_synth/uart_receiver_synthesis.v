module uart_receiver (
    input uart_sampling_clk,
    input reset,

    input RsRx,

    //Basic valid & ready handshake
    output valid,
    input ready,

    output reg [7:0] received_data
);
parameter IDLE = 2'b00;
parameter RECEIVING = 2'b01;
parameter WAIT = 2'b10;

reg [1:0] state;
reg [1:0] next_state; 
reg r_valid;
reg next_r_valid;
reg [9:0] counter_bit;
reg [9:0] next_counter_bit;
reg [3:0] counter_data; 
reg [3:0] next_counter_data;
reg [7:0] next_received_data;
assign valid = r_valid;
always @(*) begin // next state logic  
    next_state = state;
    next_counter_data = counter_data;
    next_received_data = received_data;
    next_counter_bit = counter_bit;  
    if(state == WAIT) begin 
        if(r_valid == 1 && ready) begin 
             next_state = IDLE;
        end
        else begin 
             next_state = state;
        end 
    end
    if(counter_bit == 10'd867) begin 
        next_counter_bit = 10'd0;   
        case(state) 
            IDLE: begin  
                next_counter_data = 4'd0;
                if(RsRx == 0) begin 
                    next_state = RECEIVING;      
                end
                else begin 
                    next_state = state; 
                end
            end
            RECEIVING: begin 
                if(counter_data == 4'd8) begin  
                    next_state = WAIT;             
                end  
                else begin 
                    next_state = state;
                    next_counter_data = counter_data + 4'd1;
                    next_received_data = received_data;
                    case (counter_data)
                        4'd0: next_received_data[0] = RsRx;
                        4'd1: next_received_data[1] = RsRx;
                        4'd2: next_received_data[2] = RsRx;
                        4'd3: next_received_data[3] = RsRx;
                        4'd4: next_received_data[4] = RsRx;
                        4'd5: next_received_data[5] = RsRx;
                        4'd6: next_received_data[6] = RsRx;    
                        4'd7: next_received_data[7] = RsRx;
                    endcase
                end 
            end
        endcase
    end
    else begin       
        next_counter_bit = counter_bit + 10'd1;
    end
end

always @(*) begin // output decode
    case(state) 
        IDLE: r_valid = 0;
        RECEIVING: r_valid = 0;
        WAIT: r_valid = 1; 
    endcase
end
always @(posedge uart_sampling_clk) begin 
    if (reset) begin 
       counter_bit <= 10'd0;
       counter_data <= 4'd0;
       state <= IDLE;
    end
    else begin 
        state <= next_state;
        counter_data <= next_counter_data;
        counter_bit <= next_counter_bit;
        received_data <= next_received_data;
    end
end   
endmodule