`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_yadro_stream_W14W11W14U8P16P14P14P1P400S16M10R8R15 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    input  bit i_img_end[0:0],
    output bit [13:0] od_z,
    output bit od_z_vld,
    output bit od_z_img_end,
    input  bit [9:0] i_minibatch_min1,
    input  bit [3:0] i_rallentamente,
    input  bit i_modalita,
    input  bit i_aggiorntamento,
    input  bit [13:0] i_backprop,
    input  bit i_backprop_vld,
    output bit od_backfifo_empty,
    input  bit i_controllo_backfifo_start,
    input  bit i_controllo_weight_reading,
    input  bit [13:0] i_controllo_data[0:0],
    input  bit i_controllo_data_vld,
    output bit signed [27:0] od_backprop[0:0],
    output bit od_backprop_vld,
    output bit od_backprop_img_end,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld[15:0],
    input  bit i_weight_start,
    output bit [10:0] od_weight,
    output bit od_weight_vld,
    output bit od_errore_traboc
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [9:0] minibatch_min1;
bit [3:0] rallentamente;
bit aggiorntamento;
bit [13:0] z;
bit z_vld;
bit z_img_end;
bit z_traboc;
bit backfifo_reading;
bit backfifo_wait_start;
bit backfifo_start;
bit [3:0] backfifo_counter;
bit [13:0] backfifo_data;
bit [10:0] pd_sep_weight[15:0];
bit pd_sep_weight_vld[15:0];
bit pd_sep_weight_start[15:0];
bit weight_vld_2part[15:0];
bit signed [32:0] pd_zpart[0:0];
bit pd_zpart_vld[0:0];
bit pd_zimg_end[0:0];
bit [10:0] pd_weight_part[0:0];
bit pd_weight_part_vld[0:0];
bit pd_z_backprop_vld[0:0];
bit pd_z_backprop_img_end[0:0];
bit signed [14:0] z_arrot;
bit w_backfifo_reading;
bit pd_backfifo_empty;
bit pd_backfifo_wr;
bit [13:0] pd_backfifo_data;
bit rst__pip;
bit rst__l;

function automatic bit func__bit_simile_12(input bit [11:0] i_data);
    func__bit_simile_12 = 0;
    for (int i=1; i<12; i++) begin
        if (i_data[i] != i_data[0])
            func__bit_simile_12 = 1;
    end
endfunction

genvar i;
generate
for (i=0;i<16;i++) begin : gen__fully_cl1_weight_separation_W11O1L400
    fully_cl1_weight_separation_W11O1L400 u_weight_separation
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_weight            (i_weight),
        .i_weight_vld        (i_weight_vld[i]),
        .i_weight_start      (i_weight_start),
        .od_weight           (pd_sep_weight[i]),
        .od_weight_vld       (pd_sep_weight_vld[i*1:i*1]),
        .od_weight_start     (pd_sep_weight_start[i])
    );
end
endgenerate

generate
for (i=0;i<1;i++) begin : gen__fully_cl3_fully_part_flow_W14W11W14U8P16P14P14P400S16M10R8R15
    fully_cl3_fully_part_flow_W14W11W14U8P16P14P14P400S16M10R8R15 u_part
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_data              (i_data[i]),
        .i_data_vld          (i_data_vld[i]),
        .i_img_end           (i_img_end[i]),
        .od_data             (pd_zpart[i]),
        .od_data_vld         (pd_zpart_vld[i]),
        .od_img_end          (pd_zimg_end[i]),
        .i_minibatch_min1    (minibatch_min1),
        .i_rallentamente     (rallentamente),
        .i_modalita          (i_modalita),
        .i_aggiorntamento    (aggiorntamento),
        .i_controllo_weight_reading(i_controllo_weight_reading),
        .i_controllo_data    (i_controllo_data[i]),
        .i_controllo_data_vld(i_controllo_data_vld),
        .i_backprop          (backfifo_data),
        .i_backprop_start    (backfifo_start),
        .od_z_backprop       (od_backprop[i]),
        .od_z_backprop_vld   (pd_z_backprop_vld[i]),
        .od_z_backprop_img_end(pd_z_backprop_img_end[i]),
        .i_weight            (pd_sep_weight[0]),
        .i_weight_vld        (weight_vld_2part[i*16+15:i*16]),
        .i_weight_start      (pd_sep_weight_start[0]),
        .od_weight           (pd_weight_part[i]),
        .od_weight_vld       (pd_weight_part_vld[i])
    );
end
endgenerate
common_FIFO_FastD_O5W14T30 u_backprop_fifo
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_backprop_vld),
    .i_data              (i_backprop),
    .i_read              (w_backfifo_reading),
    .od_data             (pd_backfifo_data),
    .od_empty            (pd_backfifo_empty),
    .od_wr_ready         (pd_backfifo_wr)
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
    if (i_aggiorntamento) begin
        minibatch_min1 <= i_minibatch_min1;
    end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        rallentamente <= i_rallentamente;
    end
end
always_ff @(posedge clk)
begin
    aggiorntamento <= i_aggiorntamento;
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        for (int k=0; k<16; k++) begin
            weight_vld_2part[i*16+k] = pd_sep_weight_vld[k*1+i];
        end
    end
end
assign z_arrot = $signed(pd_zpart[0][32:7])+1;
always_ff @(posedge clk)
begin
    z <= z_arrot[14:1];
end
always_ff @(posedge clk)
begin
    z_vld <= pd_zpart_vld[0];
end
always_ff @(posedge clk)
begin
    z_img_end <= pd_zimg_end[0];
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    z_traboc <= 0;
end
else begin
    z_traboc <= func__bit_simile_12(pd_zpart[0][32:21])&pd_zpart_vld[0];
end
end
assign od_weight = pd_weight_part[0];
assign od_weight_vld = pd_weight_part_vld[0];
always_comb
begin
    if ((i_data_vld[0]&backfifo_wait_start&~pd_backfifo_empty)|i_controllo_backfifo_start) begin
        w_backfifo_reading = 1;
    end
    else begin
        w_backfifo_reading = (backfifo_reading)?~(backfifo_counter==(16-1)):0;
    end
end
always_ff @(posedge clk)
begin
    if ((i_data_vld[0]&backfifo_wait_start&~pd_backfifo_empty)|i_controllo_backfifo_start) begin
        backfifo_start <= 1;
    end
    else begin
        backfifo_start <= 0;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    backfifo_wait_start <= 1;
end
else begin
    backfifo_wait_start <= (i_data_vld[0])?i_img_end[0]:backfifo_wait_start;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    backfifo_counter <= 0;
end
else begin
    if (i_data_vld[0]&backfifo_wait_start&~pd_backfifo_empty) begin
        backfifo_counter <= 0;
    end
    else begin
        backfifo_counter <= (backfifo_reading)?backfifo_counter+1:backfifo_counter;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    backfifo_reading <= 0;
end
else begin
    backfifo_reading <= w_backfifo_reading;
end
end
always_ff @(posedge clk)
begin
    backfifo_data <= pd_backfifo_data;
end
assign od_z = z;
assign od_z_vld = z_vld;
assign od_z_img_end = z_img_end;
assign od_backfifo_empty = pd_backfifo_empty;
assign od_backprop_vld = pd_z_backprop_vld[0];
assign od_backprop_img_end = pd_z_backprop_img_end[0];
assign od_errore_traboc = z_traboc;

endmodule