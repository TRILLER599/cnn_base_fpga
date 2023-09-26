`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module base_construct_unari_operator_W1L4or (
    input  bit clk,
    input  bit i_data[3:0],
    output bit o_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit data;
bit [3:0] data_half;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<4; i++) begin
        data_half[i] = i_data[i];
    end
end
assign data = |data_half;
assign o_data = data;

endmodule