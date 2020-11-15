module rx_ctrl #(
	parameter			BIT_CLK = 16'd219,
	parameter			DOG_CNT = 24'd983040,
	parameter			RAM_END = 10'd784
)(
	/* top */
	input				clk,
	input				rst_n,
	input				rx,
	output reg			start,
	output reg			en,
	/* key */
	input				key,
	/* ram */
	output reg [7:0]	ram_q,
	output reg [9:0]	ram_addr,
	output reg			ram_en
);

wire					rx_done;
wire	[7:0]			rx_data;

uart_rx u_rx(
	.clk				(clk),
	.rst_n				(rst_n),
	.BIT_CLK			(BIT_CLK),
	.rx					(rx),
	.rx_done			(rx_done),
	.rx_data			(rx_data)
);

reg		[9:0]			rx_cnt;
reg		[23:0]			wait_cnt;
reg						dog;
reg						clr;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		rx_cnt <= 0;
	else if(dog)
		rx_cnt <= 0;
	else if(rx_done) begin
		if(rx_cnt==0 && (rx_data!=8'hAA))
			rx_cnt <= 0;
		else if(rx_cnt==RAM_END)
			rx_cnt <= 0;
		else
			rx_cnt <= rx_cnt + 1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin		// watch dog
	if(!rst_n)
		wait_cnt <= 0;
	else if(rx_cnt == 0)
		wait_cnt <= 0;
	else if(rx_done)
		wait_cnt <= 0;
	else if(dog)
		wait_cnt <= 0;
	else
		wait_cnt <= wait_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dog <= 1'b0;
	else if(wait_cnt == DOG_CNT)
		dog <= 1'b1;
	else
		dog <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		clr <= 1'b0;
	else if(key)
		clr <= 1'b1;
	else if(ram_addr==RAM_END-1'b1)
		clr <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ram_q <= 0;
		ram_en <= 0;
		ram_addr <= 0;
	end else if(key) begin
		ram_addr <= 0;
	end else if(clr) begin
		ram_q <= 0;
		ram_en <= 1;
		if(ram_addr==RAM_END-1'b1)
			ram_addr <= 0;
		else
			ram_addr <= ram_addr + 1'b1;
	end else if(rx_cnt>0 && rx_done) begin
		ram_q <= rx_data;
		ram_en <= 1;
		ram_addr <= rx_cnt - 1'b1;
	end else begin
		ram_en <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		en <= 1;
	else if(rx_cnt==RAM_END && rx_done)
		en <= 0;
	else
		en <= 1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		start <= 0;
	else if(!en)
		start <= 1;
	else
		start <= 0;
end

endmodule
