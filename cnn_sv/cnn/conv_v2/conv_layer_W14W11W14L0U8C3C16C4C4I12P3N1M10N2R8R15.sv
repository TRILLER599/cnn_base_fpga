`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_conv_layer_W14W11W14L0U8C3C16C4C4I12P3N1M10N2R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_data[15:0],
    output bit od_data_vld[15:0],
    input  bit [15:0] i_minibatch,
    input  bit [4:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    output bit od_busy,
    input  bit [13:0] i_backprop[15:0],
    input  bit i_backprop_vld[15:0],
    output bit [13:0] od_backprop[0:0],
    output bit od_backprop_vld[0:0],
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit [7:0] od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [9:0] minibatch_min1;
bit [3:0] rallentamente;
bit modalita;
bit aggiorntamento;
bit busy;
bit busy_errore;
bit [1:0] dw_counter;
bit gradient_fifo_ovrf;
bit img_fifo_ovrf;
bit w_dw_ultimo;
bit pd_weight_enb_l2[15:0];
bit pd_valid_diretto_l5[15:0];
bit p_gradient_enb_l0;
bit pd_gradient_vld_l5[15:0];
bit pd_imgdir_enb_l2;
bit pd_imgdir_vld_l4[15:0];
bit pd_controllo_errore;
bit [10:0] pd_uPC_peso_scarico;
bit pd_uPC_peso_scarico_vld;
bit [10:0] pd_uPC_peso_l5[143:0];
bit pd_uPC_errore;
bit [13:0] pd_busmaker_data_l5[8:0];
bit pd_filtr_errore;
bit [13:0] pd_filtr_data[15:0];
bit pd_filtr_data_vld[15:0];
bit pd_gradient_enb_l1;
bit [13:0] pd_dz_busmaker_gradient_l4[143:0];
bit [13:0] pd_dz_busmaker_gradient_l5[143:0];
bit [13:0] pd_fifo_data[15:0];
bit pd_fifo_valid;
bit pd_fifo_empty;
bit pd_fifo_wr_ready;
bit pd_dzCalc_errore;
bit [13:0] pd_ImgDirBuff_data_l4[0:0];
bit pd_ImgDirBuff_valid;
bit pd_ImgDirBuff_empty;
bit pd_ImgDirBuff_wr_ready;
bit [10:0] pd_dwCalc_weight[143:0];
bit pd_dwCalc_weight_vld[15:0];
bit pd_dwCalc_errore;
bit rst__pip;
bit rst__l;

conv_v2_controllo_generale_C3C16S1C4I12S16O9M10 u_controllo_generale
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_valid             (i_data_vld[0]),
    .i_gradient_vld      (i_backprop_vld[0]),
    .i_minibatch_min1    (minibatch_min1),
    .i_modalita          (modalita),
    .od_weight_enb_l2    (pd_weight_enb_l2),
    .od_valid_diretto_l5 (pd_valid_diretto_l5),
    .o_gradient_enb_l0   (p_gradient_enb_l0),
    .od_gradient_vld_l5  (pd_gradient_vld_l5),
    .od_imgdir_enb_l2    (pd_imgdir_enb_l2),
    .od_imgdir_vld_l4    (pd_imgdir_vld_l4),
    .od_errore           (pd_controllo_errore)
);
conv_v2_deposito_pesi_W11C9C16S1C4 u_Pesi_Corti
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_peso_carico       (i_weight),
    .i_caricamento       (i_weight_vld),
    .od_peso_scarico     (pd_uPC_peso_scarico),
    .od_scaricamento     (pd_uPC_peso_scarico_vld),
    .i_enb_calcolo       (pd_weight_enb_l2),
    .od_peso_calcolo_l3  (pd_uPC_peso_l5),
    .i_nuovi_pesi        (pd_dwCalc_weight),
    .i_nuovi_pesi_vld    (pd_dwCalc_weight_vld),
    .od_errore           (pd_uPC_errore)
);
conv_v1_busmaker_W14C3C4C4I12 u_busmaker
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_valid             (i_data_vld),
    .od_data_l5          (pd_busmaker_data_l5)
);
conv_v2_filtr_W14W11P14C16C9C4R8S1 u_filtr
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (pd_busmaker_data_l5),
    .i_weight            (pd_uPC_peso_l5),
    .i_valid             (pd_valid_diretto_l5),
    .od_data             (pd_filtr_data),
    .od_valid            (pd_filtr_data_vld),
    .od_errore           (pd_filtr_errore)
);
conv_v1_dz_busmaker_W14C3C16I12 u_dz_busmaker
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_gradient_enb_l0   (p_gradient_enb_l0),
    .od_gradient_enb_l1  (pd_gradient_enb_l1),
    .i_gradient_l3       (pd_fifo_data),
    .od_gradient_l4      (pd_dz_busmaker_gradient_l4),
    .od_gradient_l5      (pd_dz_busmaker_gradient_l5)
);
common_FIFO_L2_Array_O9W14T510A16 u_gradient_fifo
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_backprop_vld[0]),
    .i_data              (i_backprop),
    .i_read              (pd_gradient_enb_l1),
    .od_data             (pd_fifo_data),
    .od_valid            (pd_fifo_valid),
    .od_empty            (pd_fifo_empty),
    .od_wr_ready         (pd_fifo_wr_ready)
);
conv_v2_dz_calcolatore_W14W11P14C16C9U8S1 u_dz_calcolatore
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_gradient          (pd_dz_busmaker_gradient_l5),
    .i_weight            (pd_uPC_peso_l5),
    .i_valid             (pd_gradient_vld_l5),
    .od_data             (od_backprop),
    .od_valid            (od_backprop_vld),
    .od_errore           (pd_dzCalc_errore)
);
common_FIFO_L2_Array_O12W14T4094A1 u_img_diretto_buff
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_data_vld[0]),
    .i_data              (i_data),
    .i_read              (pd_imgdir_enb_l2),
    .od_data             (pd_ImgDirBuff_data_l4),
    .od_valid            (pd_ImgDirBuff_valid),
    .od_empty            (pd_ImgDirBuff_empty),
    .od_wr_ready         (pd_ImgDirBuff_wr_ready)
);
conv_v2_dw_calcolatore_W14W11W14U8P14P14C16C3C4I12S1M10N2R8R15 u_dw_calcolatore
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_gradient_l4       (pd_dz_busmaker_gradient_l4),
    .i_zprev_l4          (pd_ImgDirBuff_data_l4),
    .i_valid_l4          (pd_imgdir_vld_l4),
    .i_minibatch_min1    (minibatch_min1),
    .i_rallentamente     (rallentamente),
    .i_aggiorntamento    (aggiorntamento),
    .i_weight            (i_weight),
    .i_weight_vld        (i_weight_vld),
    .od_weight           (od_weight),
    .od_weight_vld       (od_weight_vld),
    .od_dWeight          (pd_dwCalc_weight),
    .od_dWeight_vld      (pd_dwCalc_weight_vld),
    .od_errore           (pd_dwCalc_errore)
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
assign w_dw_ultimo = (dw_counter==4-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    dw_counter <= 0;
end
else begin
    if (pd_dwCalc_weight_vld[16-1]) begin
        dw_counter <= (w_dw_ultimo)?0:dw_counter+1;
    end
end
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
    else if (pd_fifo_empty&w_dw_ultimo) begin
        busy <= 0;
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
    gradient_fifo_ovrf <= 0;
end
else begin
    if ((pd_fifo_empty==0)&(pd_fifo_wr_ready==0)) begin
        gradient_fifo_ovrf <= 1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    img_fifo_ovrf <= 0;
end
else begin
    img_fifo_ovrf <= img_fifo_ovrf|(~pd_ImgDirBuff_empty&~pd_ImgDirBuff_wr_ready);
end
end
assign od_busy = busy;
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_data[i] = pd_filtr_data[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_data_vld[i] = pd_filtr_data_vld[i];
    end
end
assign od_errore = {busy_errore,img_fifo_ovrf,gradient_fifo_ovrf,pd_dwCalc_errore,pd_dzCalc_errore,pd_uPC_errore,pd_filtr_errore,pd_controllo_errore};

endmodule