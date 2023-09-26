`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module arithmetic_sum_simple_sign_W25N13 (
    input  bit clk,
    input  bit signed [24:0] i_data[12:0],
    output bit signed [28:0] od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [25:0] part_sum0[6:0];
bit signed [26:0] part_sum1[3:0];
bit signed [27:0] part_sum2[1:0];
bit signed [28:0] part_sum3;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<6; i++) begin
        part_sum0[i] <= i_data[i*2]+i_data[i*2+1];
    end
    part_sum0[6] <= i_data[12];
end
always_ff @(posedge clk)
begin
    for (int i=0; i<3; i++) begin
        part_sum1[i] <= part_sum0[i*2]+part_sum0[i*2+1];
    end
    part_sum1[3] <= part_sum0[6];
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        part_sum2[i] <= part_sum1[i*2]+part_sum1[i*2+1];
    end
end
always_ff @(posedge clk)
begin
    part_sum3 <= part_sum2[0]+part_sum2[1];
end
assign od_data = part_sum3;

endmodule