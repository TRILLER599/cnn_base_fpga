`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module shift_ureg_multi_vld_W14L4D1R0 (
    input  bit clk,
    input  bit [13:0] i_data,
    input  bit i_valid,
    output bit [13:0] od_data[3:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[3:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_valid) begin
        data[0] <= i_data;
        for (int i=1; i<4; i++) begin
            data[i] <= data[i-1];
        end
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_data[i] = data[4-i-1];
    end
end

endmodule