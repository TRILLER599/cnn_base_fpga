`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_dw_dsp_D14W14C5S35 (
    input  bit clk,
    input  bit signed [13:0] i_data[24:0],
    input  bit i_data_en,
    input  bit signed [13:0] i_grad,
    input  bit i_grad_en,
    input  bit i_mult_en,
    input  bit i_cmd_en,
    input  bit [1:0] i_cmd,
    input  bit i_sum_sh_en,
    output bit signed [34:0] od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data[24:0];
bit signed [13:0] gradiente[24:0];
bit signed [27:0] mult[24:0];
bit [1:0] cmd[24:0];
bit signed [34:0] sum[24:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    for (int i=0; i<25; i++) begin
        if (i_data_en) begin
            data[i] <= i_data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<25; i++) begin
        if (i_grad_en) begin
            gradiente[i] <= i_grad;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<25; i++) begin
        if (i_mult_en) begin
            mult[i] <= data[i]*gradiente[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<25; i++) begin
        if (i_cmd_en) begin
            cmd[i] <= i_cmd;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_sum_sh_en) begin
        if (cmd[0]==0) begin
            sum[0] <= mult[0];
        end
        else if (cmd[0]==1) begin
            sum[0] <= sum[0]+mult[0];
        end
        else begin
            sum[0] <= 0;
        end
        for (int i=1; i<25; i++) begin
            if (cmd[i]==0) begin
                sum[i] <= mult[i];
            end
            else if (cmd[i]==1) begin
                sum[i] <= sum[i]+mult[i];
            end
            else begin
                sum[i] <= sum[i-1];
            end
        end
    end
end
assign od_data = sum[25-1];

endmodule