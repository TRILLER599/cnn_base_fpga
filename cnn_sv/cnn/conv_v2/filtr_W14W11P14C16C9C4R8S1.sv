`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_filtr_W14W11P14C16C9C4R8S1 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[8:0],
    input  bit [10:0] i_weight[143:0],
    input  bit i_valid[15:0],
    output bit [13:0] od_data[15:0],
    output bit od_valid[15:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit errore;
bit pd_uno_errore[15:0];
bit p_errore_or;
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<16; i++) begin : gen__conv_v2_filtr_uno_W14W11P14C9C4R8S1
    conv_v2_filtr_uno_W14W11P14C9C4R8S1 u_filtr_uno
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_data              (i_data),
        .i_weight            (i_weight[i*9*1+8:i*9*1]),
        .i_valid             (i_valid[i*1:i*1]),
        .od_data             (od_data[i]),
        .od_valid            (od_valid[i]),
        .od_errore_traboccare(pd_uno_errore[i])
    );
end
endgenerate
base_construct_unari_operator_W1L16or u_errore_or
(
    .clk                 (clk),
    .i_data              (pd_uno_errore),
    .o_data              (p_errore_or)
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
    errore <= 0;
end
else begin
    errore <= p_errore_or;
end
end
assign od_errore = errore;

endmodule