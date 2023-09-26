`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_dz_calcolatore_W14W11P14C16C9U8S1 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_gradient[143:0],
    input  bit [10:0] i_weight[143:0],
    input  bit i_valid[15:0],
    output bit [13:0] od_data[0:0],
    output bit od_valid[0:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[0:0];
bit valid[0:0];
bit signed [27:0] pd_uno_data[15:0];
bit pd_uno_valid[15:0];
bit signed [27:0] w_data2conv_sum[15:0];
bit signed [31:0] pd_csum_data[0:0];
bit pd_csum_valid[0:0];
bit [21:0] w_data_arrot[0:0];
bit [10:0] w_csum_ecesso[0:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<16; i++) begin : gen__conv_v2_dz_calcolatore_uno_W14W11P14C9S1
    conv_v2_dz_calcolatore_uno_W14W11P14C9S1 u_dz_calcolatore_uno
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_gradient          (i_gradient[i*9+8:i*9]),
        .i_weight            (i_weight[i*9*1+8:i*9*1]),
        .i_valid             (i_valid[i]),
        .od_data             (pd_uno_data[i*1:i*1]),
        .od_valid            (pd_uno_valid[i])
    );
end
endgenerate

generate
for (i=0; i<1; i++) begin : gen__arithmetic_sum_unovld_sign_W28N16
    arithmetic_sum_unovld_sign_W28N16 u_conv_sum
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (w_data2conv_sum[i*16+15:i*16]),
        .i_valid             (pd_uno_valid[i]),
        .od_data             (pd_csum_data[i]),
        .od_valid            (pd_csum_valid[i])
    );
end
endgenerate
manipolazione_traboccare_1vld_N1W11 u_traboccare
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (w_csum_ecesso),
    .i_valid             (pd_csum_valid[0]),
    .od_data             (od_errore)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_comb
begin
    for (int i=0; i<1; i++) begin
        for (int k=0; k<16; k++) begin
            w_data2conv_sum[i*16+k] = pd_uno_data[k*1+i];
        end
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        if (pd_csum_data[i][31]) begin
            w_data_arrot[i] = $signed(pd_csum_data[i][21:0])+127;
        end
        else begin
            w_data_arrot[i] = $signed(pd_csum_data[i][21:0])+127+1;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (pd_csum_valid[i]) begin
            data[i] <= w_data_arrot[i][21:8];
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        valid[i] <= pd_csum_valid[i];
    end
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        w_csum_ecesso[i] = pd_csum_data[i][31:21];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data[i] = data[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_valid[i] = valid[i];
    end
end

endmodule