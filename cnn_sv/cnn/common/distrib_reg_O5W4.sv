`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_distrib_reg_O5W4 (
    input  bit clk,
    input  bit i_ena,
    input  bit [4:0] i_addra,
    input  bit [3:0] i_data,
    input  bit i_enb,
    input  bit [4:0] i_addrb,
    output bit [3:0] od_ram
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] data;
bit [3:0] dob;

distrib #(
    .ORDER               (5),
    .WIDTH               (4))
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