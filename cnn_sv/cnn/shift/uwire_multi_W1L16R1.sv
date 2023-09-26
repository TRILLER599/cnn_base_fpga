`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module shift_uwire_multi_W1L16R1 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_data,
    output bit o_data[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit data[14:0];
bit data_w[15:0];


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
if (i_rst) begin
    data[0] <= 0;
    data[1] <= 0;
    data[2] <= 0;
    data[3] <= 0;
    data[4] <= 0;
    data[5] <= 0;
    data[6] <= 0;
    data[7] <= 0;
    data[8] <= 0;
    data[9] <= 0;
    data[10] <= 0;
    data[11] <= 0;
    data[12] <= 0;
    data[13] <= 0;
    data[14] <= 0;
end
else begin
    data[0] <= i_data;
    for (int i=1; i<15; i++) begin
        data[i] <= data[i-1];
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        o_data[i] = data_w[i];
    end
end

endmodule