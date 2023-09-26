`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_busmaker_W14C3C4C4I12 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_valid[0:0],
    output bit [13:0] od_data_l5[8:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

genvar i;
generate
for (i=0;i<1; i++) begin : gen__conv_v1_busmaker_uno_semplice_L5_W14C3C4C4I12
    conv_v1_busmaker_uno_semplice_L5_W14C3C4C4I12 u_busmaker_uno
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (i_rst),
        .i_data              (i_data[i]),
        .i_valid             (i_valid[i]),
        .od_data_l5          (od_data_l5[i*9+8:i*9])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

endmodule