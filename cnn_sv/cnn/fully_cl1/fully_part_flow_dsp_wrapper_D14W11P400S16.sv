`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl1_fully_part_flow_dsp_wrapper_D14W11P400S16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit [10:0] i_weight[15:0],
    input  bit i_dw_valid,
    input  bit i_img_end,
    output bit signed [32:0] od_data[15:0],
    output bit od_data_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [2:0] sum_valid;
bit dw_valid[15:0];
bit img_start[15:0];
bit signed [13:0] sign_data;
bit signed [10:0] sign_weight[15:0];
bit dw_valid_0lat[15:0];
bit signed [33:0] pd_dsp_data[15:0];

fully_cl1_fully_part_flow_dsp_D14W11P400S16 u_dsp
(
    .clk                 (clk),
    .i_data              (sign_data),
    .i_data_vld          (dw_valid_0lat),
    .i_weight            (sign_weight),
    .i_weight_vld        (dw_valid_0lat),
    .i_mult_en           (dw_valid_0lat),
    .i_sum_en            (dw_valid),
    .i_start             (img_start),
    .od_data             (pd_dsp_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    dw_valid[0] <= i_dw_valid;
    for (int i=1; i<16; i++) begin
        dw_valid[i] <= dw_valid[i-1];
    end
end
always_ff @(posedge clk)
begin
    sum_valid[0] <= i_img_end&i_dw_valid;
    sum_valid[2:1] <= sum_valid[1:0];
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    img_start[0] <= 1;
    img_start[1] <= 0;
    img_start[2] <= 0;
    img_start[3] <= 0;
    img_start[4] <= 0;
    img_start[5] <= 0;
    img_start[6] <= 0;
    img_start[7] <= 0;
    img_start[8] <= 0;
    img_start[9] <= 0;
    img_start[10] <= 0;
    img_start[11] <= 0;
    img_start[12] <= 0;
    img_start[13] <= 0;
    img_start[14] <= 0;
    img_start[15] <= 0;
end
else begin
    if (dw_valid[0]) begin
        img_start[0] <= sum_valid[0];
    end
    for (int i=1; i<16; i++) begin
        img_start[i] <= img_start[i-1];
    end
end
end
assign sign_data = i_data;
always_comb
begin
    for (int i=0; i<16; i++) begin
        sign_weight[i] = i_weight[i];
    end
end
always_comb
begin
    dw_valid_0lat[0] = i_dw_valid;
    for (int i=1; i<16; i++) begin
        dw_valid_0lat[i] = dw_valid[i-1];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_data[i] = $signed(pd_dsp_data[i][32:0]);
    end
end
assign od_data_vld = sum_valid[2];

endmodule