`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module arithmetic_sum_unovld_sign_W28N16 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [27:0] i_data[15:0],
    input  bit i_valid,
    output bit signed [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] valid;
bit signed [28:0] part_sum0[7:0];
bit signed [29:0] part_sum1[3:0];
bit signed [30:0] part_sum2[1:0];
bit signed [31:0] part_sum3;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= {valid[2:0],i_valid};
end
end
assign od_valid = valid[3];
always_ff @(posedge clk)
begin
    if (i_valid) begin
        for (int i=0; i<8; i++) begin
            part_sum0[i] <= i_data[i*2]+i_data[i*2+1];
        end
    end
end
always_ff @(posedge clk)
begin
    if (valid[0]) begin
        for (int i=0; i<4; i++) begin
            part_sum1[i] <= part_sum0[i*2]+part_sum0[i*2+1];
        end
    end
end
always_ff @(posedge clk)
begin
    if (valid[1]) begin
        for (int i=0; i<2; i++) begin
            part_sum2[i] <= part_sum1[i*2]+part_sum1[i*2+1];
        end
    end
end
always_ff @(posedge clk)
begin
    if (valid[2]) begin
        part_sum3 <= part_sum2[0]+part_sum2[1];
    end
end
assign od_data = part_sum3;

endmodule