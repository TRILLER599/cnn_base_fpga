`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_filtr_math0_dsp_W14W11 (
    input  bit clk,
    input  bit signed [13:0] i_data[1:0],
    input  bit i_data_vld,
    input  bit signed [10:0] i_weight[1:0],
    input  bit i_weight_vld,
    output bit signed [24:0] od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data[1:0];
bit signed [10:0] weight[1:0];
bit signed [24:0] mult[1:0];
bit signed [24:0] sum;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (i_data_vld) begin
            data[i] <= i_data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (i_weight_vld) begin
            weight[i] <= i_weight[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        mult[i] <= data[i]*weight[i];
    end
end
always_ff @(posedge clk)
begin
    sum <= mult[0]+mult[1];
end
assign od_data = sum;

endmodule