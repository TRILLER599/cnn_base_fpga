`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl2_permutazione_diretto_ritardo_W14W14P1P400C16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_valid[0:0],
    output bit [13:0] od_data[0:0],
    output bit od_valid[0:0],
    output bit od_img_end[0:0],
    input  bit [13:0] i_backprop_sum[0:0],
    input  bit i_backprop_sum_vld[0:0],
    output bit [13:0] od_backprop[0:0],
    output bit od_backprop_vld[0:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

genvar i;
generate
for (i=0;i<1;i++) begin : gen__fully_cl2_permutazione_diretto_W14P400C16
    fully_cl2_permutazione_diretto_W14P400C16 u_perm_diretto
    (
        .clk                 (clk),
        .i_rst               (i_rst),
        .i_data              (i_data[i]),
        .i_valid             (i_valid[i]),
        .od_data             (od_data[i]),
        .od_valid            (od_valid[i]),
        .od_img_end          (od_img_end[i])
    );
end
endgenerate

generate
for (i=0;i<1;i++) begin : gen__fully_cl2_permutazione_ritardo_W14P400C16
    fully_cl2_permutazione_ritardo_W14P400C16 u_perm_ritardo
    (
        .clk                 (clk),
        .i_rst               (i_rst),
        .i_data              (i_backprop_sum[i]),
        .i_valid             (i_backprop_sum_vld[i]),
        .od_data             (od_backprop[i]),
        .od_valid            (od_backprop_vld[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

endmodule