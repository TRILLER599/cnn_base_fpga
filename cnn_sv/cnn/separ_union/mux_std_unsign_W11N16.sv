`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_std_unsign_W11N16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [10:0] i_data[15:0],
    input  bit i_data_vld[15:0],
    output bit [10:0] od_data,
    output bit od_data_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] mux0[7:0];
bit mux0_vld[7:0];
bit [10:0] mux1[3:0];
bit mux1_vld[3:0];
bit [10:0] mux2[1:0];
bit mux2_vld[1:0];
bit [10:0] mux3;
bit mux3_vld;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<8; i++) begin
        mux0[i] <= (i_data_vld[i*2+1])?i_data[i*2+1]:i_data[i*2];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux0_vld[0] <= 0;
    mux0_vld[1] <= 0;
    mux0_vld[2] <= 0;
    mux0_vld[3] <= 0;
    mux0_vld[4] <= 0;
    mux0_vld[5] <= 0;
    mux0_vld[6] <= 0;
    mux0_vld[7] <= 0;
end
else begin
    for (int i=0; i<8; i++) begin
        mux0_vld[i] <= i_data_vld[i*2]|i_data_vld[i*2+1];
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        mux1[i] <= (mux0_vld[i*2+1])?mux0[i*2+1]:mux0[i*2];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux1_vld[0] <= 0;
    mux1_vld[1] <= 0;
    mux1_vld[2] <= 0;
    mux1_vld[3] <= 0;
end
else begin
    for (int i=0; i<4; i++) begin
        mux1_vld[i] <= mux0_vld[i*2]|mux0_vld[i*2+1];
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        mux2[i] <= (mux1_vld[i*2+1])?mux1[i*2+1]:mux1[i*2];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux2_vld[0] <= 0;
    mux2_vld[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        mux2_vld[i] <= mux1_vld[i*2]|mux1_vld[i*2+1];
    end
end
end
always_ff @(posedge clk)
begin
    mux3 <= (mux2_vld[1])?mux2[1]:mux2[0];
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux3_vld <= 0;
end
else begin
    mux3_vld <= mux2_vld[0]|mux2_vld[1];
end
end
assign od_data = mux3;
assign od_data_vld = mux3_vld;

endmodule