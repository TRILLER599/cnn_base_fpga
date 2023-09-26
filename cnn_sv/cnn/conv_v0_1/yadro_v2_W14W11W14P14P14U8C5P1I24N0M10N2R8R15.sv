`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_yadro_v2_W14W11W14P14P14U8C5P1I24N0M10N2R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[4:0],
    input  bit i_data_vld[0:0],
    input  bit i_str_end[0:0],
    output bit [13:0] od_diretto,
    output bit od_diretto_vld,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    input  bit [13:0] i_zprev[4:0],
    input  bit i_zprev_vld,
    input  bit [13:0] i_gradient,
    input  bit i_gradient_read,
    input  bit i_calc_prec,
    output bit signed [28:0] od_backprop[0:0],
    output bit od_backprop_vld,
    output bit od_dWeight_vld,
    output bit od_errore_filtr,
    output bit od_errore_dw
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] weight[24:0];
bit [9:0] minibatch_min1;
bit [2:0] r_shift;
bit modalita;
bit gradient_vld[0:0];
bit w_weight_load[0:0];
bit signed [28:0] pd_filtr_z[0:0];
bit pd_filtr_z_vld[0:0];
bit w_zprev_vld;
bit w_weight_vld[0:0];
bit [10:0] pd_dWeight[0:0];
bit pd_dWeight_vld[0:0];
bit pd_weight_vld[0:0];
bit pd_errore_dw[0:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<1;i++) begin : gen__conv_v0_1_filtr_W14W11P14C5F29
    conv_v0_1_filtr_W14W11P14C5F29 u_filtr
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (i_data[i*5+4:i*5]),
        .i_data_vld          (i_data_vld[i]),
        .i_str_end           (i_str_end[i]),
        .i_weight            (weight[i*25+24:i*25]),
        .od_z                (pd_filtr_z[i]),
        .od_z_vld            (pd_filtr_z_vld[i])
    );
end
endgenerate
conv_v0_1_combining_features_F29P1R8W14 u_combining
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_filtr_z),
    .i_data_vld          (pd_filtr_z_vld),
    .od_z                (od_diretto),
    .od_z_vld            (od_diretto_vld),
    .od_error            (od_errore_filtr)
);

generate
for (i=0;i<1;i++) begin : gen__conv_v0_1_dw_calcolatrice_preciso_W14W11W14U8P14P14C5I24N0M10N2R8R15
    conv_v0_1_dw_calcolatrice_preciso_W14W11W14U8P14P14C5I24N0M10N2R8R15 u_dw_calcolatrice
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_minibatch_min1    (minibatch_min1),
        .i_r_shift           (r_shift),
        .i_data              (i_zprev[i*5+4:i*5]),
        .i_data_vld          (w_zprev_vld),
        .i_gradiente         (i_gradient),
        .i_grad_valid        (gradient_vld[0]),
        .i_weight            (i_weight),
        .i_weight_vld        (w_weight_vld[i]),
        .od_weight_vld       (pd_weight_vld[i]),
        .od_dWeight          (pd_dWeight[i]),
        .od_dWeight_vld      (pd_dWeight_vld[i]),
        .od_errore_ovrf      (pd_errore_dw[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        minibatch_min1 <= i_minibatch_min1;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        r_shift <= i_rallentamente-8;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        modalita <= i_modalita;
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        w_weight_load[i] = i_weight_vld|pd_dWeight_vld[i];
    end
end
always_ff @(posedge clk)
begin
    if (w_weight_load[1-1]) begin
        weight[24] <= (pd_dWeight_vld[1-1])?pd_dWeight[1-1]:i_weight;
    end
    for (int i=0; i<1; i++) begin
        if (w_weight_load[i]) begin
            for (int k=0; k<24; k++) begin
                weight[i*25+k] <= weight[i*25+k+1];
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_vld[0] <= 0;
end
else begin
    gradient_vld[0] <= i_gradient_read&(!modalita);
end
end
assign w_zprev_vld = i_zprev_vld&(!modalita);
always_comb
begin
    for (int i=0; i<1; i++) begin
        w_weight_vld[i] = i_weight_vld;
    end
end
assign od_weight = pd_dWeight[0];
assign od_weight_vld = pd_weight_vld[0];
assign od_errore_dw = pd_errore_dw[0];
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop[i] = 0;
    end
end
assign od_backprop_vld = 0;
assign od_dWeight_vld = pd_dWeight_vld[0];

endmodule