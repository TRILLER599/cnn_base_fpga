`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_bram_reg_O7W2 (
    input  bit clk,
    input  bit is0_ena,
    input  bit [6:0] is0_addra,
    input  bit [1:0] is0_data,
    input  bit is1_enb,
    input  bit [6:0] is1_addrb,
    input  bit i_enb_reg,
    output bit [1:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [1:0] data;
bit [1:0] data_reg;
bit [1:0] dob;

distrib #(
    .ORDER               (7),
    .WIDTH               (2))
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