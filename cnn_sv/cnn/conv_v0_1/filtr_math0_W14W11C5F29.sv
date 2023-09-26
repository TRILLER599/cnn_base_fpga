`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_filtr_math0_W14W11C5F29 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[24:0],
    input  bit i_data_vld,
    input  bit [10:0] i_weight[24:0],
    output bit signed [28:0] od_z,
    output bit od_z_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [6:0] data_vld;
bit signed [13:0] data_sign[24:0];
bit signed [10:0] weight_sign[24:0];
bit signed [28:0] pd_sum;
bit signed [24:0] pd_dsp_sum[12:0];

genvar i;
generate
for (i=0;i<12;i++) begin : gen__conv_v0_1_filtr_math0_dsp_W14W11
    conv_v0_1_filtr_math0_dsp_W14W11 u_filtr_dsp
    (
        .clk                 (clk),
        .i_data              (data_sign[i*2+1:i*2]),
        .i_data_vld          (i_data_vld),
        .i_weight            (weight_sign[i*2+1:i*2]),
        .i_weight_vld        (i_data_vld),
        .od_data             (pd_dsp_sum[i])
    );
end
endgenerate
conv_v0_1_filtr_math0_dsp_half_W14W11 u_filtr_dsp_half
(
    .clk                 (clk),
    .i_data              (data_sign[24]),
    .i_data_vld          (i_data_vld),
    .i_weight            (weight_sign[24]),
    .i_weight_vld        (i_data_vld),
    .od_data             (pd_dsp_sum[12])
);
arithmetic_sum_simple_sign_W25N13 u_sum
(
    .clk                 (clk),
    .i_data              (pd_dsp_sum),
    .od_data             (pd_sum)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_vld <= 0;
end
else begin
    data_vld <= {data_vld[5:0],i_data_vld};
end
end
always_comb
begin
    for (int i=0; i<25; i++) begin
        data_sign[i] = i_data[i];
    end
end
always_comb
begin
    for (int i=0; i<25; i++) begin
        weight_sign[i] = i_weight[i];
    end
end
assign od_z = $signed(pd_sum[28:0]);
assign od_z_vld = data_vld[6];

endmodule