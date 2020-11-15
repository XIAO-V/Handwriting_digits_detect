// Verilog netlist created by TD v4.6.18154
// Thu Nov 12 15:39:58 2020

`timescale 1ns / 1ps
module ram_out1  // al_ip/ann/ram_out1.v(14)
  (
  addra,
  addrb,
  cea,
  clka,
  clkb,
  dia,
  dob
  );

  input [5:0] addra;  // al_ip/ann/ram_out1.v(23)
  input [5:0] addrb;  // al_ip/ann/ram_out1.v(24)
  input cea;  // al_ip/ann/ram_out1.v(25)
  input clka;  // al_ip/ann/ram_out1.v(26)
  input clkb;  // al_ip/ann/ram_out1.v(27)
  input [8:0] dia;  // al_ip/ann/ram_out1.v(22)
  output [8:0] dob;  // al_ip/ann/ram_out1.v(19)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=50;width=9;num_section=1;width_per_section=9;section_size=9;working_depth=1024;working_width=9;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEBMUX("1"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("1"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("9"),
    .DATA_WIDTH_B("9"),
    .MODE("DP8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTAMUX("0"),
    .RSTBMUX("0"),
    .WEAMUX("1"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_50x9_sub_000000_000 (
    .addra({4'b0000,addra,3'b111}),
    .addrb({4'b0000,addrb,3'b111}),
    .cea(cea),
    .clka(clka),
    .clkb(clkb),
    .dia(dia),
    .dob(dob));

endmodule 

