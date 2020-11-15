module digit(
	input			clk,
	input			rst_n,
	input			stop,
	input	[3:0]	result,
	input			key,
	input	[12:0]	addr,
	output	reg		num,
	output	[15:0]	led
);

wire	[10:0]		q;
reg					flag;
reg		[3:0]		out;

rom_digit u_digit (
	.addra				(addr),
	.clka				(clk),
	.doa				(q),
	.rsta				(1'b0)
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		flag <= 0;
		out <= 15;
	end else if(key) begin
		flag <= 0;
		out <= 15;
	end else if(stop) begin
		flag <= ~flag;
		out <= result;
	end
end

always @(*) begin
	num = q[10];
	case(out)
		4'd0 : num = q[0];
		4'd1 : num = q[1];
		4'd2 : num = q[2];
		4'd3 : num = q[3];
		4'd4 : num = q[4];
		4'd5 : num = q[5];
		4'd6 : num = q[6];
		4'd7 : num = q[7];
		4'd8 : num = q[8];
		4'd9 : num = q[9];
		4'd15 : num = q[10];
		default : num = q[10];
	endcase
end

assign led = ~({flag, 11'h0, out});

endmodule
