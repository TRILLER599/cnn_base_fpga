`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_fully_dw_calcolatrice_W14W11W14U8P16P400S16M10R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_aggiorntamento,
    input  bit [13:0] i_data,
    input  bit i_data_vld,
    input  bit [13:0] i_gradiente,
    input  bit i_grad_start,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld[15:0],
    output bit [10:0] od_weight[15:0],
    output bit od_weight_vld[15:0],
    output bit od_traboc
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit batch_ultimo_l4;
bit [8:0] addra_load;
bit [8:0] addra_aggiorn;
bit [8:0] addra[15:0];
bit [8:0] addrb;
bit [9:0] batch_counter;
bit batch_ultimo;
bit [1:0] aggiorntamento;
bit s_ultimo_data[15:0];
bit s_ultimo_grad[15:0];
bit r_shift_en;
bit [2:0] r_shift;
bit [6:0] arrot_piu;
bit [6:0] arrot_meno;
bit signed [27:0] dw_current[15:0];
bit signed [27:0] peso_preciso[15:0];
bit [10:0] weight_load;
bit weight_load_vld[15:0];
bit [10:0] weight[15:0];
bit weight_vld[15:0];
bit p_data_vld[20:0];
bit p_grad_start[15:0];
bit pd_batch_ultimo_l5[15:0];
bit mem_read[15:0];
bit mem_read_1d[15:0];
bit [8:0] p_addrb[15:0];
bit p_in_weight_1vld;
bit mem_write[15:0];
bit [26:0] mem_dia[15:0];
bit [26:0] pd_mem_dob[15:0];
bit [2:0] r_shift_meno1;
bit signed [13:0] sign_data;
bit sign_data_en[15:0];
bit signed [13:0] sign_gradiente;
bit arrot_en[15:0];
bit w_sign_mult[15:0];
bit signed [7:0] arrot_curr[15:0];
bit signed [27:0] pd_dw_current[15:0];
bit [1:0] w_peso_traboc[15:0];
bit [11:0] w_weight[15:0];
bit rst__pip;
bit rst__l;

function automatic bit [7:0] func__int2std_3(input bit [2:0] i_data);
    func__int2std_3 = 1<<i_data;
endfunction

shift_uwire_multi_W1L21R1 u_data_vld_sh
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data_vld),
    .o_data              (p_data_vld)
);
shift_uwire_multi_W1L16R0 u_grad_start_sh
(
    .clk                 (clk),
    .i_data              (i_grad_start),
    .o_data              (p_grad_start)
);
shift_ureg_multi_W1L16D0R1 u_batch_ultimo
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (batch_ultimo_l4),
    .od_data             (pd_batch_ultimo_l5)
);
shift_uwire_multi_W9L16R0 u_opensh_addrb
(
    .clk                 (clk),
    .i_data              (addrb),
    .o_data              (p_addrb)
);
base_construct_unari_operator_W1L16or u_weight_load_1vld
(
    .clk                 (clk),
    .i_data              (i_weight_vld),
    .o_data              (p_in_weight_1vld)
);

genvar i;
generate
for (i=0;i<16;i++) begin : gen__common_bram_reg_O9W27
    common_bram_reg_O9W27 u_mem_weight
    (
        .clk                 (clk),
        .is0_ena             (mem_write[i]),
        .is0_addra           (addra[i]),
        .is0_data            (mem_dia[i]),
        .is1_enb             (mem_read[i]),
        .is1_addrb           (p_addrb[i]),
        .i_enb_reg           (mem_read_1d[i]),
        .od_ram              (pd_mem_dob[i])
    );
end
endgenerate
fully_cl3_dw_arrot_dsp_W14W14S16W8 u_dw_curr
(
    .clk                 (clk),
    .i_data              (sign_data),
    .i_data_en           (sign_data_en),
    .i_grad              (sign_gradiente),
    .i_grad_en           (p_grad_start),
    .i_arrot             (arrot_curr),
    .i_arrot_vld         (arrot_en),
    .od_data             (pd_dw_current)
);
manipolazione_traboccare_1vld_N16W2 u_traboccare
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (w_peso_traboc),
    .i_valid             (p_data_vld[5]),
    .od_data             (od_traboc)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk)
begin
if (rst__l) begin
    batch_counter <= 0;
end
else begin
    if (p_data_vld[2]&&(addrb==0)) begin
        batch_counter <= (batch_counter==i_minibatch_min1)?0:batch_counter+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    batch_ultimo <= 0;
end
else begin
    if (p_data_vld[2]&&(addrb==0)) begin
        batch_ultimo <= (batch_counter==i_minibatch_min1);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    batch_ultimo_l4 <= 0;
end
else begin
    batch_ultimo_l4 <= batch_ultimo&p_data_vld[3];
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        mem_read[i] = p_data_vld[i+2];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        mem_read_1d[i] = p_data_vld[i+3];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addrb <= 0;
end
else begin
    if (mem_read[0]) begin
        addrb <= (addrb==400-1)?0:addrb+1;
    end
end
end
always_ff @(posedge clk)
begin
    weight_load <= i_weight;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_load_vld[0] <= 0;
    weight_load_vld[1] <= 0;
    weight_load_vld[2] <= 0;
    weight_load_vld[3] <= 0;
    weight_load_vld[4] <= 0;
    weight_load_vld[5] <= 0;
    weight_load_vld[6] <= 0;
    weight_load_vld[7] <= 0;
    weight_load_vld[8] <= 0;
    weight_load_vld[9] <= 0;
    weight_load_vld[10] <= 0;
    weight_load_vld[11] <= 0;
    weight_load_vld[12] <= 0;
    weight_load_vld[13] <= 0;
    weight_load_vld[14] <= 0;
    weight_load_vld[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        weight_load_vld[i] <= i_weight_vld[i];
    end
end
end
always_ff @(posedge clk)
begin
    if (p_in_weight_1vld) begin
        addra_load <= (addra_load==400-1)?0:addra_load+1;
    end
end
always_ff @(posedge clk)
begin
    if (p_data_vld[4]) begin
        addra_aggiorn <= (addra_aggiorn==400-1)?0:addra_aggiorn+1;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addra[0] <= 0;
    addra[1] <= 0;
    addra[2] <= 0;
    addra[3] <= 0;
    addra[4] <= 0;
    addra[5] <= 0;
    addra[6] <= 0;
    addra[7] <= 0;
    addra[8] <= 0;
    addra[9] <= 0;
    addra[10] <= 0;
    addra[11] <= 0;
    addra[12] <= 0;
    addra[13] <= 0;
    addra[14] <= 0;
    addra[15] <= 0;
end
else begin
    addra[0] <= (i_weight_vld[0])?addra_load:addra_aggiorn;
    for (int i=1; i<16; i++) begin
        addra[i] <= (i_weight_vld[i])?addra_load:addra[i-1];
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        mem_write[i] = p_data_vld[i+5]|weight_load_vld[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        if (weight_load_vld[i]) begin
            mem_dia[i][27-1:16] = weight_load;
            mem_dia[i][16-1:0] = 0;
        end
        else begin
            mem_dia[i] = peso_preciso[i][26:0];
        end
    end
end
always_ff @(posedge clk)
begin
    aggiorntamento <= {aggiorntamento[0],i_aggiorntamento};
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        if (i_rallentamente>(16-8)) begin
            r_shift <= i_rallentamente-(16-8);
        end
        else begin
            r_shift <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        if (i_rallentamente>(16-8)) begin
            r_shift_en <= 1;
        end
        else begin
            r_shift_en <= 0;
        end
    end
end
assign r_shift_meno1 = r_shift-1;
always_ff @(posedge clk)
begin
    if (aggiorntamento[0]) begin
        if (r_shift_en) begin
            arrot_piu <= func__int2std_3(r_shift_meno1);
        end
        else begin
            arrot_piu <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
    if (aggiorntamento[1]) begin
        arrot_meno <= (r_shift_en)?arrot_piu-1:0;
    end
end
assign sign_data = i_data;
assign sign_gradiente = i_gradiente;
always_comb
begin
    for (int i=0; i<16; i++) begin
        sign_data_en[i] = p_data_vld[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        arrot_en[i] = p_data_vld[i+1];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (p_grad_start[i]) begin
            s_ultimo_grad[i] <= i_gradiente[13];
        end
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        w_sign_mult[i] = s_ultimo_data[i]^s_ultimo_grad[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        arrot_curr[i] = (w_sign_mult[i])?{1'd0, arrot_meno}:{1'd0, arrot_piu};
    end
end
always_ff @(posedge clk)
begin
    s_ultimo_data[0] <= (sign_data_en[0])?i_data[13]:s_ultimo_data[0];
    for (int i=1; i<16; i++) begin
        s_ultimo_data[i] <= (sign_data_en[i])?s_ultimo_data[i-1]:s_ultimo_data[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (p_data_vld[i+3]) begin
            dw_current[i] <= pd_dw_current[i]>>>r_shift;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (p_data_vld[i+4]) begin
            peso_preciso[i] <= $signed(pd_mem_dob[i])+dw_current[i];
        end
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        w_peso_traboc[i] = peso_preciso[i][27:26];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        w_weight[i] = peso_preciso[i][26:15]+1;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        if (pd_batch_ultimo_l5[i]) begin
            weight[i] <= w_weight[i][11:1];
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_vld[0] <= 0;
    weight_vld[1] <= 0;
    weight_vld[2] <= 0;
    weight_vld[3] <= 0;
    weight_vld[4] <= 0;
    weight_vld[5] <= 0;
    weight_vld[6] <= 0;
    weight_vld[7] <= 0;
    weight_vld[8] <= 0;
    weight_vld[9] <= 0;
    weight_vld[10] <= 0;
    weight_vld[11] <= 0;
    weight_vld[12] <= 0;
    weight_vld[13] <= 0;
    weight_vld[14] <= 0;
    weight_vld[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        weight_vld[i] <= pd_batch_ultimo_l5[i];
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_weight[i] = weight[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_weight_vld[i] = weight_vld[i];
    end
end

endmodule