`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_peso_corsia_W11C9C16S1C4 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [10:0] i_peso,
    input  bit i_valid,
    output bit [10:0] od_peso_diviso[15:0],
    output bit [8:0] od_peso_diviso_vld[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [5:0] count_wr_uno;
bit num_wr_std[15:0];
bit [10:0] peso_l1[15:0];
bit w_valid_convUno[15:0];

genvar i;
generate
for (i=0; i<16; i++) begin : gen__conv_v2_peso_corsia_parte
    conv_v2_peso_corsia_parte u_valid_diviso
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_caricamento       (w_valid_convUno[i]),
        .od_caricamento_l1   (od_peso_diviso_vld[i*1:i*1])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    count_wr_uno <= 0;
end
else begin
    if (i_valid) begin
        count_wr_uno <= (count_wr_uno==(36-1))?0:count_wr_uno+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
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
    if (i_valid&&(count_wr_uno==(36-1))) begin
        num_wr_std[0] <= num_wr_std[16-1];
        for (int i=1; i<16; i++) begin
            num_wr_std[i] <= num_wr_std[i-1];
        end
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        w_valid_convUno[i] = num_wr_std[i]&i_valid;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        peso_l1[i] <= i_peso;
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_peso_diviso[i] = peso_l1[i];
    end
end

endmodule