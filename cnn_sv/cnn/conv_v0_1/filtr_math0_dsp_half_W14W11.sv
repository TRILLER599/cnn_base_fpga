`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_filtr_math0_dsp_half_W14W11 (
    input  bit clk,
    input  bit signed [13:0] i_data,
    input  bit i_data_vld,
    input  bit signed [10:0] i_weight,
    input  bit i_weight_vld,
    output bit signed [24:0] od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data;
bit signed [10:0] weight;
bit signed [24:0] mult;
bit signed [24:0] sum;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_data_vld) begin
        data <= i_data;
    end
end
always_ff @(posedge clk)
begin
    if (i_weight_vld) begin
        weight <= i_weight;
    end
end
always_ff @(posedge clk)
begin
    mult <= data*weight;
end
always_ff @(posedge clk)
begin
    sum <= mult;
end
assign od_data = sum;

endmodule