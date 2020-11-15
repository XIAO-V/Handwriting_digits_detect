/////////////////////////////////////////////////////////////
////    RESET process
/////////////////////////////////////////////////////////////

module sys_rst_n(
	input					clk,
	input					rst_n,
	output	reg				rst_syn
);

reg rst_syn1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rst_syn1 <= 1'b0;
    else
        rst_syn1 <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rst_syn <= 1'b0;
    else
        rst_syn <= rst_syn1;
end

endmodule