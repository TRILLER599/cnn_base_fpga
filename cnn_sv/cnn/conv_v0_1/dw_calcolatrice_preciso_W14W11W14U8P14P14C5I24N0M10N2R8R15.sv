`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_dw_calcolatrice_preciso_W14W11W14U8P14P14C5I24N0M10N2R8R15 (
    input  bit clk,
    input  bit i_rst,
    input  bit [9:0] i_minibatch_min1,
    input  bit [2:0] i_r_shift,
    input  bit [13:0] i_data[4:0],
    input  bit i_data_vld,
    input  bit [13:0] i_gradiente,
    input  bit i_grad_valid,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit od_weight_vld,
    output bit [10:0] od_dWeight,
    output bit od_dWeight_vld,
    output bit od_errore_ovrf
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit data_vld;
bit grad_valid[2:0];
bit [9:0] grad_counter;
bit grad_wait_start;
bit grad_start;
bit grad_primo;
bit [4:0] waigth_en;
bit [4:0] waigth_counter;
bit [2:0] waigth_en_primo;
bit [9:0] batch_counter;
bit end_batch;
bit signed [41:0] img_rallentato;
bit signed [34:0] peso_prec;
bit ena_Pesi;
bit enb_Pesi;
bit [4:0] addra;
bit [4:0] addrb;
bit [2:0] weight_vld;
bit [10:0] dWeight;
bit [1:0] dWeight_vld;
bit errore_ovrf;
bit w_grad_last;
bit mult_en_dsp;
bit cmd_en_dsp;
bit sum_sh_en_dsp;
bit [1:0] cmd_dsp;
bit signed [34:0] pd_dsp_data;
bit signed [13:0] p_data_lungo_sign[24:0];
bit signed [13:0] sign_gradiente;
bit signed [41:0] w_img_lungo;
bit [33:0] w_dia_Pesi;
bit [33:0] pd_Pesi_dob;
bit [11:0] w_dWeight;

shift_wire_array_ext_u2s_vld_W14A5E4I1D0R0 u_data_shift
(
    .clk                 (clk),
    .i_data              (i_data),
    .i_valid             (data_vld),
    .o_data              (p_data_lungo_sign)
);
conv_v0_1_dw_dsp_D14W14C5S35 u_dsp
(
    .clk                 (clk),
    .i_data              (p_data_lungo_sign),
    .i_data_en           (data_vld),
    .i_grad              (sign_gradiente),
    .i_grad_en           (grad_valid[0]),
    .i_mult_en           (mult_en_dsp),
    .i_cmd_en            (cmd_en_dsp),
    .i_cmd               (cmd_dsp),
    .i_sum_sh_en         (sum_sh_en_dsp),
    .od_data             (pd_dsp_data)
);
common_distrib_reg_O5W34 u_pesi_mem
(
    .clk                 (clk),
    .i_ena               (ena_Pesi),
    .i_addra             (addra),
    .i_data              (w_dia_Pesi),
    .i_enb               (enb_Pesi),
    .i_addrb             (addrb),
    .od_ram              (pd_Pesi_dob)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_vld <= 0;
end
else begin
    data_vld <= i_data_vld;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    grad_valid[0] <= 0;
    grad_valid[1] <= 0;
    grad_valid[2] <= 0;
end
else begin
    grad_valid[0] <= i_grad_valid;
    grad_valid[1] <= grad_valid[0];
    grad_valid[2] <= grad_valid[1];
end
end
assign w_grad_last = (grad_counter==(576-1));
always_ff @(posedge clk)
begin
if (i_rst) begin
    grad_counter <= 0;
end
else begin
    if (grad_valid[0]) begin
        grad_counter <= (w_grad_last)?0:grad_counter+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    grad_wait_start <= 1;
end
else begin
    if (grad_valid[0]) begin
        grad_wait_start <= w_grad_last;
    end
end
end
always_ff @(posedge clk)
begin
    grad_start <= grad_wait_start&grad_valid[0];
end
always_ff @(posedge clk)
begin
    grad_primo <= grad_start;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    waigth_en <= 0;
end
else begin
    if (grad_valid[0]&w_grad_last) begin
        waigth_en[0] <= 1;
    end
    else begin
        waigth_en[0] <= (waigth_en[0])?~(waigth_counter==(25-1)):0;
    end
    waigth_en[4:1] <= waigth_en[3:0];
end
end
always_ff @(posedge clk)
begin
    if (waigth_en[0]&~(waigth_counter==(25-1))) begin
        waigth_counter <= waigth_counter+1;
    end
    else begin
        waigth_counter <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    waigth_en_primo <= 0;
end
else begin
    waigth_en_primo <= (waigth_en_primo<<<1)|(grad_valid[0]&w_grad_last);
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    batch_counter <= 0;
end
else begin
    if (waigth_en_primo[2]) begin
        batch_counter <= (batch_counter==i_minibatch_min1)?0:batch_counter+1;
    end
end
end
always_ff @(posedge clk)
begin
    if (waigth_en_primo[2]) begin
        end_batch <= (batch_counter==i_minibatch_min1);
    end
end
assign mult_en_dsp = grad_valid[1];
assign cmd_en_dsp = grad_start|grad_primo|waigth_en_primo[1];
always_comb
begin
    if (waigth_en_primo[1]) begin
        cmd_dsp = 2;
    end
    else if (grad_primo) begin
        cmd_dsp = 1;
    end
    else begin
        cmd_dsp = 0;
    end
end
assign sum_sh_en_dsp = grad_valid[2]|waigth_en[2];
assign sign_gradiente = i_gradiente;
assign w_img_lungo = pd_dsp_data<<<7;
always_ff @(posedge clk)
begin
    if (waigth_en[2]) begin
        img_rallentato <= w_img_lungo>>>i_r_shift;
    end
end
always_ff @(posedge clk)
begin
    if (waigth_en[3]) begin
        peso_prec <= $signed(pd_Pesi_dob)+img_rallentato;
    end
    else if (i_weight_vld) begin
        peso_prec[34-1:34-11] <= i_weight;
        peso_prec[34-11-1:0] <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ena_Pesi <= 0;
end
else begin
    ena_Pesi <= waigth_en[3]|i_weight_vld;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_Pesi <= 0;
end
else begin
    enb_Pesi <= waigth_en[1]|i_weight_vld;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra <= 0;
end
else begin
    if (ena_Pesi) begin
        addra <= (addra==25-1)?0:addra+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb <= 0;
end
else begin
    if (enb_Pesi) begin
        addrb <= (addrb==25-1)?0:addrb+1;
    end
end
end
assign w_dia_Pesi = peso_prec;
always_ff @(posedge clk)
begin
if (i_rst) begin
    weight_vld <= 0;
end
else begin
    weight_vld <= (weight_vld<<<1)|i_weight_vld;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    dWeight_vld <= 0;
end
else begin
    dWeight_vld <= (dWeight_vld<<<1)|(waigth_en[3]&end_batch);
end
end
always_comb
begin
    if (dWeight_vld[0]) begin
        w_dWeight = peso_prec[33:22]+1;
    end
    else begin
        w_dWeight = pd_Pesi_dob[33:22]+1;
    end
end
always_ff @(posedge clk)
begin
    if (dWeight_vld[0]||weight_vld[1]) begin
        dWeight <= w_dWeight[11:1];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    errore_ovrf <= 0;
end
else begin
    if (waigth_en[4]) begin
        errore_ovrf <= errore_ovrf||(^peso_prec[34:33]);
    end
end
end
assign od_weight_vld = weight_vld[2];
assign od_dWeight = dWeight;
assign od_dWeight_vld = dWeight_vld[1];
assign od_errore_ovrf = errore_ovrf;

endmodule