`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_filtr_math_W14W14W11C9 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[8:0],
    input  bit [10:0] i_weight[8:0],
    input  bit i_valid,
    output bit signed [27:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [2:0] valid;
bit signed [13:0] data[8:0];
bit signed [10:0] weight[8:0];
bit mult_en[8:0];
bit signed [23:0] mult[8:0];
bit sum_en[4:0];
bit signed [24:0] sum_0[4:0];
bit w_sum_vld;

arithmetic_sum_unovld_sign_W25N5 u_sum
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (sum_0),
    .i_valid             (w_sum_vld),
    .od_data             (od_data),
    .od_valid            (od_valid)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= (valid<<<1)|i_valid;
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (i_valid) begin
            data[i] <= i_data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (i_valid) begin
            weight[i] <= i_weight[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        mult_en[i] <= i_valid;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (mult_en[i]) begin
            mult[i] <= weight[i]*data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        sum_en[i] <= valid[0];
    end
    sum_en[4] <= valid[0];
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        if (sum_en[i]) begin
            sum_0[i] <= mult[2*i]+mult[2*i+1];
        end
    end
    if (sum_en[4+1-1]) begin
        sum_0[4] <= mult[9-1];
    end
end
assign w_sum_vld = valid[2];

endmodule