`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module ferrore_funzione_errore_tf_W14C16S1S16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    input  bit i_start,
    input  bit [3:0] i_index,
    input  bit [15:0] i_rilevanza,
    output bit od_vero,
    output bit od_falso
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [15:0] rilevanza;
bit start;
bit signed [13:0] data[0:0];
bit valid[0:0];
bit [3:0] len_counter;
bit signed [13:0] piu[0:0];
bit [3:0] piu_l_index[0:0];
bit piu_rilevanza[0:0];
bit piu_vld[0:0];
bit [3:0] piu_index;
bit vero;
bit falso;
bit w_ena;
bit pd_vindex_vld;
bit pd_empty;
bit pd_wr_ready;
bit [3:0] pd_vindex;
bit w_stop;
bit signed [13:0] pd_piu;
bit pd_piu_inum;
bit pd_piu_vld;
bit [3:0] pd_piu_l_index;
bit w_vero;

common_FIFO_L1D_O5W4T0 u_index_l1
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_write             (w_ena),
    .i_data              (i_index),
    .i_read              (pd_piu_vld),
    .od_data             (pd_vindex),
    .od_valid            (pd_vindex_vld),
    .od_empty            (pd_empty),
    .od_wr_ready         (pd_wr_ready)
);
separ_union_max_std_sign_extu_W14N1E4 u_piu_uno
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (piu),
    .i_valid             (piu_vld),
    .i_ext               (piu_l_index),
    .od_data             (pd_piu),
    .od_index            (pd_piu_inum),
    .od_valid            (pd_piu_vld),
    .od_extend           (pd_piu_l_index)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_data_vld[0]) begin
        if (i_start) begin
            rilevanza <= i_rilevanza;
        end
        else begin
            for (int i=0; i<15; i++) begin
                rilevanza[i] <= rilevanza[i+1];
            end
            rilevanza[16-1] <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    start <= 0;
end
else begin
    if (i_data_vld[0]) begin
        start <= i_start;
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        data[i] <= i_data[i];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        valid[i] <= i_data_vld[i];
    end
end
end
assign w_ena = i_data_vld[0]&i_start;
assign w_stop = (len_counter==16-1);
always_ff @(posedge clk)
begin
if (i_rst) begin
    len_counter <= 0;
end
else begin
    if (valid[0]) begin
        len_counter <= (w_stop)?0:len_counter+1;
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (valid[i]) begin
            if (start) begin
                piu[i] <= data[i];
            end
            else begin
                if (rilevanza[i*16]) begin
                    if (data[i]>piu[i]) begin
                        piu[i] <= data[i];
                    end
                end
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (valid[i]) begin
            if (start) begin
                piu_l_index[i] <= len_counter;
            end
            else begin
                if (rilevanza[i*16]) begin
                    if (data[i]>piu[i]) begin
                        piu_l_index[i] <= len_counter;
                    end
                end
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (valid[i]) begin
            if (start) begin
                piu_rilevanza[i] <= rilevanza[i*16];
            end
            else begin
                piu_rilevanza[i] <= piu_rilevanza[i]|rilevanza[i*16];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        piu_vld[i] <= valid[i]&w_stop&(piu_rilevanza[i]|rilevanza[i*16]);
    end
end
always_ff @(posedge clk)
begin
    if (pd_piu_vld) begin
        piu_index <= (pd_piu_inum<<<4)+pd_piu_l_index;
    end
end
assign w_vero = (piu_index==pd_vindex);
always_ff @(posedge clk)
begin
if (i_rst) begin
    vero <= 0;
end
else begin
    vero <= pd_vindex_vld&w_vero;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    falso <= 0;
end
else begin
    falso <= pd_vindex_vld&(~w_vero);
end
end
assign od_vero = vero;
assign od_falso = falso;

endmodule