`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_filtr_W14W11P14C5F29 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[4:0],
    input  bit i_data_vld,
    input  bit i_str_end,
    input  bit [10:0] i_weight[24:0],
    output bit signed [28:0] od_z,
    output bit od_z_vld
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[24:0];
bit [4:0] valid;
bit valid_fm;

conv_v0_1_filtr_math0_W14W11C5F29 u_filtr_math
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (data),
    .i_data_vld          (valid_fm),
    .i_weight            (i_weight),
    .od_z                (od_z),
    .od_z_vld            (od_z_vld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_data_vld) begin
        for (int k=0; k<5; k++) begin
            data[(k+1)*5-1] <= i_data[(5-1)-k];
            for (int i=0; i<4; i++) begin
                data[k*5+i] <= data[k*5+i+1];
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid[5-1] <= i_data_vld&valid[3];
    if (i_data_vld) begin
        if (i_str_end) begin
            valid[5-2:0] <= 0;
        end
        else begin
            valid[5-2:0] <= (valid[2:0]<<<1)|1'b1;
        end
    end
end
end
assign valid_fm = valid[4];

endmodule