`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_dz_calcolatore_uno_W14W11P14C9S1 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_gradient[8:0],
    input  bit [10:0] i_weight[8:0],
    input  bit i_valid,
    output bit signed [27:0] od_data[0:0],
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] w_weight_revers[8:0];
bit pd_fm_valid[0:0];

genvar i;
generate
for (i=0; i<1; i++) begin : gen__conv_v2_filtr_math_W14W14W11C9
    conv_v2_filtr_math_W14W14W11C9 u_filtr_math
    (
        .clk                 (clk),
        .i_rst               (i_rst),
        .i_data              (i_gradient),
        .i_weight            (w_weight_revers[i*9+8:i*9]),
        .i_valid             (i_valid),
        .od_data             (od_data[i]),
        .od_valid            (pd_fm_valid[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<1; i++) begin
        for (int k=0; k<9; k++) begin
            w_weight_revers[i*9+k] = i_weight[i*9+9-k-1];
        end
    end
end
assign od_valid = pd_fm_valid[0];

endmodule