`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module base_construct_unari_operator_W1L1or (
    input  bit clk,
    input  bit i_data[0:0],
    output bit o_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit data;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign data = i_data[0];
assign o_data = data;

endmodule