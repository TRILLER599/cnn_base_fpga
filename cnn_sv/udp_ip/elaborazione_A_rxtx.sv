`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_elaborazione_A_rxtx (
    input  bit clk,
    input  bit clk_eth,
    input  bit i_rst_g,
    input  bit i_rst_eth,
    input  bit i_ricezione_en,
    
    input  bit [31:0]   i_10g_rx_data,
    input  bit          i_10g_rx_last,
    input  bit          i_10g_rx_valid,
    input  bit          i_elB_payload_busy,
    output bit [31:0]   od_payload,
    output bit          od_payload_zona,
    output bit          od_payload_last,
    output bit          od_payload_8k,
    // чипскоп и ошибка
    output bit          od_rx_pacco_perduto,
    output bit [79:0]   od_cipscope,
    // ответ от обработчика payload
    input  bit [31:0]   i_elB_pacco_ultimo,
    input  bit [31:0]   i_elB_data,
    input  bit          i_elB_valid,
    input  bit [1:0]    i_elB_lung_code,
    input  bit          i_elB_lung_event,
    input  bit          i_10g_tx_ready,
    output bit [31:0]   od_10g_tx_data,
    output bit [3:0]    od_10g_tx_keep,
    output bit          od_10g_tx_last,
    output bit          od_10g_tx_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit rx_start_wr;
bit rx_ready_fix, pacco_perduto;
bit rx_reading;
bit [32:0] w_dia_rxbuf;
bit [32:0] pd_rxbuf_dob;
bit w_ena_rxbuf;
bit w_enb_rxbuf;
bit pd_rxbuf_empty;
bit pd_rxbuf_ready;
bit [1:0] rxbuf_ready_cc;
bit [7:0] w_rxbuf_data[3:0];
bit w_rxbuf_last;
bit pd_elA_risposta_busy;
bit [15:0] pd_elA_payload_2B;
bit [31:0] pd_elA_data_tx;
bit [1:0] pd_elA_keep_tx;
bit pd_elA_last_tx;
bit pd_elA_valid_tx;
bit [34:0] w_dia_txbuf;
bit w_read_txbuf;
bit [34:0] pd_txbuf_dob;
// bit pd_txbuf_empty;
bit pd_txbuf_ready;
bit [1:0] txbuf_ready;
bit rst__pip;
bit rst__l;
bit [1:0] rst_eth;
// управление чтением из TX-буфера для формирования непрерывного потока данных
bit pacco_completato=1'b0, pacco_completato_event, pacco_invio;
bit [3:0] pacco_completato_cc;
bit [3:0] tx_pack_counter; // реверсивный счётчик!

///////////////////////////////////////////////////////////
// RX-буфер
FIFO_Fast_Ind_cdc31 #(
	.ORDER       		(13),
    .width_mem       	(33),
	.threshold_full		(6143),
	.Internal_RST_WR    (0),
	.Internal_RST_RD    (1))
u_rx_buf(
	.clk_wr				(clk_eth),
	.clk_rd				(clk),    
    .in_rst_wr			(rst_eth[1]),
    .in_rst_rd			(i_rst_g),
    
    .in_write 			(w_ena_rxbuf),
    .in_data 			(w_dia_rxbuf),
    .in_read 			(w_enb_rxbuf),
    .out_data 			(pd_rxbuf_dob),
    
    .out_empty 			(pd_rxbuf_empty),	
	.out_write_ready	(pd_rxbuf_ready)
);

liv_trasporto_elaborazione_A u_elaborazione_A
(
    .clk                 (clk),
    .i_rst_g             (i_rst_g),
    .i_rst               (rst__l),
    .i_rx_data           (w_rxbuf_data),
    .i_rx_reading        (rx_reading),
    .i_rx_last           (w_rxbuf_last),
    .od_risp_busy        (pd_elA_risposta_busy),
    .i_payload_busy      (i_elB_payload_busy),
    .od_payload_2B       (pd_elA_payload_2B),
    .od_payload_zona     (od_payload_zona),
    .od_payload_lung8k   (od_payload_8k),
    .i_pacco_ultimo      (i_elB_pacco_ultimo),
    .i_elB_data          (i_elB_data),
    .i_elB_valid         (i_elB_valid),
    .i_elB_lung_code     (i_elB_lung_code),
    .i_elB_lung_event    (i_elB_lung_event),
    .i_txbuf_ready       (txbuf_ready[1]),
    .od_data_txbuf       (pd_elA_data_tx),
    .od_keep_txbuf       (pd_elA_keep_tx),
    .od_last_txbuf       (pd_elA_last_tx),
    .od_valid_txbuf      (pd_elA_valid_tx)
);

///////////////////////////////////////////////////////////
// TX-буфер
assign w_dia_txbuf = {pd_elA_last_tx, pd_elA_keep_tx, pd_elA_data_tx};
assign w_read_txbuf = i_10g_tx_ready & tx_pack_counter[3];

FIFO_Fast_Ind #(
	.ORDER       		(12),
    .width_mem       	(35),
	.threshold_full		(4087),
	.Internal_RST_WR    (1),
	.Internal_RST_RD    (1))
u_tx_buf(
	.clk_wr				(clk),
	.clk_rd				(clk_eth),    
    .in_rst_wr			(i_rst_g),
    .in_rst_rd			(i_rst_eth),

    .in_write 			(pd_elA_valid_tx),
    .in_data 			(w_dia_txbuf),
    .in_read 			(w_read_txbuf),
    .out_data 			(pd_txbuf_dob),
    .out_empty 			(), // pd_txbuf_empty
	.out_write_ready	(pd_txbuf_ready)
);

always_ff @(posedge clk)
begin
    txbuf_ready <= {txbuf_ready[0], pd_txbuf_ready};
end


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk_eth)
begin
    rst_eth  <= {rst_eth[0], i_rst_eth};
end

///////////////////////////////////////////////////////////
// сигналы записи данных в RX-буфер
always_ff @(posedge clk_eth)
begin
if (rst_eth[1]) begin
    rx_start_wr <= 1;
end
else begin
    if (i_10g_rx_valid) begin
        rx_start_wr <= i_10g_rx_last;
    end
end
end
always_ff @(posedge clk_eth)
begin
    rxbuf_ready_cc <= {rxbuf_ready_cc[0], pd_rxbuf_ready};
end
always_ff @(posedge clk_eth)
begin
if (rst_eth[1]) begin
    rx_ready_fix <= 0;
    pacco_perduto<= 0;
end
else begin
    if (i_10g_rx_valid) begin
        if (rx_start_wr) begin
            // rx_ready_fix <= rxbuf_ready_cc[1];
            rx_ready_fix <= (rxbuf_ready_cc[1] & i_ricezione_en);
            pacco_perduto<= pacco_perduto|(~rxbuf_ready_cc[1]);
        end
    end
end
end
always_comb
begin
    if (i_10g_rx_valid) begin
        // w_ena_rxbuf = (rx_start_wr)?rxbuf_ready_cc[1]:rx_ready_fix;
        w_ena_rxbuf = (rx_start_wr)?(rxbuf_ready_cc[1]&i_ricezione_en):rx_ready_fix;
    end
    else begin
        w_ena_rxbuf = 0;
    end
end
assign w_dia_rxbuf = {i_10g_rx_last,i_10g_rx_data};

///////////////////////////////////////////////////////////
// чтение данных из RX-буфера
assign w_enb_rxbuf = rx_reading&(~i_elB_payload_busy);
always_comb
begin
    for (int i=0; i<4; i++) begin
        w_rxbuf_data[i] = pd_rxbuf_dob[8*i+:8];
    end
end
assign w_rxbuf_last = pd_rxbuf_dob[32];
always_ff @(posedge clk)
begin
if (rst__l) begin
    rx_reading <= 0;
end
else begin
    if (rx_reading) begin
        if (!i_elB_payload_busy&&w_rxbuf_last) begin
            rx_reading <= 0;
        end
    end
    else begin
        rx_reading <= !pd_elA_risposta_busy&&(!pd_rxbuf_empty);
    end
end
end


///////////////////////////////////////////////////////////
// управление чтением данных из TX-буфера в домене clk_eth
always_ff @(posedge clk)
begin
    if (pd_elA_valid_tx & pd_elA_last_tx) begin
        pacco_completato <= ~pacco_completato;
    end
end

always_ff @(posedge clk_eth)
begin
    pacco_completato_cc <= {pacco_completato_cc[2:0], pacco_completato};
end

assign pacco_completato_event = pacco_completato_cc[3]^pacco_completato_cc[2];
assign pacco_invio = i_10g_tx_ready& tx_pack_counter[3]& pd_txbuf_dob[34];

always_ff @(posedge clk_eth)
begin
if (rst_eth[1]) begin
    tx_pack_counter <= 0;
end
else begin
    // реверсивный счётчик!
    if (pacco_invio == pacco_completato_event) begin
        tx_pack_counter <= tx_pack_counter;
    end
    else if (pacco_completato_event) begin
        tx_pack_counter <= tx_pack_counter - 1;
    end
    else begin
        tx_pack_counter <= tx_pack_counter + 1;
    end
end
end

// выходные порты
assign od_payload = {pd_rxbuf_dob[15:0],pd_elA_payload_2B};
assign od_payload_last = pd_rxbuf_dob[32];
assign od_10g_tx_data = pd_txbuf_dob[31:0];
assign od_10g_tx_keep = {pd_txbuf_dob[33],pd_txbuf_dob[33],pd_txbuf_dob[32],pd_txbuf_dob[32]};
assign od_10g_tx_last = pd_txbuf_dob[34];
assign od_10g_tx_valid = tx_pack_counter[3];

assign od_rx_pacco_perduto = pacco_perduto;

assign od_cipscope[33:0] = {w_enb_rxbuf, w_rxbuf_last, pd_rxbuf_dob[31:0]};
assign od_cipscope[35:34] = {pd_rxbuf_empty, i_elB_payload_busy};
assign od_cipscope[38:36] = {pd_rxbuf_ready, pd_elA_risposta_busy, rx_reading};
assign od_cipscope[39] = pd_rxbuf_empty&(~pd_rxbuf_ready)&(~rst__l);

assign od_cipscope[75:40] = {pd_elA_valid_tx, pd_elA_last_tx, pd_elA_keep_tx, pd_elA_data_tx};
assign od_cipscope[77:76] = {1'b0, txbuf_ready[1]};
assign od_cipscope[79:78] = 2'd0;

endmodule