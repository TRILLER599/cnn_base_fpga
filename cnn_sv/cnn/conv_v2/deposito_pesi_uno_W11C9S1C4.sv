`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_deposito_pesi_uno_W11C9S1C4 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [10:0] i_peso_carico,
    input  bit i_caricamento,
    output bit [10:0] od_peso_scarico,
    output bit od_scaricamento,
    input  bit i_enb_calcolo,
    output bit [10:0] od_peso_calcolo_l3[8:0],
    input  bit [10:0] i_nuovi_pesi[8:0],
    input  bit i_nuovi_pesi_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] peso_carico_l1;
bit caricamento_l1;
bit [3:0] count_size2_wr;
bit [3:0] count_size2_rd;
bit end_size2_wr;
bit end_size2_rd;
bit [8:0] size2_wr_std;
bit [8:0] size2_rd_std;
bit [1:0] count_compress_wr;
bit [1:0] count_compress_rd;
bit [10:0] dia_uRam[8:0];
bit [1:0] addra;
bit [1:0] addrb;
bit [8:0] ena[0:0];
bit [8:0] enb[0:0];
bit scaricamento_ram[2:0];
bit [3:0] contatore_rd_seriale[2:0];
bit [10:0] pd_ram_data[8:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0; i<1; i++) begin : gen__conv_v1_deposito_pesi_uno_ram_W11O2C9
    conv_v1_deposito_pesi_uno_ram_W11O2C9 u_ram_conv_2
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_ena               (ena[i]),
        .i_addra             (addra),
        .i_dia               (dia_uRam[i*9+8:i*9]),
        .i_enb               (enb[i]),
        .i_addrb             (addrb),
        .od_dob_l2           (pd_ram_data[i*9+8:i*9])
    );
end
endgenerate
separ_union_mux_int_vld_unsign_W11N9 u_unione_peso_scarico
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_ram_data),
    .i_valid             (scaricamento_ram[2]),
    .i_mux               (contatore_rd_seriale[2]),
    .od_data             (od_peso_scarico),
    .od_valid            (od_scaricamento)
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
    peso_carico_l1 <= i_peso_carico;
end
always_ff @(posedge clk)
begin
    caricamento_l1 <= i_caricamento;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_size2_wr <= 0;
end
else begin
    if (caricamento_l1) begin
        count_size2_wr <= (end_size2_wr)?0:count_size2_wr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    end_size2_wr <= 0;
end
else begin
    if (caricamento_l1) begin
        end_size2_wr <= (count_size2_wr==9-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    size2_wr_std <= 1;
end
else begin
    if (caricamento_l1) begin
        size2_wr_std <= {size2_wr_std[7:0],size2_wr_std[8]};
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_compress_wr <= 0;
end
else begin
    if ((caricamento_l1&end_size2_wr)|i_nuovi_pesi_vld) begin
        count_compress_wr <= (count_compress_wr==(4-1))?0:count_compress_wr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_size2_rd <= 0;
end
else begin
    if (i_caricamento) begin
        count_size2_rd <= (end_size2_rd)?0:count_size2_rd+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    end_size2_rd <= 0;
end
else begin
    if (i_caricamento) begin
        end_size2_rd <= (count_size2_rd==9-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    size2_rd_std <= 1;
end
else begin
    if (i_caricamento) begin
        size2_rd_std <= {size2_rd_std[7:0],size2_rd_std[8]};
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_compress_rd <= 0;
end
else begin
    if ((i_caricamento&end_size2_rd)|i_enb_calcolo) begin
        count_compress_rd <= (count_compress_rd==(4-1))?0:count_compress_rd+1;
    end
end
end
always_ff @(posedge clk)
begin
    if (caricamento_l1|i_nuovi_pesi_vld) begin
        for (int i=0; i<1; i++) begin
            for (int k=0; k<9; k++) begin
                dia_uRam[i*9+k] <= (i_nuovi_pesi_vld)?i_nuovi_pesi[i*9+k]:peso_carico_l1;
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena[0] <= 0;
end
else begin
    if (caricamento_l1) begin
        ena[0] <= size2_wr_std;
    end
    else if (i_nuovi_pesi_vld) begin
        ena[0] <= 9'd511;
    end
    else begin
        ena[0] <= 0;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    enb[0] <= 0;
end
else begin
    if (i_caricamento) begin
        enb[0] <= size2_rd_std;
    end
    else if (i_enb_calcolo) begin
        enb[0] <= 9'd511;
    end
    else begin
        enb[0] <= 0;
    end
end
end
always_ff @(posedge clk)
begin
    addra <= count_compress_wr;
end
always_ff @(posedge clk)
begin
    addrb <= count_compress_rd;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    scaricamento_ram[0] <= 0;
    scaricamento_ram[1] <= 0;
    scaricamento_ram[2] <= 0;
end
else begin
    scaricamento_ram[0] <= i_caricamento;
    scaricamento_ram[1] <= scaricamento_ram[0];
    scaricamento_ram[2] <= scaricamento_ram[1];
end
end
always_ff @(posedge clk)
begin
    contatore_rd_seriale[0] <= count_size2_rd;
    contatore_rd_seriale[1] <= contatore_rd_seriale[0];
    contatore_rd_seriale[2] <= contatore_rd_seriale[1];
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        od_peso_calcolo_l3[i] = pd_ram_data[i];
    end
end

endmodule