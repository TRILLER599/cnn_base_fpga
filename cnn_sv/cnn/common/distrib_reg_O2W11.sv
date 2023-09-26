`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_distrib_reg_O2W11 (
    input  bit clk,
    input  bit i_ena,
    input  bit [1:0] i_addra,
    input  bit [10:0] i_data,
    input  bit i_enb,
    input  bit [1:0] i_addrb,
    output bit [10:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] data;
bit [10:0] dob;

distrib #(
    .ORDER               (2),
    .WIDTH               (11))
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