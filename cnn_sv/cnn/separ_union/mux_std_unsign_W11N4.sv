`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_std_unsign_W11N4 (
    input  bit clk,
    input  bit i_rst,
    input  bit [10:0] i_data[3:0],
    input  bit i_data_vld[3:0],
    output bit [10:0] od_data,
    output bit od_data_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] mux0[1:0];
bit mux0_vld[1:0];
bit [10:0] mux1;
bit mux1_vld;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        mux0[i] <= (i_data_vld[i*2+1])?i_data[i*2+1]:i_data[i*2];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux0_vld[0] <= 0;
    mux0_vld[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        mux0_vld[i] <= i_data_vld[i*2]|i_data_vld[i*2+1];
    end
end
end
always_ff @(posedge clk)
begin
    mux1 <= (mux0_vld[1])?mux0[1]:mux0[0];
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux1_vld <= 0;
end
else begin
    mux1_vld <= mux0_vld[0]|mux0_vld[1];
end
end
assign od_data = mux1;
assign od_data_vld = mux1_vld;

endmodule