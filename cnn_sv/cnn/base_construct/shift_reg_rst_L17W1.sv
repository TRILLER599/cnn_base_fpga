`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module base_construct_shift_reg_rst_L17W1 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_data,
    output bit od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit sh[16:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    sh[0] <= 0;
    sh[1] <= 0;
    sh[2] <= 0;
    sh[3] <= 0;
    sh[4] <= 0;
    sh[5] <= 0;
    sh[6] <= 0;
    sh[7] <= 0;
    sh[8] <= 0;
    sh[9] <= 0;
    sh[10] <= 0;
    sh[11] <= 0;
    sh[12] <= 0;
    sh[13] <= 0;
    sh[14] <= 0;
    sh[15] <= 0;
    sh[16] <= 0;
end
else begin
    sh[0] <= i_data;
    for (int i=1; i<17; i++) begin
        sh[i] <= sh[i-1];
    end
end
end
assign od_data = sh[17-1];

endmodule