`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_bram_reg_O12W14 (
    input  bit clk,
    input  bit is0_ena,
    input  bit [11:0] is0_addra,
    input  bit [13:0] is0_data,
    input  bit is1_enb,
    input  bit [11:0] is1_addrb,
    input  bit i_enb_reg,
    output bit [13:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data;
bit [13:0] data_reg;
bit [13:0] dob;

distrib #(
    .ORDER               (12),
    .WIDTH               (14))
ram (
    .clk                 (clk),
    .ena                 (is0_ena),
    .addra               (is0_addra),
    .dia                 (is0_data),
    .addrb               (is1_addrb),
    .dob                 (dob));


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (is1_enb) begin
        data <= dob;
    end
end
always_ff @(posedge clk)
begin
    if (i_enb_reg) begin
        data_reg <= data;
    end
end
assign od_ram = data_reg;

endmodule