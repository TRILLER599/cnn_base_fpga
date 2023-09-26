`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module arithmetic_sum_unovld_sign_W25N5 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [24:0] i_data[4:0],
    input  bit i_valid,
    output bit signed [27:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [2:0] valid;
bit signed [25:0] part_sum0[2:0];
bit signed [26:0] part_sum1[1:0];
bit signed [27:0] part_sum2;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= {valid[1:0],i_valid};
end
end
assign od_valid = valid[2];
always_ff @(posedge clk)
begin
    if (i_valid) begin
        for (int i=0; i<2; i++) begin
            part_sum0[i] <= i_data[i*2]+i_data[i*2+1];
        end
    end
    if (i_valid) begin
        part_sum0[2] <= i_data[4];
    end
end
always_ff @(posedge clk)
begin
    if (valid[0]) begin
        for (int i=0; i<1; i++) begin
            part_sum1[i] <= part_sum0[i*2]+part_sum0[i*2+1];
        end
    end
    if (valid[0]) begin
        part_sum1[1] <= part_sum0[2];
    end
end
always_ff @(posedge clk)
begin
    if (valid[1]) begin
        part_sum2 <= part_sum1[0]+part_sum1[1];
    end
end
assign od_data = part_sum2;

endmodule