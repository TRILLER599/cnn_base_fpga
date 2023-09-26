`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module pool_v0_passaggio_diretto_v1_W14C4C1P2L24 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit i_pre_valid,
    input  bit signed [13:0] i_data[1:0],
    input  bit [1:0] i_index[1:0],
    input  bit i_valid[1:0],
    output bit [13:0] od_data[0:0],
    output bit od_valid[0:0],
    output bit [1:0] od_index[1:0],
    output bit od_index_vld[3:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
enum bit[1:0] {WRITE = 2'd0, CONFRONTO = 2'd1, CONSEGNA = 2'd2} fsm;
localparam bit quadrato_count = 0;
bit [4:0] counter_lin;
bit ena_lin;
bit [4:0] addra_lin;
bit [4:0] addrb_lin;
bit [13:0] dia_data[1:0];
bit [1:0] dia_index[1:0];
bit [1:0] valid_index_mux;
bit valid_index[3:0];
bit ena_diretto[1:0];
bit [1:0] diretto_read_a;
bit diretto_read1_a;
bit signed [13:0] data_ipip[1:0];
bit [1:0] index_ipip[1:0];
bit valid_ipip[1:0];
bit last;
bit [13:0] pd_lin_data[1:0];
bit [1:0] pd_lin_index[1:0];
bit w_enb_diretto[1:0];
bit [13:0] pd_diretto_data[1:0];
bit pd_diretto_valid[1:0];
bit pd_diretto_empty[1:0];
bit pd_diretto_wr_ready[1:0];
bit rst__pip;
bit rst__l;

common_distrib_reg_array_O5W14A2 u_linea_data
(
    .clk                 (clk),
    .is0_ena             (ena_lin),
    .is0_addra           (addra_lin),
    .is0_data            (dia_data),
    .is1_enb             (i_pre_valid),
    .is1_addrb           (addrb_lin),
    .od_data             (pd_lin_data)
);
common_distrib_reg_array_O5W2A2 u_linea_index
(
    .clk                 (clk),
    .is0_ena             (ena_lin),
    .is0_addra           (addra_lin),
    .is0_data            (dia_index),
    .is1_enb             (i_pre_valid),
    .is1_addrb           (addrb_lin),
    .od_data             (pd_lin_index)
);

genvar i;
generate
for (i=0;i<2;i++) begin : gen__common_FIFO_L2_O4W14T0
    common_FIFO_L2_O4W14T0 u_diretto_data
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_write             (ena_diretto[i]),
        .i_data              (dia_data[i]),
        .i_read              (w_enb_diretto[i]),
        .od_data             (pd_diretto_data[i]),
        .od_valid            (pd_diretto_valid[i]),
        .od_empty            (pd_diretto_empty[i]),
        .od_wr_ready         (pd_diretto_wr_ready[i])
    );
end
endgenerate

generate
for (i=0;i<1;i++) begin : gen__separ_union_mux_std_unsign_W14N2
    separ_union_mux_std_unsign_W14N2 u_stream_data
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (pd_diretto_data[i*2+1:i*2]),
        .i_data_vld          (pd_diretto_valid[i*2+1:i*2]),
        .od_data             (od_data[i]),
        .od_data_vld         (od_valid[i])
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

always_comb
begin
    for (int i=0; i<2; i++) begin
        data_ipip[i] = i_data[i];
    end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        index_ipip[i] = i_index[i];
    end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        valid_ipip[i] = i_valid[i];
    end
end
assign last = (counter_lin==24-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    counter_lin <= 0;
end
else begin
    if (valid_ipip[0]) begin
        counter_lin <= (last)?0:counter_lin+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    fsm <= WRITE;
end
else begin
    case (fsm)
        WRITE : begin
            if (valid_ipip[0]&last) begin
                fsm <= CONSEGNA;
            end
        end
        CONFRONTO : begin
            if (valid_ipip[0]&last&(quadrato_count==2-2)) begin
                fsm <= CONSEGNA;
            end
        end
        CONSEGNA : begin
            if (valid_ipip[0]&last) begin
                fsm <= WRITE;
            end
        end
    endcase
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena_lin <= 0;
end
else begin
    ena_lin <= valid_ipip[0];
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addra_lin <= 0;
end
else begin
    if (ena_lin) begin
        addra_lin <= (addra_lin==(24-1))?0:addra_lin+1;
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (valid_ipip[i]) begin
            if ((fsm==WRITE)||(data_ipip[i]>$signed(pd_lin_data[i]))) begin
                dia_data[i] <= data_ipip[i];
            end
            else begin
                dia_data[i] <= pd_lin_data[i];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (valid_ipip[i]) begin
            if ((fsm==WRITE)||(data_ipip[i]>$signed(pd_lin_data[i]))) begin
                dia_index[i] <= index_ipip[i];
            end
            else begin
                dia_index[i] <= pd_lin_index[i];
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addrb_lin <= 0;
end
else begin
    if (i_pre_valid) begin
        addrb_lin <= (addrb_lin==(24-1))?0:addrb_lin+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_index[0] <= 0;
    valid_index[1] <= 0;
    valid_index[2] <= 0;
    valid_index[3] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        for (int k=0; k<2; k++) begin
            valid_index[i*2+k] <= ((fsm==CONSEGNA)&&valid_ipip[i])?valid_index_mux[k]:0;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_index_mux <= 1;
end
else begin
    if ((fsm==CONSEGNA)&&valid_ipip[0]) begin
        valid_index_mux <= {valid_index_mux[0:0],valid_index_mux[1]};
    end
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        for (int k=0; k<2; k++) begin
            w_enb_diretto[i*2+k] = diretto_read_a[k];
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena_diretto[0] <= 0;
    ena_diretto[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        ena_diretto[i] <= (fsm==CONSEGNA)?valid_ipip[i]:0;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    diretto_read_a <= 0;
end
else begin
    if (diretto_read1_a==0) begin
        diretto_read_a[2-1:1] <= diretto_read_a[0:0];
        diretto_read_a[0] <= (diretto_read_a[0:0])?0:~pd_diretto_empty[0];
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    diretto_read1_a <= 0;
end
else begin
    if (diretto_read1_a!=0) begin
        diretto_read1_a <= diretto_read1_a-1;
    end
    else if (~pd_diretto_empty[0]|diretto_read_a[0:0]) begin
        diretto_read1_a <= 2-1;
    end
end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        od_index[i] = dia_index[i];
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_index_vld[i] = valid_index[i];
    end
end

endmodule