module display (
	/* top */
	 input				clk,
	 input				rst_n,
	/* ram */
	input		[7:0]	ram_q,
	output		[9:0]	ram_addr,
	input				digit_q,
	output		[12:0]	digit_addr,
	/* vga */
	input		[11:0]	vga_x,
	input		[11:0]	vga_y,
	output		[23:0]	vga_rgb
);

// 448*448
localparam		S_X = 16;
localparam		S_Y = 16;
localparam		E_X = 16+448;
localparam		E_Y = 16+448;

wire			en;
wire [11:0]		addr_x;
wire [11:0]		addr_y;

// 132*86
localparam		S_X1 = 494-8;
localparam		S_Y1 = 140-8;
localparam		E_X1 = 132+494-8;
localparam		E_Y1 = 86+140-8;

wire			q_its;
wire [13:0]		addr_its;
wire			en_its;

// 60*86
localparam		S_X2 = 530-8;
localparam		S_Y2 = 254-8;
localparam		E_X2 = 60+530-8;
localparam		E_Y2 = 86+254-8;

wire			en_digit;

wire			dis_en;

assign en = (vga_x<E_X && vga_x>=S_X && vga_y<E_Y && vga_y>=S_Y);
assign addr_x = en ? (vga_x-S_X) : 0;
assign addr_y = en ? (vga_y-S_Y) : 0;
assign ram_addr = addr_y[11:4]*28 + addr_x[11:4];

assign en_its = (vga_x<E_X1 && vga_x>=S_X1 && vga_y<E_Y1 && vga_y>=S_Y1);
assign addr_its = en_its ? (vga_y-S_Y1)*132 + (vga_x-S_X1) : 0;

assign en_digit = (vga_x<E_X2 && vga_x>=S_X2 && vga_y<E_Y2 && vga_y>=S_Y2);
assign digit_addr = en_digit ? (vga_y-S_Y2)*60 + (vga_x-S_X2) : 0;

assign dis_en = (en_its&&(!q_its)) || (en_digit&&(!digit_q));
assign vga_rgb = en ? {ram_q, ram_q, ram_q} : dis_en ? 24'h0 : 24'hFFFFFF;

its u_its(
	.doa		(q_its),
	.addra		(addr_its),
	.clka		(clk),
	.rsta		(1'b0)
);

endmodule
