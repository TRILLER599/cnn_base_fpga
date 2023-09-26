`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_fully_layer_W14W11W14L0U8P16P1P400P16Y16P3N2M10R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_z[0:0],
    output bit od_z_vld[0:0],
    input  bit [15:0] i_minibatch,
    input  bit [4:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    output bit od_busy,
    input  bit [13:0] i_backprop[0:0],
    input  bit i_backprop_vld[0:0],
    output bit [13:0] od_backprop[0:0],
    output bit od_backprop_vld[0:0],
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit [4:0] od_error
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit const_weight_start = 0;
bit [9:0] minibatch_min1;
bit [3:0] rallentamente;
bit modalita;
bit aggiorntamento;
bit busy;
bit busy_errore;
bit yadro_errore_traboc;
bit [10:0] pd_sep_weight;
bit pd_sep_weight_vld[15:0];
bit pd_sep_weight_start;
bit [13:0] p_i_data[0:0];
bit p_i_data_vld[0:0];
bit p_i_img_end[0:0];
bit [13:0] pd_premutIn_backprop[0:0];
bit pd_premutIn_backprop_vld[0:0];
bit pd_controllo_backfifo_start;
bit pd_controllo_weight_reading;
bit pd_controllo_data_vld;
bit pd_controllo_bufdir_empty;
bit [1:0] pd_controllo_errorre;
bit [13:0] pd_controllo_data[0:0];
bit pd_yadro_img_end[0:0];
bit signed [27:0] pd_yadro_z_backprop[0:0];
bit pd_yadro_z_backprop_vld[0:0];
bit pd_yadro_z_backprop_img_end[0:0];
bit pd_yadro_backfifo_empty[0:0];
bit [10:0] pd_yadro_weight[0:0];
bit pd_yadro_weight_vld[0:0];
bit pd_yadro_err_taboc[0:0];
bit [13:0] pd_backSum_backprop[0:0];
bit pd_backSum_backprop_vld[0:0];
bit pd_backSum_end;
bit pd_backSum_traboc;
bit p_yadro_traboc_uno;
bit rst__pip;
bit rst__l;

fully_cl1_weight_separation_W11O16L400 u_weight_separation
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_weight            (i_weight),
    .i_weight_vld        (i_weight_vld),
    .i_weight_start      (const_weight_start),
    .od_weight           (pd_sep_weight),
    .od_weight_vld       (pd_sep_weight_vld),
    .od_weight_start     (pd_sep_weight_start)
);
fully_cl2_permutazione_diretto_ritardo_W14W14P1P400C16 u_permutazione_in
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_valid             (i_data_vld),
    .od_data             (p_i_data),
    .od_valid            (p_i_data_vld),
    .od_img_end          (p_i_img_end),
    .i_backprop_sum      (pd_backSum_backprop),
    .i_backprop_sum_vld  (pd_backSum_backprop_vld),
    .od_backprop         (pd_premutIn_backprop),
    .od_backprop_vld     (pd_premutIn_backprop_vld)
);
fully_cl3_fully_backprop_controllo_D14P3N2P1P400S1 u_backprop_controllo
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_data              (p_i_data),
    .i_data_vld          (p_i_data_vld),
    .i_img_end           (p_i_img_end[0]),
    .i_minibatch         (i_minibatch),
    .i_aggiorntamento    (i_aggiorntamento),
    .i_backfifo_empty    (pd_yadro_backfifo_empty[0]),
    .od_backfifo_start   (pd_controllo_backfifo_start),
    .od_weight_reading   (pd_controllo_weight_reading),
    .od_data             (pd_controllo_data),
    .od_data_vld         (pd_controllo_data_vld),
    .od_buf_diretto_empty(pd_controllo_bufdir_empty),
    .od_errore           (pd_controllo_errorre)
);

genvar i;
generate
for (i=0;i<1;i++) begin : gen__fully_cl3_yadro_stream_W14W11W14U8P16P14P14P1P400S16M10R8R15
    fully_cl3_yadro_stream_W14W11W14U8P16P14P14P1P400S16M10R8R15 u_yadro
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_data              (p_i_data[0:0]),
        .i_data_vld          (p_i_data_vld[0:0]),
        .i_img_end           (p_i_img_end[0:0]),
        .od_z                (od_z[i]),
        .od_z_vld            (od_z_vld[i]),
        .od_z_img_end        (pd_yadro_img_end[i]),
        .i_minibatch_min1    (minibatch_min1),
        .i_rallentamente     (rallentamente),
        .i_modalita          (modalita),
        .i_aggiorntamento    (aggiorntamento),
        .i_backprop          (i_backprop[i]),
        .i_backprop_vld      (i_backprop_vld[i]),
        .od_backfifo_empty   (pd_yadro_backfifo_empty[i]),
        .i_controllo_backfifo_start(pd_controllo_backfifo_start),
        .i_controllo_weight_reading(pd_controllo_weight_reading),
        .i_controllo_data    (pd_controllo_data),
        .i_controllo_data_vld(pd_controllo_data_vld),
        .od_backprop         (pd_yadro_z_backprop[i*1:i*1]),
        .od_backprop_vld     (pd_yadro_z_backprop_vld[i]),
        .od_backprop_img_end (pd_yadro_z_backprop_img_end[i]),
        .i_weight            (pd_sep_weight),
        .i_weight_vld        (pd_sep_weight_vld[i*16+15:i*16]),
        .i_weight_start      (pd_sep_weight_start),
        .od_weight           (pd_yadro_weight[i]),
        .od_weight_vld       (pd_yadro_weight_vld[i]),
        .od_errore_traboc    (pd_yadro_err_taboc[i])
    );
end
endgenerate
separ_union_mux_std_unsign_W11N1 u_weight_mux
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_yadro_weight[0:0]),
    .i_data_vld          (pd_yadro_weight_vld[0:0]),
    .od_data             (od_weight),
    .od_data_vld         (od_weight_vld)
);
fully_cl3_fully_z_backprop_outsum_W28P1S1W14U8 u_backprop_sum
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (pd_yadro_z_backprop),
    .i_data_vld          (pd_yadro_z_backprop_vld),
    .i_img_end           (pd_yadro_z_backprop_img_end[0]),
    .od_data             (pd_backSum_backprop),
    .od_valid            (pd_backSum_backprop_vld),
    .od_img_end          (pd_backSum_end),
    .od_traboc           (pd_backSum_traboc)
);
base_construct_unari_operator_W1L1or u_yadro_errore_traboc
(
    .clk                 (clk),
    .i_data              (pd_yadro_err_taboc),
    .o_data              (p_yadro_traboc_uno)
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
    if (i_aggiorntamento&~busy) begin
        minibatch_min1 <= i_minibatch-1;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento&~busy) begin
        rallentamente <= (i_rallentamente>15)?15:i_rallentamente;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento&~busy) begin
        modalita <= i_modalita;
    end
end
always_ff @(posedge clk)
begin
    aggiorntamento <= (i_aggiorntamento&!busy);
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    busy <= 0;
end
else begin
    if (i_data_vld[0]) begin
        busy <= 1;
    end
    else if (pd_controllo_bufdir_empty&pd_backSum_backprop_vld[0]&pd_backSum_end) begin
        busy <= 0;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    busy_errore <= 0;
end
else begin
    busy_errore <= (busy&i_aggiorntamento);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    yadro_errore_traboc <= 0;
end
else begin
    yadro_errore_traboc <= p_yadro_traboc_uno;
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop[i] = pd_premutIn_backprop[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop_vld[i] = pd_premutIn_backprop_vld[i];
    end
end
assign od_busy = busy;
assign od_error = {busy_errore,pd_controllo_errorre,pd_backSum_traboc,yadro_errore_traboc};

endmodule