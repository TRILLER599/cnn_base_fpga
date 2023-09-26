`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_caricamento_data (
    input  bit clk,
    input  bit i_rst,
    input  bit [31:0] i_data,
    input  bit i_start,
    input  bit i_completamento,
    output bit od_zona_pix,
    output bit od_buf_empty,
    output bit od_buf_ready,
    input  bit [15:0] i_quantita_meno1,
    input  bit [3:0] i_byte_inPIX,
    input  bit i_minib_busy,
    input  bit [10:0] i_minibatch,
    input  bit [20:0] i_img_dir,
    input  bit i_img_aggiornamento,
    output bit [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit zona_pix;
bit [10:0] count_wr;
bit [10:0] count_wr_max;
bit rading_mb;
bit valid;
bit [29:0] count_rd;
bit [29:0] count_rd_max;
bit [1:0] mux_rd;
bit [31:0] data;
bit [10:0] dsp_minibatch;
bit [20:0] dsp_img;
bit [31:0] dsp_mult;
bit [31:0] dsp_sum_meno1;
bit dsp_mult_en;
bit dsp_sum_en;
bit arriornamento_rd_max;
bit w_last_wr;
bit w_valid;
bit w_ultima_parola;
bit [1:0] w_byte_num;
bit [1:0] w_parole_num;
bit w_enb_buf;
bit w_ena_buf;
bit pd_buf_empty;
bit pd_buf_ready;
bit [34:0] w_dia_buf;
bit [34:0] pd_buf_data;

common_FIFO_Fast_O12W35T4092 u_bufer_pix
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_write             (w_ena_buf),
    .i_data              (w_dia_buf),
    .i_read              (w_enb_buf),
    .od_data             (pd_buf_data),
    .od_empty            (pd_buf_empty),
    .od_wr_ready         (pd_buf_ready)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_start) begin
        if (i_byte_inPIX[2]) begin
            count_wr_max <= i_quantita_meno1;
        end
        else if (i_byte_inPIX[1]) begin
            count_wr_max <= i_quantita_meno1>>>1;
        end
        else begin
            count_wr_max <= i_quantita_meno1>>>2;
        end
    end
end
assign w_last_wr = (count_wr==count_wr_max);
always_ff @(posedge clk)
begin
if (i_rst) begin
    zona_pix <= 0;
end
else begin
    if (zona_pix) begin
        if (i_completamento==0) begin
            zona_pix <= ~w_last_wr;
        end
    end
    else begin
        zona_pix <= i_start;
    end
end
end
always_ff @(posedge clk)
begin
    if (zona_pix) begin
        if (i_completamento==0) begin
            count_wr <= count_wr+1;
        end
    end
    else begin
        count_wr <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    rading_mb <= 0;
end
else begin
    if (rading_mb) begin
        if (~pd_buf_empty) begin
            rading_mb <= ~(count_rd==count_rd_max);
        end
    end
    else begin
        rading_mb <= ~pd_buf_empty&(~i_minib_busy);
    end
end
end
always_ff @(posedge clk)
begin
    if (rading_mb) begin
        if (~pd_buf_empty) begin
            count_rd <= count_rd+1;
        end
    end
    else begin
        count_rd <= 0;
    end
end
assign w_ultima_parola = pd_buf_data[34];
assign w_byte_num = pd_buf_data[33:32];
assign w_parole_num = i_quantita_meno1[1:0];
assign w_valid = rading_mb&(~pd_buf_empty);
always_ff @(posedge clk)
begin
if (i_rst) begin
    mux_rd <= 0;
end
else begin
    if (w_valid) begin
        if (w_byte_num[1]) begin
            mux_rd <= 0;
        end
        else if (w_byte_num[0]) begin
            if (w_ultima_parola) begin
                mux_rd <= (mux_rd[0]==w_parole_num[0])?0:mux_rd+1;
            end
            else begin
                mux_rd <= (mux_rd[0])?0:mux_rd+1;
            end
        end
        else begin
            if (w_ultima_parola) begin
                mux_rd <= (mux_rd==w_parole_num)?0:mux_rd+1;
            end
            else begin
                mux_rd <= mux_rd+1;
            end
        end
    end
end
end
always_comb
begin
    if (w_valid) begin
        if (w_byte_num[1]) begin
            w_enb_buf = 1;
        end
        else if (w_byte_num[0]) begin
            if (w_ultima_parola) begin
                w_enb_buf = mux_rd[0]==w_parole_num[0];
            end
            else begin
                w_enb_buf = mux_rd[0];
            end
        end
        else begin
            if (w_ultima_parola) begin
                w_enb_buf = mux_rd==w_parole_num;
            end
            else begin
                w_enb_buf = &mux_rd;
            end
        end
    end
    else begin
        w_enb_buf = 0;
    end
end
assign w_ena_buf = zona_pix&(~i_completamento);
assign w_dia_buf = {w_last_wr,i_byte_inPIX[2:1],i_data};
always_ff @(posedge clk)
begin
    if (i_img_aggiornamento) begin
        dsp_minibatch <= i_minibatch;
    end
end
always_ff @(posedge clk)
begin
    if (i_img_aggiornamento) begin
        dsp_img <= i_img_dir;
    end
end
always_ff @(posedge clk)
begin
    dsp_mult_en <= i_img_aggiornamento;
end
always_ff @(posedge clk)
begin
    if (dsp_mult_en) begin
        dsp_mult <= dsp_minibatch*dsp_img;
    end
end
always_ff @(posedge clk)
begin
    dsp_sum_en <= dsp_mult_en;
end
always_ff @(posedge clk)
begin
    if (dsp_sum_en) begin
        dsp_sum_meno1 <= dsp_mult-1;
    end
end
always_ff @(posedge clk)
begin
    arriornamento_rd_max <= dsp_sum_en;
end
always_ff @(posedge clk)
begin
    if (arriornamento_rd_max) begin
        count_rd_max <= dsp_sum_meno1;
    end
end
always_ff @(posedge clk)
begin
    valid <= w_valid;
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if (w_byte_num[1]) begin
            data <= pd_buf_data[31:0];
        end
        else if (w_byte_num[0]) begin
            data <= (mux_rd[0])?pd_buf_data[31:16]:pd_buf_data[15:0];
        end
        else begin
            if (mux_rd==0) begin
                data <= pd_buf_data[7:0];
            end
            else if (mux_rd==1) begin
                data <= pd_buf_data[15:8];
            end
            else if (mux_rd==2) begin
                data <= pd_buf_data[23:16];
            end
            else begin
                data <= pd_buf_data[31:24];
            end
        end
    end
end
assign od_zona_pix = zona_pix;
assign od_buf_empty = pd_buf_empty;
assign od_buf_ready = pd_buf_ready;
assign od_data = data;
assign od_valid = valid;

endmodule