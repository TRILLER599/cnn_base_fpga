`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module ferrore_funzione_errore_W14L0C16S16R10 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_backprop[0:0],
    output bit od_backprop_vld[0:0],
    input  bit [13:0] i_Y,
    input  bit i_Y_vld,
    input  bit [15:0] i_index,
    input  bit i_index_vld,
    input  bit [15:0] i_class_num,
    input  bit i_class_num_vld,
    input  bit [7:0] i_mux_funzione,
    output bit od_vero,
    output bit od_falso,
    output bit od_error
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] Yl;
bit [13:0] Yhn;
bit [13:0] Yhp;
bit [13:0] Ylm;
bit [13:0] Y_limit;
bit [2:0] addr_Y;
bit start;
bit [3:0] counter_len;
bit class_num_vld;
bit [3:0] class_num_meno1;
bit [15:0] rilevanza;
bit [1:0] mux_funzione;
bit [13:0] ferr_data[0:0];
bit ferr_valid[0:0];
bit error;
bit [3:0] w_index_clnum;
bit read_buf;
bit pd_buf_empty;
bit pd_buf_wr_ready;
bit [3:0] pd_buf_index;
bit [15:0] maschera;
bit [13:0] pd_2soglie_data[0:0];
bit pd_2soglie_valid[0:0];
bit [13:0] pd_2soglieLim_data[0:0];
bit pd_2soglieLim_valid[0:0];
bit [13:0] pd_4soglie_data[0:0];
bit pd_4soglie_valid[0:0];
bit [13:0] pd_4soglieLim_data[0:0];
bit pd_4soglieLim_valid[0:0];
bit rst__pip;
bit rst__l;

function automatic bit [15:0] func__int2std_4(input bit [3:0] i_data);
    func__int2std_4 = 1<<i_data;
endfunction

common_FIFO_Fast_O10W4T0 u_index_buf
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_index_vld),
    .i_data              (w_index_clnum),
    .i_read              (read_buf),
    .od_data             (pd_buf_index),
    .od_empty            (pd_buf_empty),
    .od_wr_ready         (pd_buf_wr_ready)
);
ferrore_ferr_2soglie_W14C16S1S16 u_2soglie
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .i_start             (start),
    .i_maschera          (maschera),
    .i_Yhn               (Yhn),
    .i_Yl                (Yl),
    .i_rilevanza         (rilevanza),
    .od_data             (pd_2soglie_data),
    .od_data_vld         (pd_2soglie_valid)
);
ferrore_ferr_2soglie_limitato_W14C16S1S16 u_2soglieLim
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .i_start             (start),
    .i_maschera          (maschera),
    .i_Y1                (Yhn),
    .i_Y0                (Yl),
    .i_Y_limit           (Y_limit),
    .i_rilevanza         (rilevanza),
    .od_data             (pd_2soglieLim_data),
    .od_data_vld         (pd_2soglieLim_valid)
);
ferrore_ferr_4soglie_W14C16S1S16 u_4soglie
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .i_start             (start),
    .i_maschera          (maschera),
    .i_Y2                (Yhp),
    .i_Y1                (Yhn),
    .i_Y0                (Yl),
    .i_Y0m               (Ylm),
    .i_rilevanza         (rilevanza),
    .od_data             (pd_4soglie_data),
    .od_data_vld         (pd_4soglie_valid)
);
ferrore_ferr_4soglie_limitato_W14C16S1S16 u_4soglieLim
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .i_start             (start),
    .i_maschera          (maschera),
    .i_Y2                (Yhp),
    .i_Y1                (Yhn),
    .i_Y0                (Yl),
    .i_Y0m               (Ylm),
    .i_Y_limit           (Y_limit),
    .i_rilevanza         (rilevanza),
    .od_data             (pd_4soglieLim_data),
    .od_data_vld         (pd_4soglieLim_valid)
);
ferrore_funzione_errore_tf_W14C16S1S16 u_vero_falso
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_data_vld          (i_data_vld),
    .i_start             (start),
    .i_index             (pd_buf_index),
    .i_rilevanza         (rilevanza),
    .od_vero             (od_vero),
    .od_falso            (od_falso)
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
    if (i_Y_vld) begin
        addr_Y <= (addr_Y==7)?addr_Y:addr_Y+1;
    end
    else begin
        addr_Y <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (i_Y_vld) begin
        Yl <= (addr_Y==0)?i_Y:Yl;
    end
end
always_ff @(posedge clk)
begin
    if (i_Y_vld) begin
        Yhn <= (addr_Y==1)?i_Y:Yhn;
    end
end
always_ff @(posedge clk)
begin
    if (i_Y_vld) begin
        Yhp <= (addr_Y==2)?i_Y:Yhp;
    end
end
always_ff @(posedge clk)
begin
    if (i_Y_vld) begin
        Ylm <= (addr_Y==3)?i_Y:Ylm;
    end
end
always_ff @(posedge clk)
begin
    if (i_Y_vld) begin
        Y_limit <= (addr_Y==6)?i_Y:Y_limit;
    end
end
always_ff @(posedge clk)
begin
    if (i_class_num_vld) begin
        class_num_meno1 <= i_class_num[4:0]-1;
    end
end
always_ff @(posedge clk)
begin
    class_num_vld <= i_class_num_vld;
end
always_ff @(posedge clk)
begin
    if (class_num_vld) begin
        rilevanza[16-1:1] <= func__int2std_4(class_num_meno1)-1;
        rilevanza[0] <= 1;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    start <= 1;
end
else begin
    if (i_data_vld[0]) begin
        if (counter_len==(16-1)) begin
            start <= 1;
        end
        else begin
            start <= 0;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    counter_len <= 0;
end
else begin
    if (i_data_vld[0]) begin
        if (counter_len==(16-1)) begin
            counter_len <= 0;
        end
        else begin
            counter_len <= counter_len+1;
        end
    end
end
end
assign read_buf = i_data_vld[0]&start;
assign w_index_clnum = i_index;
always_ff @(posedge clk)
begin
if (rst__l) begin
    error <= 0;
end
else begin
    error <= (~pd_buf_empty&i_Y_vld)|(pd_buf_empty&read_buf);
end
end
assign od_error = error;
assign maschera = func__int2std_4(pd_buf_index);
always_ff @(posedge clk)
begin
    if (i_class_num_vld) begin
        mux_funzione <= i_mux_funzione;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (mux_funzione==3) begin
            ferr_data[i] <= pd_4soglieLim_data[i];
        end
        else if (mux_funzione==2) begin
            ferr_data[i] <= pd_4soglie_data[i];
        end
        else if (mux_funzione==1) begin
            ferr_data[i] <= pd_2soglieLim_data[i];
        end
        else begin
            ferr_data[i] <= pd_2soglie_data[i];
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (mux_funzione==3) begin
            ferr_valid[i] <= pd_4soglieLim_valid[i];
        end
        else if (mux_funzione==2) begin
            ferr_valid[i] <= pd_4soglie_valid[i];
        end
        else if (mux_funzione==1) begin
            ferr_valid[i] <= pd_2soglieLim_valid[i];
        end
        else begin
            ferr_valid[i] <= pd_2soglie_valid[i];
        end
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop[i] = ferr_data[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_backprop_vld[i] = ferr_valid[i];
    end
end

endmodule