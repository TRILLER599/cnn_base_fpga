`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_combining_features_F29P1R8W14 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [28:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_z,
    output bit od_z_vld,
    output bit od_error
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit data_vld;
bit [13:0] data;
bit error;
bit signed [14:0] w_data_arrot;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign w_data_arrot = $signed(i_data[0][28:7])+1;
always_ff @(posedge clk)
begin
    data <= w_data_arrot[14:1];
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_vld <= 0;
end
else begin
    data_vld <= i_data_vld[0];
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    error <= 0;
end
else begin
    error <= (error)?1:~(!i_data[0][28:21]|(&i_data[0][28:21]));
end
end
assign od_z = data;
assign od_z_vld = data_vld;
assign od_error = error;

endmodule