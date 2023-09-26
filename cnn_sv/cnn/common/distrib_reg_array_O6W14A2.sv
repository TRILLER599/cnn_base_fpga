`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_distrib_reg_array_O6W14A2 (
    input  bit clk,
    input  bit is0_ena,
    input  bit [5:0] is0_addra,
    input  bit [13:0] is0_data[1:0],
    input  bit is1_enb,
    input  bit [5:0] is1_addrb,
    output bit [13:0] od_data[1:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [27:0] data_wr_part;
bit [27:0] pd_data_rd_part;

common_distrib_reg_O6W28 u_distrib_part
(
    .clk                 (clk),
    .i_ena               (is0_ena),
    .i_addra             (is0_addra),
    .i_data              (data_wr_part),
    .i_enb               (is1_enb),
    .i_addrb             (is1_addrb),
    .od_ram              (pd_data_rd_part)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign data_wr_part = {is0_data[1],is0_data[0]};
assign od_data[0] = pd_data_rd_part[13:0];
assign od_data[1] = pd_data_rd_part[27:14];

endmodule