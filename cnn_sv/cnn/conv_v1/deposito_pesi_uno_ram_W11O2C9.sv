`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_deposito_pesi_uno_ram_W11O2C9 (
    input  bit clk,
    input  bit i_rst,
    input  bit [8:0] i_ena,
    input  bit [1:0] i_addra,
    input  bit [10:0] i_dia[8:0],
    input  bit [8:0] i_enb,
    input  bit [1:0] i_addrb,
    output bit [10:0] od_dob_l2[8:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit enb_reg[8:0];
bit [1:0] addrb_l1;
bit w_ena[8:0];
bit w_enb[8:0];

genvar i;
generate
for (i=0; i<9; i++) begin : gen__common_distrib_reg_O2W11
    common_distrib_reg_O2W11 u_ram
    (
        .clk                 (clk),
        .i_ena               (w_ena[i]),
        .i_addra             (i_addra),
        .i_data              (i_dia[i]),
        .i_enb               (enb_reg[i]),
        .i_addrb             (addrb_l1),
        .od_ram              (od_dob_l2[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_ena[i] = i_ena[i];
    end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_enb[i] = i_enb[i];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_reg[0] <= 0;
    enb_reg[1] <= 0;
    enb_reg[2] <= 0;
    enb_reg[3] <= 0;
    enb_reg[4] <= 0;
    enb_reg[5] <= 0;
    enb_reg[6] <= 0;
    enb_reg[7] <= 0;
    enb_reg[8] <= 0;
end
else begin
    for (int i=0; i<9; i++) begin
        enb_reg[i] <= w_enb[i];
    end
end
end
always_ff @(posedge clk)
begin
    addrb_l1 <= i_addrb;
end

endmodule