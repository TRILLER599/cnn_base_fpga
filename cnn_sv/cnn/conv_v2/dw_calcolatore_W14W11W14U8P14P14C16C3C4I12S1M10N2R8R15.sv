`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_dw_calcolatore_W14W11W14U8P14P14C16C3C4I12S1M10N2R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_gradient_l4[143:0],
    input  bit [13:0] i_zprev_l4[0:0],
    input  bit i_valid_l4[15:0],
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_aggiorntamento,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit [10:0] od_dWeight[143:0],
    output bit od_dWeight_vld[15:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit errore;
bit [13:0] w_gradient_l4_stream[143:0];
bit [13:0] zprev_l4_conv[15:0];
bit [10:0] pd_peso_diviso[15:0];
bit [8:0] pd_peso_diviso_vld[15:0];
bit [10:0] pd_peso_rit[15:0];
bit pd_peso_rit_vld[15:0];
bit pd_dWeight_vld[15:0];
bit pd_dW_errore[15:0];
bit p_erorer_uno;

conv_v2_peso_corsia_W11C9C16S1C4 u_peso_corsia
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_peso              (i_weight),
    .i_valid             (i_weight_vld),
    .od_peso_diviso      (pd_peso_diviso),
    .od_peso_diviso_vld  (pd_peso_diviso_vld)
);

genvar i;
generate
for (i=0;i<16*1; i++) begin : gen__conv_v2_dw_calcolatore_precizo_W14W11W14U8P14P14C3C4I12M10R8R15
    conv_v2_dw_calcolatore_precizo_W14W11W14U8P14P14C3C4I12M10R8R15 u_dw_calc_stream
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (i_rst),
        .i_gradient_l4       (w_gradient_l4_stream[i*9+8:i*9]),
        .i_zprev_l4          (zprev_l4_conv[i]),
        .i_valid_l4          (i_valid_l4[i]),
        .i_minibatch_min1    (i_minibatch_min1),
        .i_rallentamente     (i_rallentamente),
        .i_aggiorntamento    (i_aggiorntamento),
        .i_weight            (pd_peso_diviso[i]),
        .i_weight_vld        (pd_peso_diviso_vld[i]),
        .od_weight           (pd_peso_rit[i]),
        .od_weight_vld       (pd_peso_rit_vld[i]),
        .od_dWeight          (od_dWeight[i*9+8:i*9]),
        .od_dWeight_vld      (pd_dWeight_vld[i]),
        .od_errore           (pd_dW_errore[i])
    );
end
endgenerate
separ_union_mux_std_unsign_W11N16 u_weight_scarico
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (pd_peso_rit),
    .i_data_vld          (pd_peso_rit_vld),
    .od_data             (od_weight),
    .od_data_vld         (od_weight_vld)
);
base_construct_unari_operator_W1L16or u_errore_unione
(
    .clk                 (clk),
    .i_data              (pd_dW_errore),
    .o_data              (p_erorer_uno)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<16; i++) begin
        for (int s=0; s<1; s++) begin
            for (int k=0; k<9; k++) begin
                w_gradient_l4_stream[i*1*9+s*9+k] = i_gradient_l4[i*9+k];
            end
        end
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        for (int s=0; s<1; s++) begin
            zprev_l4_conv[i*1+s] = i_zprev_l4[s];
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    errore <= 0;
end
else begin
    errore <= errore|p_erorer_uno;
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_dWeight_vld[i] = pd_dWeight_vld[i*1];
    end
end
assign od_errore = errore;

endmodule