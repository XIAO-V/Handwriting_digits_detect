module uart_rx(
    input            clk            ,
    input            rst_n          ,
    input  [15:0]    BIT_CLK        ,
    input            rx             ,
    output reg       rx_done        ,
    output reg [7:0] rx_data    
);

// parameter BUART_RATE     =  115200                   ;
// parameter CLK_FREQUENCE  =  50000000                 ;
// parameter BIT_CLK        =  CLK_FREQUENCE/BUART_RATE ;//每一位需要多少个clk
// parameter BIT_WIDTH      =  `$clog2(BIT_CLK)         ;//BIT_CLK的位宽
parameter BIT_WIDTH         =  16                       ;

localparam  IDLE  = 2'b00,//检测下降沿，即接收开始
            START = 2'b01,//起始位
            DATA  = 2'b10,//数据位
            STOP  = 2'b11;//停止位

reg [1:0] 			detect_rx_negedge;//检查rx的下降沿到来

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        detect_rx_negedge <= 2'b11;
    else
        detect_rx_negedge <= {detect_rx_negedge[0],rx};//当detect_rx_negedge=10的时候，即检测到下降沿
end

reg [1 :0]          state      ;
reg [1 :0]          next_state ;
reg [BIT_WIDTH-1:0] cnt        ;
reg [2:0]           bit_num    ;//接收到数据位的第几位 0~7

//状态寄存
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        state <= IDLE;
    else 
        state <= next_state;
end

//状态转移
always @(*) begin
    next_state = state;
    case(state)
        IDLE:begin
            if(detect_rx_negedge == 2'b10)
                next_state = START;
        end
        START:begin
            if(cnt == BIT_CLK)
                next_state = DATA;
        end
        DATA:begin
            if(cnt == BIT_CLK && bit_num == 3'h7)
                next_state = STOP;
        end
        STOP:begin
            if(cnt == {1'b0,BIT_CLK[BIT_WIDTH-1:1]})
                next_state = IDLE;
        end
    endcase // state
end

//每个状态下的操作
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_done <= 1'b0;
        rx_data <= 1'b0;
        bit_num <= 1'b0;
        cnt <= 16'h1;
    end else 
        case(state)
            IDLE:begin
                rx_done <= 1'b0;
                rx_data <= 1'b0;
                bit_num <= 3'h0;
                cnt <= 16'h2;//补偿检测下降沿的一个周期
            end
            START:begin
                cnt <= cnt + 1'b1;
                if(cnt == BIT_CLK)
                    cnt <= 16'h1;
            end
            DATA:begin
                cnt <= cnt + 1'b1;
                if(cnt == {1'b0,BIT_CLK[BIT_WIDTH-1:1]}) begin //在每个bit的中间采样
                    rx_data[bit_num] <= rx;
                end

                if(cnt == BIT_CLK) begin
                    cnt <= 16'h1;
                    if(bit_num != 3'h7)
                        bit_num <= bit_num + 1'b1;
                end
            end
            STOP:begin
                cnt <= cnt + 1'b1;
                if(cnt == {1'b0,BIT_CLK[BIT_WIDTH-1:1]}) begin
                    cnt <= 16'h1;
                    rx_done <= 1'b1;
                end
            end
        endcase // state
end

endmodule // uart_rx