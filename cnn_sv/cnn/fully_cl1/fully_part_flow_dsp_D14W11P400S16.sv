`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl1_fully_part_flow_dsp_D14W11P400S16 (
    input  bit clk,
    input  bit signed [13:0] i_data,
    input  bit i_data_vld[15:0],
    input  bit signed [10:0] i_weight[15:0],
    input  bit i_weight_vld[15:0],
    input  bit i_mult_en[15:0],
    input  bit i_sum_en[15:0],
    input  bit i_start[15:0],
    output bit signed [33:0] od_data[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data[15:0];
bit signed [10:0] weight[15:0];
bit mult_en[15:0];
bit sum_en[15:0];
bit start[15:0];
bit signed [24:0] mult[15:0];
bit signed [33:0] sum[15:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_data_vld[0]) begin
        data[0] <= i_data;
    end
    for (int i=1; i<16; i++) begin
        data[i] <= data[i-1];
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
        mult_en[i] <= i_mult_en[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        sum_en[i] <= i_sum_en[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        start[i] <= i_start[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (mult_en[i]) begin
            mult[i] <= weight[i]*data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (sum_en[i]) begin
            sum[i] <= (start[i])?mult[i]:sum[i]+mult[i];
        end
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_data[i] = sum[i];
    end
end

endmodule