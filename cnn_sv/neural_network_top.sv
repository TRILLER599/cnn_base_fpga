
`timescale 100ps/100ps

module neural_network_top
(
    input  bit  clk,
    input  bit  clk_eth,
    input  bit  i_eth_conf_complete,  

    output bit         o_preE_errore_ovrf, // переполнение счётчика длин в preE
    output bit         o_rx_pacco_perduto, // заполнение приёмного буфера с потерей
    // 32-bit DATA RX   
    input  bit  [31:0] i_eth_rx_data,
    input  bit  [3:0]  i_eth_rx_keep,
    input  bit         i_eth_rx_valid,
    input  bit         i_eth_rx_last,   
 
    // 32-bit DATA TX   
    input bit          i_eth_tx_ready,
    output bit  [31:0] o_eth_tx_data,
    output bit  [3:0]  o_eth_tx_keep,
    output bit         o_eth_tx_valid,
    output bit         o_eth_tx_last   
);
   
   
///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// 
localparam bit [7:0] MAC_FPGA[6] = '{51,17,34,0,170,187};
localparam bit [7:0] IP_FPGA[4] = '{192,168,19,128};


///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// 
bit             rst_g, rst_l, rst_cmd;
bit [2:0]       rst_elab, rst_rete;
bit             rst_eth;

// предварительная фильтрация принятых пакетов
bit [31:0]      preE_data;
bit             preE_valid, preE_last;

// первичный разбор UDP-IP
bit [31:0]      elA_payload;
bit             elA_payload_zona, elA_payload_last, elA_payload_8k;    
bit [79:0]      elA_cipscope;

// обработчик payload
bit             wd_flag;
bit [15:0]      minibatch, class_num;
bit [4:0]       rallentamente;
bit             modalita_studio, class_num_vld;
bit [7:0]       mux_funzione;
bit [31:0]      elB_pix, elB_peso, elB_Y;
bit             elB_pix_vld, elB_Y_vld, elB_index_vld;
bit [15:0]      elB_peso_vld, elB_index;
bit             elB_rete_errori_read, elB_tf_read;  

bit [31:0]      elB_pacco_ultimo, elB_risp_data;
bit             elB_completamento, elB_risp_valid, elB_risp_event;   
bit [1:0]       elB_risp_lcode;
// bit [63:0]      elB_cipscope;

bit [31:0]      pd_cnn_peso, pd_true_false;
bit             pd_cnn_peso_vld, pd_tf_vld;
bit [15:0]      pd_rete_errori, pd_strato_ultimo_attuale;
bit             pd_rete_errori_vld, pd_minib_completamento;
bit [6:0]       pd_profondita_attuale;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////	
// глобальный ресет дл¤ основной частоты ~200 МГц
async_reset16 #(
    .length_rst         (8))
u_rst_g(
	.clk				(clk),    
	.in_reset			(1'b0),
	.in_locked			(i_eth_conf_complete),
	.out_rst			(rst_g),
	.out_locked			());

// логический ресет для основной частоты ~200 МГц
always_ff @(posedge clk)
begin
    if (rst_g)
        rst_elab        <= 3'b111;
    else
        rst_elab        <= {rst_elab[1:0], 1'b0};
end
assign rst_l            = rst_elab[2];

////////
// ресет для частоты Ethernet 312 МГц
async_reset16 #(
    .length_rst         (8))
u_rst_eth(
	.clk				(clk_eth),    
	.in_reset			(1'b0),
	.in_locked			(i_eth_conf_complete),
	.out_rst			(rst_eth),
	.out_locked			());
   

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////    
liv_trasporto_preElaborazione 
#(
    .mac                (MAC_FPGA),
    .ip                 (IP_FPGA)
)
u_preElaborazione(
    .clk                (clk_eth),
    .i_rst_g            (rst_eth),
    .i_rx_data          (i_eth_rx_data),    // [31:0] 
    .i_rx_valid         (i_eth_rx_valid),
    .i_rx_last          (i_eth_rx_last),
    .od_data            (preE_data),  // [31:0] 
    .od_valid           (preE_valid),
    .od_last            (preE_last),
    .od_errore_ovrf     (o_preE_errore_ovrf)
);


//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////// 
liv_trasporto_elaborazione_A_rxtx u_elaborazione_A(
    .clk                (clk),
    .clk_eth            (clk_eth),
    .i_rst_g            (rst_elab[0]),
    .i_rst_eth          (rst_eth),
    .i_ricezione_en     (1'b1),
    // приЄм информации из сети
    .i_10g_rx_data      (preE_data),    // [31:0]
    .i_10g_rx_last      (preE_last),    //       
    .i_10g_rx_valid     (preE_valid),   //     
    // полезные данные пакета дл¤ дальнейшей обработки
    .i_elB_payload_busy (elB_completamento),       
    .od_payload         (elA_payload),      // [31:0]
    .od_payload_zona    (elA_payload_zona), //       
    .od_payload_last    (elA_payload_last), //       
    .od_payload_8k      (elA_payload_8k),   //   
    // чипскоп      
    .od_rx_pacco_perduto(o_rx_pacco_perduto),
    .od_cipscope        (elA_cipscope),     // [63:0]
    // информаци¤ от обработчика полезной нагрузки
    .i_elB_pacco_ultimo (elB_pacco_ultimo), // [31:0]
    .i_elB_data         (elB_risp_data),    // [31:0]
    .i_elB_valid        (elB_risp_valid),   //       
    .i_elB_lung_code    (elB_risp_lcode),   // [1:0] 
    .i_elB_lung_event   (elB_risp_event),   //  
    // передача в сеть
    .i_10g_tx_ready     (i_eth_tx_ready),   //       
    .od_10g_tx_data     (o_eth_tx_data),    // [31:0]
    .od_10g_tx_keep     (o_eth_tx_keep),    // [3:0] 
    .od_10g_tx_last     (o_eth_tx_last),    //       
    .od_10g_tx_valid    (o_eth_tx_valid)    //       
);


//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////// 
liv_trasporto_elaborazione_B u_elaborazione_B(

    .clk                    (clk),              //       
    .i_rst_g                (rst_elab[0]),      //       
    .i_rst                  (rst_l),            //   
    // данные от оботчика UDP-IP
    .i_data                 (elA_payload),      // [31:0]
    .i_reading              (elA_payload_zona), //       
    .i_last                 (elA_payload_last), //       
    .i_lung8k               (elA_payload_8k),   //  
    .od_completamento       (elB_completamento),//       
    .od_pixbuf_empty        (),                 //       
    .od_rst_cmd             (rst_cmd),          //   
    .od_wd_flag             (wd_flag),
    // настойки нейросети
    .od_minibatch           (minibatch),        // [15:0]
    .od_rallentamente       (rallentamente),    // [4:0] 
    .od_modalita_studio     (modalita_studio),  //       
    .od_class_num           (class_num),        // [15:0]
    .od_class_num_vld       (class_num_vld),    //  
    .od_mux_funzione        (mux_funzione),     // [7:0]
    // данные дл¤ обучени¤
    .od_pix                 (elB_pix),          // [31:0]
    .od_pix_vld             (elB_pix_vld),      //       
    .od_peso                (elB_peso),         // [31:0]
    .od_peso_vld            (elB_peso_vld),     // [15:0]
    .i_peso                 (pd_cnn_peso),      // [31:0]
    .i_peso_vld             (pd_cnn_peso_vld),  //       
    .od_Y                   (elB_Y),            // [31:0]
    .od_Y_vld               (elB_Y_vld),        //       
    .od_index               (elB_index),        // [15:0]
    .od_index_vld           (elB_index_vld),    //       
    .od_rete_errori_read    (elB_rete_errori_read), //       
    .i_rete_errori          (pd_rete_errori),       // [15:0]
    .i_rete_errori_vld      (pd_rete_errori_vld),   //       
    .od_tf_read             (elB_tf_read),          //       
    .i_true_false           (pd_true_false),        // [31:0]
    .i_tf_valid             (pd_tf_vld),            // 
    // реальные параметры сети и сигнал завершени¤ минибатча
    .i_profondita_attuale   (pd_profondita_attuale),   // [6:0] 
    .i_strato_ultimo_attuale(pd_strato_ultimo_attuale),// [15:0]
    .i_minib_busy           (pd_minib_completamento),  //   
    // данные дл¤ формировани¤ пакета UDP-IP 
    .od_pacco_ultimo        (elB_pacco_ultimo),     // [31:0]
    .od_risp_event          (elB_risp_event),       //       
    .od_risp_lcode          (elB_risp_lcode),       // [1:0] 
    .od_risp_data           (elB_risp_data),        // [31:0]
    .od_risp_valid          (elB_risp_valid),       //  
    .od_cipscope            (),                     // [63:0] 
    .od_logic_errore        ()                      // [7:0] 
);

// логический ресет для нейросети
always_ff @(posedge clk)
begin
    if (rst_g | rst_cmd | wd_flag)
        rst_rete        <= 3'b111;
    else
        rst_rete        <= {rst_rete[1:0], 1'b0};
end


///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// 
//       нейросеть

reti_neurali_base_0920 u_cnn(

    .clk                    (clk), 
    .i_rst_g                (rst_rete[0]),
    .i_rst                  (rst_rete[2]),
    
    .i_minibatch            (minibatch),            // [15:0] 
    .i_rallentamente        (rallentamente),        // [4:0]
    .i_modalita_studio      (modalita_studio),      //  
    .i_class_num            (class_num),            // [15:0] 
    .i_class_num_vld        (class_num_vld),        //  
    .i_mux_funzione         (mux_funzione),         // [7:0]
    
    .i_pix                  (elB_pix),              // [31:0] 
    .i_pix_vld              (elB_pix_vld),          //  
    .i_peso                 (elB_peso),             // [31:0] 
    .i_peso_vld             (elB_peso_vld),         // [15:0] 
    .od_peso                (pd_cnn_peso),          // [31:0] 
    .od_peso_vld            (pd_cnn_peso_vld),      // 
    .i_Y                    (elB_Y),                // [31:0] 
    .i_Y_vld                (elB_Y_vld),            //   
    .i_index                (elB_index),            // [15:0] 
    .i_index_vld            (elB_index_vld),        // input  
    .i_rete_errori_read     (elB_rete_errori_read), // input  
    .od_rete_errori         (pd_rete_errori),       // [15:0] 
    .od_rete_errori_vld     (pd_rete_errori_vld),   // 
    .i_tf_read              (elB_tf_read),          // 
    .od_true_false          (pd_true_false),        // [31:0] 
    .od_tf_vld              (pd_tf_vld),            // 

    .od_minib_completamento (pd_minib_completamento),   // 
    .od_profondita_attuale  (pd_profondita_attuale),    // [6:0] 
    .od_strato_ultimo       (pd_strato_ultimo_attuale)  // [15:0] 
);


///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// 
   
   
endmodule
