`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module shift_wire_array_ext_u2s_vld_W14A5E4I1D0R0 (
    input  bit clk,
    input  bit [13:0] i_data[4:0],
    input  bit i_valid,
    output bit signed [13:0] o_data[24:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[19:0];
bit [13:0] reorder_data[4:0];
bit signed [13:0] w_data[24:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<5; i++) begin
        reorder_data[5-1-i] = i_data[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<5; i++) begin
        if (i_valid) begin
            data[i*4] <= reorder_data[i];
            for (int k=0; k<3; k++) begin
                data[i*4+k+1] <= data[i*4+k];
            end
        end
    end
end
always_comb
begin
    for (int i=0; i<5; i++) begin
        w_data[i*5] = reorder_data[i];
        for (int k=0; k<4; k++) begin
            w_data[i*5+k+1] = data[i*4+k];
        end
    end
end
always_comb
begin
    for (int i=0; i<25; i++) begin
        o_data[i] = w_data[i];
    end
end

endmodule