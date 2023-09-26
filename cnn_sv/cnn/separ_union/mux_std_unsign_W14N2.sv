`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_std_unsign_W14N2 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[1:0],
    input  bit i_data_vld[1:0],
    output bit [13:0] od_data,
    output bit od_data_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] mux0;
bit mux0_vld;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    mux0 <= (i_data_vld[1])?i_data[1]:i_data[0];
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux0_vld <= 0;
end
else begin
    mux0_vld <= i_data_vld[0]|i_data_vld[1];
end
end
assign od_data = mux0;
assign od_data_vld = mux0_vld;

endmodule