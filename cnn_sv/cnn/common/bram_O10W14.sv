`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_bram_O10W14 (
    input  bit clk,
    input  bit i_ena,
    input  bit [9:0] i_addra,
    input  bit [13:0] i_data,
    input  bit i_enb,
    input  bit [9:0] i_addrb,
    output bit [13:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data;
bit [13:0] dob;

distrib #(
    .ORDER               (10),
    .WIDTH               (14))
ram (
    .clk                 (clk),
    .ena                 (i_ena),
    .addra               (i_addra),
    .dia                 (i_data),
    .addrb               (i_addrb),
    .dob                 (dob));


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_enb) begin
        data <= dob;
    end
end
assign od_ram = data;

endmodule