`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_busmaker_buf_principale_L3_W14C4I12A2 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[1:0],
    input  bit [3:0] i_valid,
    output bit [13:0] od_data[1:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [5:0] addra;
bit [5:0] addrb;
bit ena;
bit enb;
bit enb_reg;

common_bram_reg_array_O6W14A2 u_shift
(
    .clk                 (clk),
    .is0_ena             (ena),
    .is0_addra           (addra),
    .is0_data            (i_data),
    .is1_enb             (enb),
    .is1_addrb           (addrb),
    .i_enb_reg           (enb_reg),
    .od_data             (od_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign ena = i_valid[3];
assign enb = i_valid[0];
assign enb_reg = i_valid[1];
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra <= 0;
end
else begin
    addra <= (ena)?addra+1:addra;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb <= -48;
end
else begin
    addrb <= (enb)?addrb+1:addrb;
end
end

endmodule