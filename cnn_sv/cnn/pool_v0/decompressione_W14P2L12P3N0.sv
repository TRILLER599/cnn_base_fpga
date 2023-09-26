`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module pool_v0_decompressione_W14P2L12P3N0 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_valid,
    input  bit [1:0] i_index,
    input  bit i_index_vld,
    output bit od_ready,
    input  bit i_read_en,
    output bit od_presence,
    output bit [13:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] count_linea;
bit linea_end;
bit count_quad;
bit [4:0] difference;
bit ready;
bit soglia_leggere;
bit count_pool;
bit [1:0] spostamento;
bit [13:0] data;
bit valid;
bit w_reading_mem;
bit [13:0] pd_data;
bit [1:0] pd_index;
bit pd_empty[1:0];
bit w_quad_end;
bit rst__pip;
bit rst__l;

common_FIFO_FastD_ReRead_O5W14L12C2 u_data
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_valid),
    .i_data              (i_data),
    .i_read              (w_reading_mem),
    .od_data             (pd_data),
    .od_empty            (pd_empty[0])
);
common_FIFO_Fast_ReRead_O10W2L12C2 u_index
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_index_vld),
    .i_data              (i_index),
    .i_read              (w_reading_mem),
    .od_data             (pd_index),
    .od_empty            (pd_empty[1])
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

assign w_reading_mem = i_read_en&soglia_leggere&(count_pool==2-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    linea_end <= 0;
end
else begin
    if (w_reading_mem) begin
        linea_end <= (count_linea==12-2);
    end
end
end
assign w_quad_end = (count_quad==2-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_linea <= 0;
end
else begin
    if (w_reading_mem) begin
        count_linea <= (linea_end)?0:count_linea+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_quad <= 0;
end
else begin
    if (w_reading_mem) begin
        if (linea_end) begin
            count_quad <= (w_quad_end)?0:count_quad+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    difference <= 0;
end
else begin
    if (i_valid) begin
        difference <= (w_reading_mem&w_quad_end)?difference:difference+1;
    end
    else begin
        difference <= (w_reading_mem&w_quad_end)?difference-1:difference;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ready <= 0;
end
else begin
    ready <= (difference<12*2);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    soglia_leggere <= 0;
end
else begin
    if (soglia_leggere) begin
        if (i_read_en&(count_pool==2-1)&linea_end&w_quad_end) begin
            soglia_leggere <= (difference>12)&~pd_empty[0];
        end
    end
    else begin
        soglia_leggere <= (difference>12-1)&~pd_empty[0];
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_pool <= 0;
end
else begin
    if (i_read_en&soglia_leggere) begin
        count_pool <= (count_pool==2-1)?0:count_pool+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    spostamento <= 0;
end
else begin
    if (i_read_en&soglia_leggere) begin
        if ((count_pool==2-1)&linea_end) begin
            spostamento <= (w_quad_end)?0:spostamento+2;
        end
    end
end
end
always_ff @(posedge clk)
begin
    data <= ((spostamento+count_pool)==pd_index)?pd_data:0;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid <= 0;
end
else begin
    valid <= (i_read_en&soglia_leggere);
end
end
assign od_ready = ready;
assign od_presence = soglia_leggere;
assign od_data = data;
assign od_valid = valid;

endmodule