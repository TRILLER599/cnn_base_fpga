`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_bram_reg_array_O9W14A16 (
    input  bit clk,
    input  bit is0_ena,
    input  bit [8:0] is0_addra,
    input  bit [13:0] is0_data[15:0],
    input  bit is1_enb,
    input  bit [8:0] is1_addrb,
    input  bit i_enb_reg,
    output bit [13:0] od_data[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [63:0] data_wr[2:0];
bit [63:0] pd_data_rd[2:0];
bit [31:0] data_wr_part;
bit [31:0] pd_data_rd_part;

genvar i;
generate
for (i=0;i<3;i++) begin : gen__common_bram_reg_O9W64
    common_bram_reg_O9W64 u_bram
    (
        .clk                 (clk),
        .is0_ena             (is0_ena),
        .is0_addra           (is0_addra),
        .is0_data            (data_wr[i]),
        .is1_enb             (is1_enb),
        .is1_addrb           (is1_addrb),
        .i_enb_reg           (i_enb_reg),
        .od_ram              (pd_data_rd[i])
    );
end
endgenerate
common_bram_reg_O9W32 u_bram_part
(
    .clk                 (clk),
    .is0_ena             (is0_ena),
    .is0_addra           (is0_addra),
    .is0_data            (data_wr_part),
    .is1_enb             (is1_enb),
    .is1_addrb           (is1_addrb),
    .i_enb_reg           (i_enb_reg),
    .od_ram              (pd_data_rd_part)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign data_wr[0] = {is0_data[4][7:0],is0_data[3],is0_data[2],is0_data[1],is0_data[0]};
assign data_wr[1] = {is0_data[9][1:0],is0_data[8],is0_data[7],is0_data[6],is0_data[5],is0_data[4][13:8]};
assign data_wr[2] = {is0_data[13][9:0],is0_data[12],is0_data[11],is0_data[10],is0_data[9][13:2]};
assign data_wr_part = {is0_data[15],is0_data[14],is0_data[13][13:10]};
assign od_data[0] = pd_data_rd[0][13:0];
assign od_data[1] = pd_data_rd[0][27:14];
assign od_data[2] = pd_data_rd[0][41:28];
assign od_data[3] = pd_data_rd[0][55:42];
assign od_data[4] = {pd_data_rd[1][5:0],pd_data_rd[0][63:56]};
assign od_data[5] = pd_data_rd[1][19:6];
assign od_data[6] = pd_data_rd[1][33:20];
assign od_data[7] = pd_data_rd[1][47:34];
assign od_data[8] = pd_data_rd[1][61:48];
assign od_data[9] = {pd_data_rd[2][11:0],pd_data_rd[1][63:62]};
assign od_data[10] = pd_data_rd[2][25:12];
assign od_data[11] = pd_data_rd[2][39:26];
assign od_data[12] = pd_data_rd[2][53:40];
assign od_data[13] = {pd_data_rd_part[3:0],pd_data_rd[2][63:54]};
assign od_data[14] = pd_data_rd_part[17:4];
assign od_data[15] = pd_data_rd_part[31:18];

endmodule