`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module shift_uwire_multi_W9L16R0 (
    input  bit clk,
    input  bit [8:0] i_data,
    output bit [8:0] o_data[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [8:0] data[14:0];
bit [8:0] data_w[15:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    data_w[0] = i_data;
    for (int i=1; i<16; i++) begin
        data_w[i] = data[i-1];
    end
end
always_ff @(posedge clk)
begin
    data[0] <= i_data;
    for (int i=1; i<15; i++) begin
        data[i] <= data[i-1];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        o_data[i] = data_w[i];
    end
end

endmodule