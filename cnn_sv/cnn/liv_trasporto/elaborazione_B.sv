`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_elaborazione_B (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [31:0] i_data,
    input  bit i_reading,
    input  bit i_last,
    input  bit i_lung8k,
    output bit od_completamento,
    output bit od_pixbuf_empty,
    output bit od_rst_cmd,
    output bit od_wd_flag,
    output bit [15:0] od_minibatch,
    output bit [4:0] od_rallentamente,
    output bit od_modalita_studio,
    output bit [15:0] od_class_num,
    output bit od_class_num_vld,
    output bit [7:0] od_mux_funzione,
    output bit [31:0] od_pix,
    output bit od_pix_vld,
    output bit [31:0] od_peso,
    output bit [15:0] od_peso_vld,
    input  bit [31:0] i_peso,
    input  bit i_peso_vld,
    output bit [31:0] od_Y,
    output bit od_Y_vld,
    output bit [15:0] od_index,
    output bit od_index_vld,
    output bit od_rete_errori_read,
    input  bit [15:0] i_rete_errori,
    input  bit i_rete_errori_vld,
    output bit od_tf_read,
    input  bit [31:0] i_true_false,
    input  bit i_tf_valid,
    input  bit [6:0] i_profondita_attuale,
    input  bit [15:0] i_strato_ultimo_attuale,
    input  bit i_minib_busy,
    output bit [31:0] od_pacco_ultimo,
    output bit od_risp_event,
    output bit [1:0] od_risp_lcode,
    output bit [31:0] od_risp_data,
    output bit od_risp_valid,
    output bit [63:0] od_cipscope,
    output bit [7:0] od_logic_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [2:0] ricezione_count;
bit rst_cmd;
bit completamento;
bit [1:0] rst_cmd_count;
bit questo_disp;
bit tutti_disp;
bit comando_hard;
bit [13:0] comando;
bit [2:0] cmd_soft_prec;
bit [31:0] pacco_ultimo;
bit [31:0] pacco_prossimo;
bit [31:0] pacco_ricevuto;
bit [15:0] class_num;
bit [10:0] minibatch;
bit [4:0] rallentamente;
bit [6:0] profondita;
bit [20:0] img_dir;
bit modalita_studio;
bit aggiornamento_cmd1;
bit [7:0] mux_funzione;
bit [10:0] quantita_W_meno1;
bit [5:0] strato_W_numero;
bit [15:0] quantita_IX_meno1;
bit [15:0] quantita_pix_meno1;
bit [15:0] pix_strato_ingresso;
bit [3:0] byte_inPIX;
bit [31:0] Y_reg;
bit [31:0] peso_reg;
bit [2:0] Y_count;
bit Y_count_en;
bit Y_valid;
bit rete_errori_read;
bit tf_read[1:0];
bit zona_peso;
bit [10:0] peso_count;
bit [15:0] peso_vaild_std;
bit errore_flg_1d;
bit start_risposta;
bit errore_flg_non_rst;
bit [1:0] code_risposta;
bit [31:0] data_risposta;
bit valid_risposta;
bit [19:0] wd_count;
bit wd_count_b19;
bit wd_flag;
bit [3:0] reg4[5:0];
bit w_valid;
bit [2:0] w_cmd;
bit w_comando_vld;
bit [15:0] w_data_15_0_meno1;
bit [15:0] pd_errore;
bit pd_errore_flg;
bit [15:0] w_peso_valid_std;
bit w_start_ix;
bit w_start_pix;
bit pd_zona_pix;
bit pd_pixbuf_empty;
bit pd_pixbuf_ready;
bit [1:0] pd_drisp_lung;
bit [31:0] pd_drisp_data;
bit pd_drisp_valid;
bit [31:0] pd_erisp_data;
bit w_errore_event;
bit pd_erisp_valid;
bit rst__pip;
bit rst__l;

function automatic bit [15:0] func__int2std_4(input bit [3:0] i_data);
    func__int2std_4 = 1<<i_data;
endfunction

liv_trasporto_controllo_param u_controllo_param
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_reading           (i_reading),
    .i_completamento     (completamento),
    .i_counter           (ricezione_count),
    .i_questo_disp       (questo_disp),
    .i_comando_hard      (comando_hard),
    .i_pacco_prossimo    (pacco_prossimo),
    .i_cmd               (w_cmd),
    .i_profondita_attuale(i_profondita_attuale),
    .i_strato_ultimo_attuale(i_strato_ultimo_attuale),
    .od_errore           (pd_errore),
    .od_errore_flg       (pd_errore_flg)
);
liv_trasporto_caricamento_ix u_caricamento_ix
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_start             (w_start_ix),
    .i_quantita_meno1    (quantita_IX_meno1),
    .od_data             (od_index),
    .od_valid            (od_index_vld)
);
liv_trasporto_caricamento_data u_caricamento_data
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (i_data),
    .i_start             (w_start_pix),
    .i_completamento     (completamento),
    .od_zona_pix         (pd_zona_pix),
    .od_buf_empty        (pd_pixbuf_empty),
    .od_buf_ready        (pd_pixbuf_ready),
    .i_quantita_meno1    (quantita_pix_meno1),
    .i_byte_inPIX        (byte_inPIX),
    .i_minib_busy        (i_minib_busy),
    .i_minibatch         (minibatch),
    .i_img_dir           (img_dir),
    .i_img_aggiornamento (aggiornamento_cmd1),
    .od_data             (od_pix),
    .od_valid            (od_pix_vld)
);
liv_trasporto_data_B_risposta u_data_risp
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data_rx           (i_data),
    .i_reading_rx        (i_reading),
    .i_completamento     (completamento),
    .i_wd_flag           (wd_flag),
    .i_counter           (ricezione_count),
    .i_cmd               (w_cmd),
    .i_errore_flg        (pd_errore_flg),
    .i_quantita_W_meno1  (quantita_W_meno1),
    .i_rete_errore       (i_rete_errori),
    .i_rete_errore_vld   (i_rete_errori_vld),
    .i_true_false        (i_true_false),
    .i_tf_vld            (i_tf_valid),
    .i_weight            (i_peso),
    .i_weight_vld        (i_peso_vld),
    .od_errore_logica    (od_logic_errore),
    .od_lunghezza_risp   (pd_drisp_lung),
    .od_data             (pd_drisp_data),
    .od_valid            (pd_drisp_valid)
);
liv_trasporto_errore_B_risposta u_err_risp
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_errore            (pd_errore),
    .i_errore_event      (w_errore_event),
    .i_tutti_disp        (tutti_disp),
    .i_comando           (comando),
    .i_pacco_ricevuto    (pacco_ricevuto),
    .i_pacco_ultimo      (pacco_ultimo),
    .i_lung8k            (i_lung8k),
    .od_data             (pd_erisp_data),
    .od_valid            (pd_erisp_valid)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

assign w_valid = i_reading&(~completamento);
always_ff @(posedge clk)
begin
if (rst__l) begin
    ricezione_count <= 0;
end
else begin
    if (w_valid) begin
        if (i_last) begin
            ricezione_count <= 0;
        end
        else begin
            ricezione_count <= (&ricezione_count)?ricezione_count:ricezione_count+1;
        end
    end
end
end
assign w_comando_vld = questo_disp&(~comando_hard)&(~pd_errore_flg);
assign w_cmd = comando[2:0];
assign w_data_15_0_meno1 = i_data[15:0]-1;
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if (ricezione_count==0) begin
            questo_disp <= i_data[15]|(i_data[14:0]==0);
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if (ricezione_count==0) begin
            tutti_disp <= i_data[15];
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if (ricezione_count==0) begin
            comando_hard <= i_data[30];
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if (ricezione_count==0) begin
            comando <= i_data[29:16];
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==1)&questo_disp) begin
            pacco_ricevuto <= i_data;
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==1) begin
                class_num <= i_data[15:0];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==1) begin
                minibatch <= i_data[26:16];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==2) begin
                quantita_W_meno1 <= w_data_15_0_meno1;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==2) begin
                strato_W_numero <= i_data[21:16];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==3) begin
                quantita_IX_meno1 <= w_data_15_0_meno1;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==4) begin
                quantita_pix_meno1 <= w_data_15_0_meno1;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==2)&w_comando_vld) begin
            if (w_cmd==4) begin
                byte_inPIX <= i_data[19:16];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==3)&w_comando_vld) begin
            if (w_cmd==1) begin
                rallentamente <= i_data;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==3)&w_comando_vld) begin
            if (w_cmd==1) begin
                profondita <= i_data;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==3)&w_comando_vld) begin
            if (w_cmd==4) begin
                pix_strato_ingresso <= i_data[15:0];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==4)&w_comando_vld) begin
            if (w_cmd==1) begin
                img_dir <= i_data;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==5)&w_comando_vld) begin
            if (w_cmd==1) begin
                modalita_studio <= i_data[0];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (w_valid) begin
        if ((ricezione_count==5)&w_comando_vld) begin
            if (w_cmd==1) begin
                mux_funzione <= i_data[15:8];
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    completamento <= 0;
end
else begin
    if (completamento) begin
        if (pd_zona_pix) begin
            completamento <= ~pd_pixbuf_ready;
        end
        else begin
            completamento <= i_minib_busy|(~pd_pixbuf_empty);
        end
    end
    else begin
        if (pd_zona_pix) begin
            completamento <= (i_last)?0:~pd_pixbuf_ready;
        end
        else if (ricezione_count==1) begin
            if (w_comando_vld&&(cmd_soft_prec==4)&&(w_cmd!=4)) begin
                completamento <= i_minib_busy||(!pd_pixbuf_empty);
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
    wd_count <= (completamento==1)?wd_count+1:0;
end
always_ff @(posedge clk)
begin
    wd_count_b19 <= wd_count[19];
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    wd_flag <= 0;
end
else begin
    wd_flag <= (rst_cmd)?0:wd_flag|(wd_count[19]&(!wd_count_b19));
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore_flg_1d <= 0;
end
else begin
    errore_flg_1d <= pd_errore_flg;
end
end
always_ff @(posedge clk)
begin
    errore_flg_non_rst <= pd_errore_flg;
end
always_ff @(posedge clk)
begin
    aggiornamento_cmd1 <= (ricezione_count==5)&(w_cmd==1)&w_comando_vld;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    Y_count_en <= 0;
end
else begin
    if (Y_count_en) begin
        Y_count_en <= ~(&Y_count);
    end
    else begin
        Y_count_en <= (ricezione_count==5)&(w_cmd==1)&w_comando_vld;
    end
end
end
always_ff @(posedge clk)
begin
    if (Y_count_en) begin
        Y_count <= Y_count+1;
    end
    else begin
        Y_count <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (Y_count_en) begin
        Y_reg <= i_data;
    end
end
always_ff @(posedge clk)
begin
    Y_valid <= Y_count_en;
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    rete_errori_read <= 0;
end
else begin
    rete_errori_read <= Y_count_en&(Y_count<6);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    tf_read[0] <= 0;
    tf_read[1] <= 0;
end
else begin
    tf_read[0] <= (Y_count==6)|(Y_count==7);
    tf_read[1] <= tf_read[0];
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    zona_peso <= 0;
end
else begin
    if (zona_peso) begin
        zona_peso <= ~(peso_count==quantita_W_meno1);
    end
    else begin
        zona_peso <= (ricezione_count==3)&(w_cmd==2)&w_comando_vld;
    end
end
end
always_ff @(posedge clk)
begin
    if (zona_peso) begin
        peso_count <= peso_count+1;
    end
    else begin
        peso_count <= 0;
    end
end
assign w_peso_valid_std = func__int2std_4(strato_W_numero[3:0]);
always_ff @(posedge clk)
begin
if (rst__l) begin
    peso_vaild_std <= 0;
end
else begin
    peso_vaild_std <= (zona_peso)?w_peso_valid_std:0;
end
end
always_ff @(posedge clk)
begin
    if (zona_peso) begin
        peso_reg <= i_data;
    end
end
assign w_start_ix = (ricezione_count==3)&(w_cmd==3)&w_comando_vld;
assign w_start_pix = (ricezione_count==3)&(w_cmd==4)&w_comando_vld;
assign w_errore_event = pd_errore_flg&(~errore_flg_1d);
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_risposta <= 0;
end
else begin
    valid_risposta <= pd_drisp_valid|pd_erisp_valid;
end
end
always_ff @(posedge clk)
begin
    data_risposta <= (pd_drisp_valid)?pd_drisp_data:pd_erisp_data;
end
always_ff @(posedge clk)
begin
    if (pd_errore_flg) begin
        if (~errore_flg_1d) begin
            code_risposta <= 0;
        end
    end
    else begin
        if (ricezione_count==4) begin
            code_risposta <= pd_drisp_lung;
        end
    end
end
always_ff @(posedge clk)
begin
    if (pd_errore_flg) begin
        start_risposta <= ~errore_flg_1d;
    end
    else begin
        if (ricezione_count==4) begin
            start_risposta <= (w_cmd==2)|(w_cmd==4);
        end
        else if (ricezione_count==5) begin
            start_risposta <= (w_cmd==1);
        end
        else begin
            start_risposta <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pacco_ultimo <= -1;
end
else begin
    if (questo_disp&&(!pd_errore_flg)) begin
        if (comando_hard) begin
            if (ricezione_count==4) begin
                pacco_ultimo <= 0;
            end
        end
        else begin
            if (((ricezione_count==4)&&(w_cmd!=1))||((ricezione_count==5)&&(w_cmd==1))) begin
                pacco_ultimo <= pacco_ricevuto;
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pacco_prossimo <= 0;
end
else begin
    if (questo_disp&&(!pd_errore_flg)) begin
        if (comando_hard) begin
            if (ricezione_count==4) begin
                pacco_prossimo <= 0;
            end
        end
        else begin
            if (((ricezione_count==4)&&(w_cmd!=1))||((ricezione_count==5)&&(w_cmd==1))) begin
                pacco_prossimo <= pacco_ricevuto+1;
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    cmd_soft_prec <= 0;
end
else begin
    if (questo_disp&&(!pd_errore_flg)) begin
        if (comando_hard) begin
            if (ricezione_count==4) begin
                cmd_soft_prec <= 0;
            end
        end
        else begin
            if (((ricezione_count==4)&&(w_cmd!=1))||((ricezione_count==5)&&(w_cmd==1))) begin
                cmd_soft_prec <= w_cmd;
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    rst_cmd <= 0;
end
else begin
    if (rst_cmd) begin
        rst_cmd <= ~(&rst_cmd_count);
    end
    else begin
        rst_cmd <= questo_disp&&(!pd_errore_flg)&&comando_hard&&(ricezione_count==4);
    end
end
end
always_ff @(posedge clk)
begin
    if (rst_cmd) begin
        rst_cmd_count <= rst_cmd_count+1;
    end
    else begin
        rst_cmd_count <= 0;
    end
end
assign od_completamento = completamento;
assign od_pixbuf_empty = pd_pixbuf_empty;
assign od_rst_cmd = rst_cmd;
assign od_wd_flag = wd_flag;
assign od_minibatch = {5'd0, minibatch};
assign od_rallentamente = rallentamente;
assign od_modalita_studio = modalita_studio;
assign od_class_num = class_num;
assign od_class_num_vld = aggiornamento_cmd1;
assign od_mux_funzione = mux_funzione;
assign od_peso = peso_reg;
assign od_peso_vld = peso_vaild_std;
assign od_Y = Y_reg;
assign od_Y_vld = Y_valid;
assign od_rete_errori_read = rete_errori_read;
assign od_tf_read = tf_read[1];
assign od_pacco_ultimo = pacco_ultimo;
assign od_risp_event = start_risposta;
assign od_risp_lcode = code_risposta;
assign od_risp_data = data_risposta;
assign od_risp_valid = valid_risposta;
always_ff @(posedge clk)
begin
    reg4[0] <= {pd_pixbuf_ready,pd_zona_pix,i_minib_busy,completamento};
    reg4[1] <= {ricezione_count,pd_pixbuf_empty};
    reg4[2] <= {w_comando_vld,w_cmd};
    reg4[3] <= {w_start_pix,cmd_soft_prec};
    reg4[4] <= {valid_risposta,start_risposta,code_risposta};
    reg4[5] <= {i_lung8k,i_last,w_valid,i_reading};
end
assign od_cipscope = {errore_flg_non_rst,pd_errore[6:0],data_risposta[31:16],reg4[5],reg4[4],reg4[3],reg4[2],reg4[1],reg4[0],data_risposta[15:0]};

endmodule