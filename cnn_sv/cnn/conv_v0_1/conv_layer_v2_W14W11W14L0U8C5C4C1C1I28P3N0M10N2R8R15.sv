`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_conv_layer_v2_W14W11W14L0U8C5C4C1C1I28P3N0M10N2R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_data[3:0],
    output bit od_data_vld[3:0],
    input  bit [15:0] i_minibatch,
    input  bit [4:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    output bit od_busy,
    input  bit [13:0] i_backprop[3:0],
    input  bit i_backprop_vld[3:0],
    output bit [13:0] od_backprop[0:0],
    output bit od_backprop_vld[0:0],
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit [5:0] od_error
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit pd_dzFin_errore = 0;
bit [9:0] minibatch_min1;
bit [3:0] rallentamente;
bit modalita;
bit aggiorntamento;
bit dWeight_vld_1d;
bit busy;
bit busy_errore;
bit [10:0] weight[3:0];
bit weight_vld[3:0];
bit [4:0] count_peso_wr;
bit [3:0] num_pwr_std;
bit errore_filtr;
bit errore_dw;
bit [13:0] pd_bsm_data[4:0];
bit pd_bsm_valid[0:0];
bit pd_bsm_str_end[0:0];
bit [10:0] pd_yWeight[3:0];
bit pd_yWeight_vld[3:0];
bit pd_errore_filtr[3:0];
bit pd_errore_dw[3:0];
bit signed [28:0] pd_yadro_backprop[3:0];
bit pd_yadro_backprop_vld[3:0];
bit pd_yadro_dWeight_vld[3:0];
bit p_errore_filtr;
bit p_errore_dw;
bit pd_controllo_z_read[0:0];
bit pd_controllo_z_vld;
bit pd_controllo_grad_read[3:0];
bit pd_controllo_calc_prec[3:0];
bit [13:0] pd_zbuf_data[4:0];
bit pd_zbuf_errore;
bit [13:0] pd_gbuf_data[3:0];
bit pd_gbuf_empty;
bit pd_gbuf_errore;
bit rst__pip;
bit rst__l;

conv_v0_1_busmaker_W14C5C1L28L28 u_busmaker
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .od_data             (pd_bsm_data),
    .od_data_vld         (pd_bsm_valid),
    .od_str_end          (pd_bsm_str_end)
);

genvar i;
generate
for (i=0;i<4;i++) begin : gen__conv_v0_1_yadro_v2_W14W11W14P14P14U8C5P1I24N0M10N2R8R15
    conv_v0_1_yadro_v2_W14W11W14P14P14U8C5P1I24N0M10N2R8R15 u_yadro
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_data              (pd_bsm_data),
        .i_data_vld          (pd_bsm_valid),
        .i_str_end           (pd_bsm_str_end),
        .od_diretto          (od_data[i]),
        .od_diretto_vld      (od_data_vld[i]),
        .i_weight            (weight[i]),
        .i_weight_vld        (weight_vld[i]),
        .od_weight           (pd_yWeight[i]),
        .od_weight_vld       (pd_yWeight_vld[i]),
        .i_minibatch_min1    (minibatch_min1),
        .i_rallentamente     (rallentamente),
        .i_modalita          (modalita),
        .i_aggiorntamento    (aggiorntamento),
        .i_zprev             (pd_zbuf_data),
        .i_zprev_vld         (pd_controllo_z_vld),
        .i_gradient          (pd_gbuf_data[i]),
        .i_gradient_read     (pd_controllo_grad_read[i]),
        .i_calc_prec         (pd_controllo_calc_prec[i]),
        .od_backprop         (pd_yadro_backprop[i*1:i*1]),
        .od_backprop_vld     (pd_yadro_backprop_vld[i]),
        .od_dWeight_vld      (pd_yadro_dWeight_vld[i]),
        .od_errore_filtr     (pd_errore_filtr[i]),
        .od_errore_dw        (pd_errore_dw[i])
    );
end
endgenerate
separ_union_mux_std_unsign_W11N4 u_peso_unione
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_yWeight),
    .i_data_vld          (pd_yWeight_vld),
    .od_data             (od_weight),
    .od_data_vld         (od_weight_vld)
);
base_construct_unari_operator_W1L4or u_errore_filtr
(
    .clk                 (clk),
    .i_data              (pd_errore_dw),
    .o_data              (p_errore_filtr)
);
base_construct_unari_operator_W1L4or u_errore_dw
(
    .clk                 (clk),
    .i_data              (pd_errore_dw),
    .o_data              (p_errore_dw)
);
conv_v0_1_conv_backprop_controllo_C4P1C5I24O11 u_backprop_controllo
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_gradient_wr       (i_backprop_vld[0]),
    .od_z_read           (pd_controllo_z_read),
    .od_z_vld            (pd_controllo_z_vld),
    .od_grad_read        (pd_controllo_grad_read),
    .od_calc_prec        (pd_controllo_calc_prec)
);
conv_v0_1_conv_z_bufer_W14C5P1I28P3N0 u_z_buffer
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_valid             (i_data_vld),
    .i_read              (pd_controllo_z_read),
    .od_data             (pd_zbuf_data),
    .od_errore           (pd_zbuf_errore)
);
conv_v0_1_gradiente_buffer_W14C4O11 u_gradiente_buffer
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (i_backprop),
    .i_data_vld          (i_backprop_vld),
    .i_read              (pd_controllo_grad_read),
    .od_data             (pd_gbuf_data),
    .od_empty            (pd_gbuf_empty),
    .od_errore           (pd_gbuf_errore)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk)
begin
    if (i_aggiorntamento&~busy) begin
        minibatch_min1 <= i_minibatch-1;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento&~busy) begin
        rallentamente <= (i_rallentamente>15)?15:i_rallentamente;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento&~busy) begin
        modalita <= i_modalita;
    end
end
always_ff @(posedge clk)
begin
    aggiorntamento <= (i_aggiorntamento&!busy);
end
always_ff @(posedge clk)
begin
    dWeight_vld_1d <= pd_yadro_dWeight_vld[0];
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    busy <= 0;
end
else begin
    if (i_data_vld[0]) begin
        busy <= 1;
    end
    else begin
        if (pd_gbuf_empty&&(!pd_yadro_dWeight_vld[0])&&dWeight_vld_1d) begin
            busy <= 0;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    busy_errore <= 0;
end
else begin
    busy_errore <= (busy&i_aggiorntamento);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_peso_wr <= 0;
end
else begin
    if (i_weight_vld) begin
        count_peso_wr <= (count_peso_wr==25-1)?0:count_peso_wr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    num_pwr_std <= 1;
end
else begin
    if (i_weight_vld) begin
        if (count_peso_wr==(25-1)) begin
            num_pwr_std <= (num_pwr_std<<<1)|num_pwr_std[3];
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_vld[0] <= 0;
    weight_vld[1] <= 0;
    weight_vld[2] <= 0;
    weight_vld[3] <= 0;
end
else begin
    for (int i=0; i<4; i++) begin
        weight_vld[i] <= i_weight_vld&num_pwr_std[i];
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        weight[i] <= i_weight;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore_filtr <= 0;
end
else begin
    errore_filtr <= p_errore_filtr;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore_dw <= 0;
end
else begin
    errore_dw <= p_errore_dw;
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop[i] = 0;
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop_vld[i] = 0;
    end
end
assign od_busy = busy;
assign od_error = {busy_errore,pd_zbuf_errore,pd_gbuf_errore,pd_dzFin_errore,errore_dw,errore_filtr};

endmodule