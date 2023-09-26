`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_max_std_sign_extu_W14N1E4 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [13:0] i_data[0:0],
    input  bit i_valid[0:0],
    input  bit [3:0] i_ext[0:0],
    output bit signed [13:0] od_data,
    output bit od_index,
    output bit od_valid,
    output bit [3:0] od_extend
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data0;
bit index0;
bit valid0;
bit [3:0] ext0;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    data0 <= i_data[0];
end
always_ff @(posedge clk)
begin
    index0 <= 0;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid0 <= 0;
end
else begin
    valid0 <= i_valid[0];
end
end
always_ff @(posedge clk)
begin
    ext0 <= i_ext[0];
end
assign od_data = data0;
assign od_index = index0;
assign od_valid = valid0;
assign od_extend = ext0;

endmodule