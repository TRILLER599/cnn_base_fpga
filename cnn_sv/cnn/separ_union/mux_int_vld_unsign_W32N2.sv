`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_int_vld_unsign_W32N2 (
    input  bit clk,
    input  bit i_rst,
    input  bit [31:0] i_data[1:0],
    input  bit i_valid,
    input  bit i_mux,
    output bit [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit valid;
bit [31:0] data0;
bit w_mux0;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= i_valid;
end
end
assign w_mux0 = i_mux;
always_ff @(posedge clk)
begin
    if (w_mux0==0) begin
        data0 <= i_data[0];
    end
    else begin
        data0 <= i_data[1];
    end
end
assign od_data = data0;
assign od_valid = valid;

endmodule