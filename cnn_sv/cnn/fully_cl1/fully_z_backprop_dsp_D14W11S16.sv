`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl1_fully_z_backprop_dsp_D14W11S16 (
    input  bit clk,
    input  bit signed [13:0] i_data,
    input  bit i_data_start[15:0],
    input  bit signed [10:0] i_weight[15:0],
    input  bit i_weight_vld[15:0],
    output bit signed [28:0] od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data[15:0];
bit signed [10:0] weight[15:0];
bit signed [24:0] mult[15:0];
bit signed [28:0] sum[15:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (i_data_start[i]) begin
            data[i] <= i_data;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (i_weight_vld[i]) begin
            weight[i] <= i_weight[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        mult[i] <= data[i]*weight[i];
    end
end
always_ff @(posedge clk)
begin
    sum[0] <= mult[0];
    for (int i=1; i<16; i++) begin
        sum[i] <= mult[i]+sum[i-1];
    end
end
assign od_data = sum[16-1];

endmodule