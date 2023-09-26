`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_dw_calcolatore_precizo_W14W11W14U8P14P14C3C4I12M10R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_gradient_l4[8:0],
    input  bit [13:0] i_zprev_l4,
    input  bit i_valid_l4,
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_aggiorntamento,
    input  bit [10:0] i_weight,
    input  bit [8:0] i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit [10:0] od_dWeight[8:0],
    output bit od_dWeight_vld,
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [6:0] const_zero = 0;
localparam bit [22:0] const_in_weigh_zero = 0;
bit valid_l5;
bit valid_l6;
bit valid_l7;
bit valid_l8;
bit [9:0] minibatch_min1;
bit [2:0] r_shift;
bit signed [13:0] gradient[8:0];
bit signed [13:0] zprev;
bit signed [27:0] molt[8:0];
bit signed [33:0] molt_rallentato[8:0];
bit [1:0] count_compress;
bit compress_end;
bit [7:0] count_pixel;
bit pixel_end;
bit [9:0] count_minib;
bit minib_end;
bit signed [34:0] somma[8:0];
bit [10:0] dWeight[8:0];
bit weight_vld_l8;
bit dWeight_vld;
bit [1:0] addra;
bit [1:0] addrb;
bit weight_vld[2:0];
bit [3:0] weight_vld_int[2:0];
bit signed [33:0] w_molt_lungo[8:0];
bit [33:0] w_weight_preciso;
bit w_ena_Pesi[8:0];
bit w_enb_Pesi[8:0];
bit [33:0] w_dia_Pesi[8:0];
bit [33:0] pd_Pesi_dob[8:0];
bit [11:0] w_weight_arrot[8:0];
bit [3:0] w_weight_vld_int;
bit [1:0] w_controllo_traboc[8:0];
bit rst__pip;
bit rst__l;

function automatic bit [3:0] func__stbit_piu1_9(input bit [8:0] i_data);
    func__stbit_piu1_9 = 0;
    for (int i=0; i<9; i++) begin
        if (i_data[i])
            func__stbit_piu1_9 = i+1;
    end
endfunction

genvar i;
generate
for (i=0; i<9; i++) begin : gen__common_distrib_reg_O2W34
    common_distrib_reg_O2W34 u_pesi_mem
    (
        .clk                 (clk),
        .i_ena               (w_ena_Pesi[i]),
        .i_addra             (addra),
        .i_data              (w_dia_Pesi[i]),
        .i_enb               (w_enb_Pesi[i]),
        .i_addrb             (addrb),
        .od_ram              (pd_Pesi_dob[i])
    );
end
endgenerate
separ_union_mux_int_vld_unsign_W11N9 u_weight_scarico
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (dWeight),
    .i_valid             (weight_vld[2]),
    .i_mux               (weight_vld_int[2]),
    .od_data             (od_weight),
    .od_valid            (od_weight_vld)
);
manipolazione_traboccare_1vld_N9W2 u_traboccare
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (w_controllo_traboc),
    .i_valid             (valid_l8),
    .od_data             (od_errore)
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
    valid_l5 <= 0;
end
else begin
    valid_l5 <= i_valid_l4;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_l6 <= 0;
end
else begin
    valid_l6 <= valid_l5;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_l7 <= 0;
end
else begin
    valid_l7 <= valid_l6;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_l8 <= 0;
end
else begin
    valid_l8 <= valid_l7;
end
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
if (rst__l) begin
    count_compress <= 0;
end
else begin
    if (valid_l7) begin
        count_compress <= (compress_end)?0:count_compress+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compress_end <= 0;
end
else begin
    if (valid_l7) begin
        compress_end <= (count_compress==4-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_pixel <= 0;
end
else begin
    if (valid_l7) begin
        if (compress_end) begin
            count_pixel <= (pixel_end)?0:count_pixel+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pixel_end <= 0;
end
else begin
    if (valid_l7) begin
        if (compress_end) begin
            pixel_end <= (count_pixel==144-2);
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_minib <= 0;
end
else begin
    if (valid_l7) begin
        if (compress_end&pixel_end) begin
            count_minib <= (minib_end)?0:count_minib+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    minib_end <= 0;
end
else begin
    minib_end <= (count_minib==minibatch_min1);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_vld_l8 <= 0;
end
else begin
    weight_vld_l8 <= pixel_end&minib_end&valid_l7;
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (i_valid_l4) begin
            gradient[i] <= i_gradient_l4[9-i-1];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (i_valid_l4) begin
            zprev <= i_zprev_l4;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (valid_l5) begin
            molt[i] <= gradient[i]*zprev;
        end
    end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_molt_lungo[i] = $signed({molt[i][26:0],const_zero});
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (valid_l6) begin
            molt_rallentato[i] <= w_molt_lungo[i]>>>r_shift;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (valid_l7||weight_vld[0]) begin
            if (valid_l7) begin
                somma[i] <= $signed(pd_Pesi_dob[i])+molt_rallentato[i];
            end
            else begin
                somma[i] <= $signed(pd_Pesi_dob[i]);
            end
        end
    end
end
assign w_weight_preciso = {i_weight,const_in_weigh_zero};
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_ena_Pesi[i] = valid_l8|i_weight_vld[i];
    end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_dia_Pesi[i] = (valid_l8)?somma[i][33:0]:w_weight_preciso;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addra <= 0;
end
else begin
    if (valid_l8|i_weight_vld[8]) begin
        addra <= (addra==4-1)?0:addra+1;
    end
end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_enb_Pesi[i] = valid_l6|i_weight_vld[i];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addrb <= 0;
end
else begin
    if (valid_l6|i_weight_vld[8]) begin
        addrb <= (addrb==4-1)?0:addrb+1;
    end
end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_weight_arrot[i] = somma[i][33:22]+1;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<9; i++) begin
        if (weight_vld_l8||weight_vld[1]) begin
            dWeight[i] <= w_weight_arrot[i][11:1];
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    dWeight_vld <= 0;
end
else begin
    dWeight_vld <= weight_vld_l8;
end
end
assign w_weight_vld_int = func__stbit_piu1_9(i_weight_vld);
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_vld[0] <= 0;
    weight_vld[1] <= 0;
    weight_vld[2] <= 0;
end
else begin
    weight_vld[0] <= |i_weight_vld;
    weight_vld[1] <= weight_vld[0];
    weight_vld[2] <= weight_vld[1];
end
end
always_ff @(posedge clk)
begin
    weight_vld_int[0] <= w_weight_vld_int-1;
    weight_vld_int[1] <= weight_vld_int[0];
    weight_vld_int[2] <= weight_vld_int[1];
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        w_controllo_traboc[i] = somma[i][34:33];
    end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        od_dWeight[i] = dWeight[i];
    end
end
assign od_dWeight_vld = dWeight_vld;

endmodule