`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_elaborazione_A (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [7:0] i_rx_data[3:0],
    input  bit i_rx_reading,
    input  bit i_rx_last,
    output bit od_risp_busy,
    input  bit i_payload_busy,
    output bit [15:0] od_payload_2B,
    output bit od_payload_zona,
    output bit od_payload_lung8k,
    input  bit [31:0] i_pacco_ultimo,
    input  bit [31:0] i_elB_data,
    input  bit i_elB_valid,
    input  bit [1:0] i_elB_lung_code,
    input  bit i_elB_lung_event,
    input  bit i_txbuf_ready,
    output bit [31:0] od_data_txbuf,
    output bit [1:0] od_keep_txbuf,
    output bit od_last_txbuf,
    output bit od_valid_txbuf
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [7:0] ip[4] = '{192,168,19,128};
bit [3:0] ricezione_count;
bit arp;
bit ip_prot;
bit udp_prot;
bit port_f_vero;
bit lung_coretta;
bit risposta_e1lung;
bit [15:0] data_lunghezza;
bit data_8k;
bit [7:0] host_port[1:0];
bit risposta_rapida;
bit risp_busy;
bit [15:0] pld_sh;
bit zona_pld;
bit [31:0] data_risposta;
bit [1:0] keep_risposta;
bit last_risposta;
bit valid_risposta;
bit [15:0] w_rx_data_B0B1;
bit [7:0] pd_host_mac[5:0];
bit [7:0] pd_fpga_mac[5:0];
bit [7:0] pd_host_ip[3:0];
bit [7:0] pd_fpga_ip[3:0];
bit pd_mac_f_vero;
bit pd_ip_f_vero;
bit [3:0] w_arp_ip_vero;
bit w_arp_start;
bit [31:0] pd_arp_data;
bit pd_arp_last;
bit pd_arp_valid;
bit w_e1r_start;
bit pd_e1r_valid;
bit pd_e1r_last;
bit [31:0] pd_e1r_data;
bit [31:0] pd_drisp_data;
bit pd_drisp_valid;
bit pd_drisp_last;
bit rst__pip;
bit rst__l;

liv_trasporto_host_fpga_indirizio u_host_fpga_indirizio
(
    .clk                 (clk),
    .i_data              (i_rx_data),
    .i_valid             (i_rx_reading),
    .i_ricezione_count   (ricezione_count),
    .i_arp               (arp),
    .od_host_mac         (pd_host_mac),
    .od_fpga_mac         (pd_fpga_mac),
    .od_host_ip          (pd_host_ip),
    .od_fpga_ip          (pd_fpga_ip),
    .od_mac_f_vero       (pd_mac_f_vero),
    .od_ip_f_vero        (pd_ip_f_vero)
);
liv_trasporto_arp_risposta_4B u_arp
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_mac_host          (pd_host_mac),
    .i_ip_host           (pd_host_ip),
    .i_start_risp        (w_arp_start),
    .i_ready             (i_txbuf_ready),
    .od_data             (pd_arp_data),
    .od_valid            (pd_arp_valid),
    .od_last             (pd_arp_last)
);
liv_trasporto_errore1_risposta_4B u_e1risp
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_mac_host          (pd_host_mac),
    .i_ip_host           (pd_host_ip[3]),
    .i_port_host         (host_port),
    .i_lunghezza         (data_lunghezza),
    .i_pacco_ultimo      (i_pacco_ultimo),
    .i_start_risp        (w_e1r_start),
    .i_ready             (i_txbuf_ready),
    .od_data             (pd_e1r_data),
    .od_valid            (pd_e1r_valid),
    .od_last             (pd_e1r_last)
);
liv_trasporto_data_risposta_4B u_data_risp
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_mac_host          (pd_host_mac),
    .i_ip_host           (pd_host_ip[3]),
    .i_port_host         (host_port),
    .i_data              (i_elB_data),
    .i_valid             (i_elB_valid),
    .i_lung_index        (i_elB_lung_code),
    .i_lung_event        (i_elB_lung_event),
    .i_ready             (i_txbuf_ready),
    .od_data             (pd_drisp_data),
    .od_valid            (pd_drisp_valid),
    .od_last             (pd_drisp_last)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

assign w_rx_data_B0B1 = {i_rx_data[0],i_rx_data[1]};
always_ff @(posedge clk)
begin
if (rst__l) begin
    ricezione_count <= 0;
end
else begin
    if (i_rx_reading) begin
        if (i_rx_last&(~i_payload_busy)) begin
            ricezione_count <= 0;
        end
        else begin
            ricezione_count <= (&ricezione_count)?ricezione_count:ricezione_count+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==3) begin
            arp <= (i_rx_data[0]==8)&(i_rx_data[1]==6);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==3) begin
            ip_prot <= (i_rx_data[0]==8)&(i_rx_data[1]==0);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==4) begin
            data_lunghezza <= w_rx_data_B0B1-28;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==5) begin
            udp_prot <= ip_prot&(i_rx_data[3]==17);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==5) begin
            if ((data_lunghezza!=1024)&(data_lunghezza!=8192)) begin
                lung_coretta <= 0;
            end
            else begin
                lung_coretta <= 1;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==5) begin
            if ((data_lunghezza!=1024)&(data_lunghezza!=8192)) begin
                risposta_e1lung <= data_lunghezza>=32;
            end
            else begin
                risposta_e1lung <= 0;
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==5) begin
            data_8k <= data_lunghezza==8192;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==8) begin
            if (udp_prot==1) begin
                host_port[0] <= i_rx_data[2];
                host_port[1] <= i_rx_data[3];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_reading) begin
        if (ricezione_count==9) begin
            port_f_vero <= udp_prot&(w_rx_data_B0B1==7007);
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    risposta_rapida <= 0;
end
else begin
    risposta_rapida <= i_rx_reading&(ricezione_count==9)&(~i_rx_last);
end
end
assign w_arp_ip_vero[0] = pd_fpga_ip[0]==ip[0];
assign w_arp_ip_vero[1] = pd_fpga_ip[1]==ip[1];
assign w_arp_ip_vero[2] = i_rx_data[0]==ip[2];
assign w_arp_ip_vero[3] = (i_rx_data[1]==ip[3])|(i_rx_data[1]==255);
assign w_arp_start = risposta_rapida&arp&(&w_arp_ip_vero);
assign w_e1r_start = risposta_rapida&risposta_e1lung&port_f_vero&pd_mac_f_vero&pd_ip_f_vero;
always_ff @(posedge clk)
begin
if (rst__l) begin
    risp_busy <= 0;
end
else begin
    if (risp_busy) begin
        risp_busy <= ~((pd_arp_valid&pd_arp_last)|(pd_e1r_valid&pd_e1r_last)|(pd_drisp_valid&pd_drisp_last));
    end
    else begin
        risp_busy <= w_arp_start|w_e1r_start|i_elB_lung_event;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_risposta <= 0;
end
else begin
    valid_risposta <= pd_arp_valid|pd_e1r_valid|pd_drisp_valid;
end
end
always_ff @(posedge clk)
begin
    if (pd_arp_valid) begin
        data_risposta <= pd_arp_data;
    end
    else if (pd_e1r_valid) begin
        data_risposta <= pd_e1r_data;
    end
    else begin
        data_risposta <= pd_drisp_data;
    end
end
always_ff @(posedge clk)
begin
    if (pd_arp_valid) begin
        keep_risposta <= (pd_arp_last)?2'b01:2'b11;
    end
    else if (pd_e1r_valid) begin
        keep_risposta <= (pd_e1r_last)?2'b01:2'b11;
    end
    else begin
        keep_risposta <= (pd_drisp_last)?2'b01:2'b11;
    end
end
always_ff @(posedge clk)
begin
    if (pd_arp_valid) begin
        last_risposta <= pd_arp_last;
    end
    else if (pd_e1r_valid) begin
        last_risposta <= pd_e1r_last;
    end
    else begin
        last_risposta <= pd_drisp_last;
    end
end
always_ff @(posedge clk)
begin
    if (risposta_rapida|(zona_pld&(~i_payload_busy))) begin
        pld_sh <= {i_rx_data[3],i_rx_data[2]};
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    zona_pld <= 0;
end
else begin
    if (zona_pld) begin
        if (~i_payload_busy) begin
            zona_pld <= ~i_rx_last;
        end
    end
    else begin
        zona_pld <= risposta_rapida&lung_coretta&port_f_vero&pd_mac_f_vero&pd_ip_f_vero;
    end
end
end
assign od_risp_busy = risp_busy;
assign od_payload_2B = pld_sh;
assign od_payload_zona = zona_pld;
assign od_payload_lung8k = data_8k;
assign od_data_txbuf = data_risposta;
assign od_keep_txbuf = keep_risposta;
assign od_last_txbuf = last_risposta;
assign od_valid_txbuf = valid_risposta;

endmodule