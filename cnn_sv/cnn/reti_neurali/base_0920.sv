`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module reti_neurali_base_0920 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [15:0] i_minibatch,
    input  bit [4:0] i_rallentamente,
    input  bit i_modalita_studio,
    input  bit [15:0] i_class_num,
    input  bit i_class_num_vld,
    input  bit [7:0] i_mux_funzione,
    input  bit [31:0] i_pix,
    input  bit i_pix_vld,
    input  bit [31:0] i_peso,
    input  bit [15:0] i_peso_vld,
    output bit [31:0] od_peso,
    output bit od_peso_vld,
    input  bit [31:0] i_Y,
    input  bit i_Y_vld,
    input  bit [15:0] i_index,
    input  bit i_index_vld,
    input  bit i_rete_errori_read,
    output bit [15:0] od_rete_errori,
    output bit od_rete_errori_vld,
    input  bit i_tf_read,
    output bit [31:0] od_true_false,
    output bit od_tf_vld,
    output bit od_minib_completamento,
    output bit [6:0] od_profondita_attuale,
    output bit [15:0] od_strato_ultimo
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] in_weight;
bit in_weight_vld[2:0];
bit [10:0] pd_layer_weight[2:0];
bit pd_layer_weight_vld[2:0];
bit [13:0] array_i_data[0:0];
bit array_i_data_vld[0:0];
bit [13:0] pd_primario_0_data[3:0];
bit pd_primario_0_data_vld[3:0];
bit pd_primario_0_busy;
bit [13:0] pd_primario_0_backprop[0:0];
bit pd_primario_0_backprop_vld[0:0];
bit [5:0] pd_primario_0_errore;
bit [13:0] pd_pool_0_data[0:0];
bit pd_pool_0_valid[0:0];
bit [13:0] pd_pool_0_backprop[3:0];
bit pd_pool_0_backprop_vld[3:0];
bit [13:0] pd_primario_1_data[15:0];
bit pd_primario_1_data_vld[15:0];
bit pd_primario_1_busy;
bit [13:0] pd_primario_1_backprop[0:0];
bit pd_primario_1_backprop_vld[0:0];
bit [7:0] pd_primario_1_errore;
bit [13:0] pd_pool_1_data[0:0];
bit pd_pool_1_valid[0:0];
bit [13:0] pd_pool_1_backprop[15:0];
bit pd_pool_1_backprop_vld[15:0];
bit [13:0] pd_primario_2_data[0:0];
bit pd_primario_2_data_vld[0:0];
bit pd_primario_2_busy;
bit [13:0] pd_primario_2_backprop[0:0];
bit pd_primario_2_backprop_vld[0:0];
bit [4:0] pd_primario_2_errore;
bit [13:0] pd_ferrore_backprop[0:0];
bit pd_ferrore_backprop_vld[0:0];
bit [13:0] in_Y;
bit in_Y_vld;
bit pd_ferr_vero;
bit pd_ferr_falso;
bit pd_ferrore;
bit [10:0] pd_layerWei;
bit pd_layerWei_vld;
bit w_tf_enable[1:0];
bit [15:0] w_errori[5:0];

conv_v0_1_conv_layer_v2_W14W11W14L0U8C5C4C1C1I28P3N0M10N2R8R15 u_primario_0
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (array_i_data),
    .i_data_vld          (array_i_data_vld),
    .od_data             (pd_primario_0_data),
    .od_data_vld         (pd_primario_0_data_vld),
    .i_minibatch         (i_minibatch),
    .i_rallentamente     (i_rallentamente),
    .i_modalita          (i_modalita_studio),
    .i_aggiorntamento    (i_class_num_vld),
    .od_busy             (pd_primario_0_busy),
    .i_backprop          (pd_pool_0_backprop),
    .i_backprop_vld      (pd_pool_0_backprop_vld),
    .od_backprop         (pd_primario_0_backprop),
    .od_backprop_vld     (pd_primario_0_backprop_vld),
    .i_weight            (in_weight),
    .i_weight_vld        (in_weight_vld[0]),
    .od_weight           (pd_layer_weight[0]),
    .od_weight_vld       (pd_layer_weight_vld[0]),
    .od_error            (pd_primario_0_errore)
);
pool_v0_maxpool_v0_W14L0C4C1P2L24P3N0 u_pool_0
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (pd_primario_0_data),
    .i_valid             (pd_primario_0_data_vld),
    .od_data             (pd_pool_0_data),
    .od_valid            (pd_pool_0_valid),
    .i_backprop          (pd_primario_1_backprop),
    .i_backprop_vld      (pd_primario_1_backprop_vld),
    .od_backprop         (pd_pool_0_backprop),
    .od_backprop_vld     (pd_pool_0_backprop_vld)
);
conv_v2_conv_layer_W14W11W14L0U8C3C16C4C4I12P3N1M10N2R8R15 u_primario_1
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (pd_pool_0_data),
    .i_data_vld          (pd_pool_0_valid),
    .od_data             (pd_primario_1_data),
    .od_data_vld         (pd_primario_1_data_vld),
    .i_minibatch         (i_minibatch),
    .i_rallentamente     (i_rallentamente),
    .i_modalita          (i_modalita_studio),
    .i_aggiorntamento    (i_class_num_vld),
    .od_busy             (pd_primario_1_busy),
    .i_backprop          (pd_pool_1_backprop),
    .i_backprop_vld      (pd_pool_1_backprop_vld),
    .od_backprop         (pd_primario_1_backprop),
    .od_backprop_vld     (pd_primario_1_backprop_vld),
    .i_weight            (in_weight),
    .i_weight_vld        (in_weight_vld[1]),
    .od_weight           (pd_layer_weight[1]),
    .od_weight_vld       (pd_layer_weight_vld[1]),
    .od_errore           (pd_primario_1_errore)
);
pool_v0_maxpool_v0_W14L0C16C4P2L10P3N1 u_pool_1
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (pd_primario_1_data),
    .i_valid             (pd_primario_1_data_vld),
    .od_data             (pd_pool_1_data),
    .od_valid            (pd_pool_1_valid),
    .i_backprop          (pd_primario_2_backprop),
    .i_backprop_vld      (pd_primario_2_backprop_vld),
    .od_backprop         (pd_pool_1_backprop),
    .od_backprop_vld     (pd_pool_1_backprop_vld)
);
fully_cl3_fully_layer_W14W11W14L0U8P16P1P400P16Y16P3N2M10R8R15 u_primario_2
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (pd_pool_1_data),
    .i_data_vld          (pd_pool_1_valid),
    .od_z                (pd_primario_2_data),
    .od_z_vld            (pd_primario_2_data_vld),
    .i_minibatch         (i_minibatch),
    .i_rallentamente     (i_rallentamente),
    .i_modalita          (i_modalita_studio),
    .i_aggiorntamento    (i_class_num_vld),
    .od_busy             (pd_primario_2_busy),
    .i_backprop          (pd_ferrore_backprop),
    .i_backprop_vld      (pd_ferrore_backprop_vld),
    .od_backprop         (pd_primario_2_backprop),
    .od_backprop_vld     (pd_primario_2_backprop_vld),
    .i_weight            (in_weight),
    .i_weight_vld        (in_weight_vld[2]),
    .od_weight           (pd_layer_weight[2]),
    .od_weight_vld       (pd_layer_weight_vld[2]),
    .od_error            (pd_primario_2_errore)
);
ferrore_funzione_errore_W14L0C16S16R10 u_ferrore
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (pd_primario_2_data),
    .i_data_vld          (pd_primario_2_data_vld),
    .od_backprop         (pd_ferrore_backprop),
    .od_backprop_vld     (pd_ferrore_backprop_vld),
    .i_Y                 (in_Y),
    .i_Y_vld             (in_Y_vld),
    .i_index             (i_index),
    .i_index_vld         (i_index_vld),
    .i_class_num         (i_class_num),
    .i_class_num_vld     (i_class_num_vld),
    .i_mux_funzione      (i_mux_funzione),
    .od_vero             (pd_ferr_vero),
    .od_falso            (pd_ferr_falso),
    .od_error            (pd_ferrore)
);
separ_union_mux_std_unsign_W11N3 u_layer_weight
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (pd_layer_weight),
    .i_data_vld          (pd_layer_weight_vld),
    .od_data             (pd_layerWei),
    .od_data_vld         (pd_layerWei_vld)
);
regs_mem_vldcount_read_flash_W32N2 u_true_false
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_count_en          (w_tf_enable),
    .i_read              (i_tf_read),
    .od_data             (od_true_false),
    .od_valid            (od_tf_vld)
);
regs_mem_autowr_read_flash_W16N6 u_statistiche
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (w_errori),
    .i_read              (i_rete_errori_read),
    .od_data             (od_rete_errori),
    .od_valid            (od_rete_errori_vld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign in_weight = i_peso;
always_comb
begin
    for (int i=0; i<3; i++) begin
        in_weight_vld[i] = i_peso_vld[i];
    end
end
assign array_i_data[0] = i_pix;
assign array_i_data_vld[0] = i_pix_vld;
assign in_Y = i_Y;
assign in_Y_vld = i_Y_vld;
assign w_tf_enable[0] = pd_ferr_vero;
assign w_tf_enable[1] = pd_ferr_falso;
assign w_errori[0] = pd_primario_0_errore;
assign w_errori[1] = pd_primario_1_errore;
assign w_errori[2] = pd_primario_2_errore;
assign w_errori[3] = pd_ferrore;
assign w_errori[4] = 0;
assign w_errori[5] = 0;
assign od_peso = {pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei[10],pd_layerWei};
assign od_peso_vld = pd_layerWei_vld;
assign od_minib_completamento = pd_primario_0_busy;
assign od_profondita_attuale = 3;
assign od_strato_ultimo = 16;

endmodule