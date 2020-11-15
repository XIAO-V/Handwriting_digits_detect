/**********************
* Project: Handwriting digits detect
* Version: V1.0
* Date   : 2020/11/01
* By     : xiao-v
**********************/

module Handwriting_digits_detect(
	input	wire		clk_24m,
	
	// uart
	input	wire		rx,
	output	wire		tx,
	
	// vga
	output	wire		vga_clk,
	output	wire		vga_hs,
	output	wire		vga_vs,
	output	wire [23:0]	vga_rgb,
	
	// key
	input	wire [4:0]	key,
	
	// led
	output	wire [15:0]	led
);

wire				clk;
wire				rst_n;
wire	[3:0]		key_pulse;
wire				start;
wire				stop;
wire				en;
wire	[3:0]		result;

pll u_pll(
	.refclk			(clk_24m),
	.reset			(1'b0),
	.clk0_out		(clk),
	.clk1_out		()
);

sys_rst_n u_rst(
	.clk			(clk),
	.rst_n			(key[2]),
	.rst_syn		(rst_n)
);

wire	[23:0]		lcd_rgb;
wire	[11:0]		lcd_x;
wire	[11:0]		lcd_y;
wire	[9:0]		rd_addr;
wire	[7:0]		rd_q;
wire	[9:0]		img_addr;
wire	[7:0]		img_q;
wire	[12:0]		digit_addr;
wire				digit_q;

Driver u_vga(
	.clk			(clk),
	.rst_n			(rst_n),
	.lcd_data		(lcd_rgb),
	
	//lcd interface
	.lcd_dclk		(vga_clk),
	.lcd_hs			(vga_hs),
	.lcd_vs			(vga_vs),
	.lcd_en			(),
	.lcd_rgb		(vga_rgb),

	//user interface
	.lcd_xpos		(lcd_x),
	.lcd_ypos		(lcd_y)
);

display u_disp(
	/* top */
	 .clk			(clk),
	 .rst_n			(rst_n),
	/* ram */
	.ram_q			(rd_q),
	.ram_addr		(rd_addr),
	.digit_q		(digit_q),
	.digit_addr		(digit_addr),
	/* vga */
	.vga_x			(lcd_x),
	.vga_y			(lcd_y),
	.vga_rgb		(lcd_rgb)
);

wire	[9:0]		wr_addr;
wire				wr_en;
wire	[7:0]		wr_q;

key #(
	.N				(4),
	.CNT_20MS		(19'd300000)
)u_key(
	.clk			(clk),
	.rst_n			(rst_n),
	// key
	.key			({key[4:3],key[1:0]}),
	.key_pulse		(key_pulse)
); 

rx_ctrl u_rx_ctrl(
	/* top */
	.clk			(clk),
	.rst_n			(rst_n),
	.rx				(rx),
	.start			(start),
	.en				(en),
	/* key */
	.key			(key_pulse[0]),
	/* ram */
	.ram_q			(wr_q),
	.ram_addr		(wr_addr),
	.ram_en			(wr_en)
);

ram u_ram( 
	.dia			(wr_q),
	.addra			(wr_addr),
	.cea			(wr_en),
	.clka			(clk),
	.dob			(rd_q),
	.addrb			(rd_addr),
	.clkb			(clk)
);

ram_img u_ram_img( 
	.dia			(wr_q),
	.addra			(wr_addr),
	.cea			(wr_en),
	.clka			(clk),
	.dob			(img_q),
	.addrb			(img_addr),
	.clkb			(clk)
);

fc_net u_net(
	.clk			(clk),
	.rst_n			(rst_n),
	.start			(start),
	.stop			(stop),
	.en				(en),
	.result			(result),
	.img_q			(img_q),
	.img_addr		(img_addr)
);

digit u_digit(
	.clk			(clk),
	.rst_n			(rst_n),
	.stop			(stop),
	.result			(result),
	.key			(key_pulse[0]),
	.addr			(digit_addr),
	.num			(digit_q),
	.led			(led)
);

assign tx = 1'b1;

endmodule
