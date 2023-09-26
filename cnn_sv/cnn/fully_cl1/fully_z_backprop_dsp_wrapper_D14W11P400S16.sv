`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl1_fully_z_backprop_dsp_wrapper_D14W11P400S16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_backprop,
    input  bit i_backprop_start,
    input  bit [10:0] i_weight[15:0],
    input  bit i_weight0_vld,
    output bit signed [27:0] od_data,
    output bit od_data_vld,
    output bit od_data_end
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit last_vld;
bit end_vld;
bit [8:0] count_prev_stream;
bit p_backprop_start[15:0];
bit p_weight_vld[15:0];
bit signed [13:0] sign_backprop;
bit signed [10:0] sign_weight[15:0];
bit signed [28:0] pd_dsp_data;
bit pd_weight_vld;

shift_uwire_multi_W1L16R0 u_opensh_backprop_start
(
    .clk                 (clk),
    .i_data              (i_backprop_start),
    .o_data              (p_backprop_start)
);
shift_uwire_multi_W1L16R1 u_opensh_weight_vld
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (i_weight0_vld),
    .o_data              (p_weight_vld)
);
fully_cl1_fully_z_backprop_dsp_D14W11S16 u_dsp
(
    .clk                 (clk),
    .i_data              (sign_backprop),
    .i_data_start        (p_backprop_start),
    .i_weight            (sign_weight),
    .i_weight_vld        (p_weight_vld),
    .od_data             (pd_dsp_data)
);
base_construct_shift_reg_rst_L17W1 u_res_vld
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (i_weight0_vld),
    .od_data             (pd_weight_vld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign sign_backprop = i_backprop;
always_comb
begin
    for (int i=0; i<16; i++) begin
        sign_weight[i] = i_weight[i];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    last_vld <= 0;
end
else begin
    last_vld <= pd_weight_vld;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    count_prev_stream <= 0;
end
else begin
    if (pd_weight_vld) begin
        count_prev_stream <= (count_prev_stream==400-1)?0:count_prev_stream+1;
    end
end
end
always_ff @(posedge clk)
begin
    end_vld <= pd_weight_vld&(count_prev_stream==400-1);
end
assign od_data = $signed(pd_dsp_data[27:0]);
assign od_data_vld = last_vld;
assign od_data_end = end_vld;

endmodule