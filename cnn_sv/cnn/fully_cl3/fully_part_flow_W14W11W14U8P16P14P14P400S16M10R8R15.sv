`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_fully_part_flow_W14W11W14U8P16P14P14P400S16M10R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_data_vld,
    input  bit i_img_end,
    output bit signed [32:0] od_data,
    output bit od_data_vld,
    output bit od_img_end,
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    input  bit i_controllo_weight_reading,
    input  bit [13:0] i_controllo_data,
    input  bit i_controllo_data_vld,
    input  bit [13:0] i_backprop,
    input  bit i_backprop_start,
    output bit signed [27:0] od_z_backprop,
    output bit od_z_backprop_vld,
    output bit od_z_backprop_img_end,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld[15:0],
    input  bit i_weight_start,
    output bit [10:0] od_weight,
    output bit od_weight_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit const_controllo_weight_reading = 0;
bit [13:0] data;
bit data_vld[14:0];
bit modalita;
bit img_end;
bit [3:0] count;
bit count_en;
bit count_end;
bit p_controllo_weight_reading[15:0];
bit data_vld_0lat[15:0];
bit [10:0] pd_weight[15:0];
bit pd_weight_vld[15:0];
bit pd_reading[15:0];
bit signed [32:0] pd_wrapper_data[15:0];
bit pd_wrapper_data_vld;
bit w_controllo_data_vld;
bit [10:0] pd_dwcalc_weight[15:0];
bit pd_dwcalc_weight_vld[15:0];
bit pd_dwcalc_traboc;
bit valid_dunion;

shift_uwire_multi_W1L16R0 opensh_weight_reading
(
    .clk                 (clk),
    .i_data              (i_controllo_weight_reading),
    .o_data              (p_controllo_weight_reading)
);

genvar i;
generate
for (i=0;i<16;i++) begin : gen__fully_cl0_fully_weight_memory_W11L400
    fully_cl0_fully_weight_memory_W11L400 u_weight_mem
    (
        .clk                 (clk),
        .i_rst               (i_rst),
        .i_weight            (i_weight),
        .i_weight_vld        (i_weight_vld[i]),
        .i_weight_start      (i_weight_start),
        .i_weight_mod        (pd_dwcalc_weight[i]),
        .i_weight_mod_vld    (pd_dwcalc_weight_vld[i]),
        .i_read              (data_vld_0lat[i]),
        .i_read2update       (p_controllo_weight_reading[i]),
        .od_weight           (pd_weight[i]),
        .od_load             (pd_weight_vld[i]),
        .od_reading          (pd_reading[i])
    );
end
endgenerate
fully_cl1_fully_part_flow_dsp_wrapper_D14W11P400S16 u_diretto_dsp_wrapper
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (data),
    .i_weight            (pd_weight),
    .i_dw_valid          (pd_reading[0]),
    .i_img_end           (img_end),
    .od_data             (pd_wrapper_data),
    .od_data_vld         (pd_wrapper_data_vld)
);
fully_cl1_fully_z_backprop_dsp_wrapper_D14W11P400S16 u_zback_dsp_wrapper
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_backprop          (i_backprop),
    .i_backprop_start    (i_backprop_start),
    .i_weight            (pd_weight),
    .i_weight0_vld       (i_controllo_data_vld),
    .od_data             (od_z_backprop),
    .od_data_vld         (od_z_backprop_vld),
    .od_data_end         (od_z_backprop_img_end)
);
fully_cl3_fully_dw_calcolatrice_W14W11W14U8P16P400S16M10R8R15 u_dw_calcolatrice
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_minibatch_min1    (i_minibatch_min1),
    .i_rallentamente     (i_rallentamente),
    .i_aggiorntamento    (i_aggiorntamento),
    .i_data              (i_controllo_data),
    .i_data_vld          (w_controllo_data_vld),
    .i_gradiente         (i_backprop),
    .i_grad_start        (i_backprop_start),
    .i_weight            (i_weight),
    .i_weight_vld        (i_weight_vld),
    .od_weight           (pd_dwcalc_weight),
    .od_weight_vld       (pd_dwcalc_weight_vld),
    .od_traboc           (pd_dwcalc_traboc)
);
separ_union_mux_int_vld_sign_W33N16 u_data_union
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (pd_wrapper_data),
    .i_valid             (valid_dunion),
    .i_mux               (count),
    .od_data             (od_data),
    .od_valid            (od_data_vld)
);
separ_union_mux_std_unsign_W11N16 u_weight_union
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (pd_weight[0+15:0]),
    .i_data_vld          (pd_weight_vld[0+15:0]),
    .od_data             (od_weight),
    .od_data_vld         (od_weight_vld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        modalita <= i_modalita;
    end
end
always_ff @(posedge clk)
begin
    if (i_data_vld) begin
        data <= i_data;
    end
end
always_ff @(posedge clk)
begin
    if (i_data_vld) begin
        img_end <= i_img_end;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_vld[0] <= 0;
    data_vld[1] <= 0;
    data_vld[2] <= 0;
    data_vld[3] <= 0;
    data_vld[4] <= 0;
    data_vld[5] <= 0;
    data_vld[6] <= 0;
    data_vld[7] <= 0;
    data_vld[8] <= 0;
    data_vld[9] <= 0;
    data_vld[10] <= 0;
    data_vld[11] <= 0;
    data_vld[12] <= 0;
    data_vld[13] <= 0;
    data_vld[14] <= 0;
end
else begin
    data_vld[0] <= i_data_vld;
    for (int i=1; i<15; i++) begin
        data_vld[i] <= data_vld[i-1];
    end
end
end
always_comb
begin
    data_vld_0lat[0] = i_data_vld;
    for (int i=1; i<16; i++) begin
        data_vld_0lat[i] = data_vld[i-1];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    count_en <= 0;
end
else begin
    if (pd_wrapper_data_vld) begin
        count_en <= 1;
    end
    else if (count_en) begin
        count_en <= ~(&count);
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    count <= 0;
end
else begin
    if (pd_wrapper_data_vld) begin
        count <= 1;
    end
    else if (count_en) begin
        count <= count+1;
    end
end
end
always_ff @(posedge clk)
begin
    count_end <= &count;
end
assign w_controllo_data_vld = i_controllo_data_vld&(!modalita);
assign valid_dunion = pd_wrapper_data_vld|count_en;
assign od_img_end = count_end;

endmodule