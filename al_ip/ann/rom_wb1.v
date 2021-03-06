/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	D:/Database/FPGA/Anlogic/Handwriting_digits_detect/al_ip/ann/rom_wb1.v
 ** Date	:	2020 11 12
 ** TD version	:	4.6.18154
\************************************************************/

`timescale 1ns / 1ps

module rom_wb1 ( doa, addra, clka, rsta );

	output [449:0] doa;

	input  [9:0] addra;
	input  clka;
	input  rsta;




	EG_LOGIC_BRAM #( .DATA_WIDTH_A(450),
				.ADDR_WIDTH_A(10),
				.DATA_DEPTH_A(785),
				.DATA_WIDTH_B(450),
				.ADDR_WIDTH_B(10),
				.DATA_DEPTH_B(785),
				.MODE("SP"),
				.REGMODE_A("NOREG"),
				.RESETMODE("SYNC"),
				.IMPLEMENT("9K"),
				.DEBUGGABLE("NO"),
				.PACKABLE("NO"),
				.INIT_FILE("mif/WB1.mif"),
				.FILL_ALL("NONE"))
			inst(
				.dia({450{1'b0}}),
				.dib({450{1'b0}}),
				.addra(addra),
				.addrb({10{1'b0}}),
				.cea(1'b1),
				.ceb(1'b0),
				.ocea(1'b0),
				.oceb(1'b0),
				.clka(clka),
				.clkb(1'b0),
				.wea(1'b0),
				.web(1'b0),
				.bea(1'b0),
				.beb(1'b0),
				.rsta(rsta),
				.rstb(1'b0),
				.doa(doa),
				.dob());


endmodule