`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_distrib_reg_O6W28 (
    input  bit clk,
    input  bit i_ena,
    input  bit [5:0] i_addra,
    input  bit [27:0] i_data,
    input  bit i_enb,
    input  bit [5:0] i_addrb,
    output bit [27:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [27:0] data;
bit [27:0] dob;

distrib #(
    .ORDER               (6),
    .WIDTH               (28))
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