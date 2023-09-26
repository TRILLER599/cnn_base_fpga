`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_deposito_pesi_W11C9C16S1C4 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [10:0] i_peso_carico,
    input  bit i_caricamento,
    output bit [10:0] od_peso_scarico,
    output bit od_scaricamento,
    input  bit i_enb_calcolo[15:0],
    output bit [10:0] od_peso_calcolo_l3[143:0],
    input  bit [10:0] i_nuovi_pesi[143:0],
    input  bit i_nuovi_pesi_vld[15:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [5:0] count_wr_uno;
bit num_wr_std[15:0];
bit caricamento_l1;
bit [10:0] peso_carico_uUno;
bit caricamento_uUno[15:0];
bit errore;
bit [10:0] pd_uUno_peso_scarico[15:0];
bit pd_uUno_scaricamento[15:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0; i<16; i++) begin : gen__conv_v2_deposito_pesi_uno_W11C9S1C4
    conv_v2_deposito_pesi_uno_W11C9S1C4 u_Uno
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_peso_carico       (peso_carico_uUno),
        .i_caricamento       (caricamento_uUno[i]),
        .od_peso_scarico     (pd_uUno_peso_scarico[i]),
        .od_scaricamento     (pd_uUno_scaricamento[i]),
        .i_enb_calcolo       (i_enb_calcolo[i]),
        .od_peso_calcolo_l3  (od_peso_calcolo_l3[i*9*1+8:i*9*1]),
        .i_nuovi_pesi        (i_nuovi_pesi[i*9*1+8:i*9*1]),
        .i_nuovi_pesi_vld    (i_nuovi_pesi_vld[i])
    );
end
endgenerate
separ_union_mux_std_unsign_W11N16 u_Unione_peso_scarico
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_uUno_peso_scarico),
    .i_data_vld          (pd_uUno_scaricamento),
    .od_data             (od_peso_scarico),
    .od_data_vld         (od_scaricamento)
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
if (rst__l) begin
    count_wr_uno <= 0;
end
else begin
    if (i_caricamento) begin
        count_wr_uno <= (count_wr_uno==(36-1))?0:count_wr_uno+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    num_wr_std[0] <= 1;
    num_wr_std[1] <= 0;
    num_wr_std[2] <= 0;
    num_wr_std[3] <= 0;
    num_wr_std[4] <= 0;
    num_wr_std[5] <= 0;
    num_wr_std[6] <= 0;
    num_wr_std[7] <= 0;
    num_wr_std[8] <= 0;
    num_wr_std[9] <= 0;
    num_wr_std[10] <= 0;
    num_wr_std[11] <= 0;
    num_wr_std[12] <= 0;
    num_wr_std[13] <= 0;
    num_wr_std[14] <= 0;
    num_wr_std[15] <= 0;
end
else begin
    if (i_caricamento&(count_wr_uno==(36-1))) begin
        num_wr_std[0] <= num_wr_std[16-1];
        for (int i=1; i<16; i++) begin
            num_wr_std[i] <= num_wr_std[i-1];
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    caricamento_l1 <= 0;
end
else begin
    caricamento_l1 <= i_caricamento;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    caricamento_uUno[0] <= 0;
    caricamento_uUno[1] <= 0;
    caricamento_uUno[2] <= 0;
    caricamento_uUno[3] <= 0;
    caricamento_uUno[4] <= 0;
    caricamento_uUno[5] <= 0;
    caricamento_uUno[6] <= 0;
    caricamento_uUno[7] <= 0;
    caricamento_uUno[8] <= 0;
    caricamento_uUno[9] <= 0;
    caricamento_uUno[10] <= 0;
    caricamento_uUno[11] <= 0;
    caricamento_uUno[12] <= 0;
    caricamento_uUno[13] <= 0;
    caricamento_uUno[14] <= 0;
    caricamento_uUno[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        caricamento_uUno[i] <= num_wr_std[i]&i_caricamento;
    end
end
end
always_ff @(posedge clk)
begin
    peso_carico_uUno <= (i_caricamento)?i_peso_carico:peso_carico_uUno;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore <= 0;
end
else begin
    errore <= errore|(caricamento_l1&i_enb_calcolo[0])|(caricamento_l1&i_nuovi_pesi_vld[0]);
end
end
assign od_errore = errore;

endmodule