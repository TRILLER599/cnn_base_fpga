`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module pool_v0_maxpool_v0_W14L0C16C4P2L10P3N1 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[15:0],
    input  bit i_valid[15:0],
    output bit [13:0] od_data[0:0],
    output bit od_valid[0:0],
    input  bit [13:0] i_backprop[0:0],
    input  bit i_backprop_vld[0:0],
    output bit [13:0] od_backprop[15:0],
    output bit od_backprop_vld[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] pd_comprl_data[1:0];
bit [1:0] pd_comprl_index[1:0];
bit pd_comprl_pre_valid;
bit pd_comprl_valid[1:0];
bit [13:0] pd_diretto_data[0:0];
bit pd_diretto_valid[0:0];
bit [1:0] pd_diretto_index[1:0];
bit pd_diretto_index_vld[15:0];

pool_v0_compressione_linea_W14C16C4P2L10 u_compr_linea
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_data              (i_data),
    .i_valid             (i_valid),
    .od_valid_m1         (pd_comprl_pre_valid),
    .od_data             (pd_comprl_data),
    .od_index            (pd_comprl_index),
    .od_valid            (pd_comprl_valid)
);
pool_v0_passaggio_diretto_v1_W14C16C4P2L10 u_passaggio_diretto
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_pre_valid         (pd_comprl_pre_valid),
    .i_data              (pd_comprl_data),
    .i_index             (pd_comprl_index),
    .i_valid             (pd_comprl_valid),
    .od_data             (pd_diretto_data),
    .od_valid            (pd_diretto_valid),
    .od_index            (pd_diretto_index),
    .od_index_vld        (pd_diretto_index_vld)
);
pool_v0_passaggio_ritorno_W14C16C4C8P2L5P3N1 u_passaggio_ritorno
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (i_rst),
    .i_data              (i_backprop),
    .i_valid             (i_backprop_vld),
    .i_index             (pd_diretto_index),
    .i_index_vld         (pd_diretto_index_vld),
    .od_data             (od_backprop),
    .od_valid            (od_backprop_vld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data[i] = pd_diretto_data[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_valid[i] = pd_diretto_valid[i];
    end
end

endmodule