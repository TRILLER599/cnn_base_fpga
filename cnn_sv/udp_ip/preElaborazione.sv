`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_preElaborazione 
#(
	parameter bit [7:0] mac[6] = '{51,17,34,0,170,187},
    parameter bit [7:0] ip[4] = '{192,168,19,128}
)
(
    input  bit clk,
    input  bit i_rst_g,
    input  bit [31:0] i_rx_data,
    input  bit i_rx_valid,
    input  bit i_rx_last,
    output bit [31:0] od_data,
    output bit od_valid,
    output bit od_last,
    output bit od_errore_ovrf
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
// localparam bit [7:0] mac[6] = '{51,17,34,0,170,187};
// localparam bit [7:0] ip[4] = '{192,168,19,128};
bit [3:0] intest_count;
bit [11:0] ricezione_count;
bit [11:0] start_addr_wr;
bit pacco_start;
bit troppo_lungo;
bit mac_f_vero;
bit mac_multi_vero;
bit arp;
bit ip_prot;
bit udp_prot;
bit port_f_vero;
bit ipaddr_f_vero;
bit ipaddr_arp_vero;
bit [15:0] ippacco_lunghezza;
bit [13:0] pacco_lunghezza_4B_meno1;
bit [11:0] reading_count;
bit valid;
bit meml_ovrf;
bit [1:0] last;
bit ena_memd;
bit enb_memd;
bit enb_memd_reg;
bit [11:0] addra_memd;
bit [11:0] addrb_memd;
bit [31:0] dia_memd;
bit ena_meml;
bit [11:0] dia_meml;
bit [7:0] w_rx_data[3:0];
bit [15:0] w_rx_B0B1;
bit [15:0] w_pacco_lunghezza;
bit w_reading_last;
bit [11:0] pd_meml_dob;
bit w_enb_meml;
bit pd_meml_empty;
bit pd_meml_ready;
bit rst__pip;
bit rst__l;

common_bram_reg_O12W32 u_memd
(
    .clk                 (clk),
    .is0_ena             (ena_memd),
    .is0_addra           (addra_memd),
    .is0_data            (dia_memd),
    .is1_enb             (enb_memd),
    .is1_addrb           (addrb_memd),
    .i_enb_reg           (enb_memd_reg),
    .od_ram              (od_data)
);
common_FIFO_FastD_O5W12T29 u_meml
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (ena_meml),
    .i_data              (dia_meml),
    .i_read              (w_enb_meml),
    .od_data             (pd_meml_dob),
    .od_empty            (pd_meml_empty),
    .od_wr_ready         (pd_meml_ready)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_comb
begin
    for (int i=0; i<4; i++) begin
        w_rx_data[i] = i_rx_data[8*i+:8];
    end
end
assign w_rx_B0B1 = {i_rx_data[7:0],i_rx_data[15:8]};
always_ff @(posedge clk)
begin
if (rst__l) begin
    intest_count <= 0;
end
else begin
    if (i_rx_valid) begin
        if (i_rx_last) begin
            intest_count <= 0;
        end
        else begin
            intest_count <= (&intest_count)?intest_count:intest_count+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ricezione_count <= 0;
end
else begin
    if (i_rx_valid) begin
        if (i_rx_last) begin
            ricezione_count <= 0;
        end
        else begin
            ricezione_count <= ricezione_count+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pacco_start <= 1;
end
else begin
    if (i_rx_valid) begin
        pacco_start <= i_rx_last;
    end
end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==0) begin
            if (mac[0]==w_rx_data[0]&&mac[1]==w_rx_data[1]&&mac[2]==w_rx_data[2]&&mac[3]==w_rx_data[3]) begin
                mac_f_vero <= 1;
            end
            else begin
                mac_f_vero <= 0;
            end
        end
        else if (intest_count==1) begin
            mac_f_vero <= mac_f_vero&&mac[4]==w_rx_data[0]&&mac[5]==w_rx_data[1];
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==0) begin
            if (w_rx_data[0]==255&&w_rx_data[1]==255&&w_rx_data[2]==255&&w_rx_data[3]==255) begin
                mac_multi_vero <= 1;
            end
            else begin
                mac_multi_vero <= 0;
            end
        end
        else if (intest_count==1) begin
            mac_multi_vero <= mac_multi_vero&&w_rx_data[0]==255&&w_rx_data[1]==255;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==3) begin
            arp <= (w_rx_data[0]==8)&(w_rx_data[1]==6);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==3) begin
            ip_prot <= (w_rx_data[0]==8)&(w_rx_data[1]==0);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==4) begin
            ippacco_lunghezza <= w_rx_B0B1;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==5) begin
            udp_prot <= mac_f_vero&&ip_prot&&(w_rx_data[3]==17);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==7) begin
            ipaddr_f_vero <= udp_prot&&(ip[0]==w_rx_data[2])&&(ip[1]==w_rx_data[3]);
        end
        else if (intest_count==8) begin
            ipaddr_f_vero <= ipaddr_f_vero&&(ip[2]==w_rx_data[0])&&(ip[3]==w_rx_data[1]);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==9) begin
            port_f_vero <= ipaddr_f_vero&&(w_rx_B0B1==7007);
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        if (intest_count==9) begin
            ipaddr_arp_vero <= (mac_f_vero||mac_multi_vero)&&w_rx_data[2]==ip[0]&&w_rx_data[3]==ip[1];
        end
        else if (intest_count==10) begin
            ipaddr_arp_vero <= ipaddr_arp_vero&&w_rx_data[0]==ip[2]&&(w_rx_data[1]==ip[3]||w_rx_data[1]==255);
        end
    end
end
assign w_pacco_lunghezza = ippacco_lunghezza+13;
always_ff @(posedge clk)
begin
    if (intest_count==5) begin
        pacco_lunghezza_4B_meno1 <= w_pacco_lunghezza[15:2];
    end
end
always_ff @(posedge clk)
begin
    if (pacco_start) begin
        troppo_lungo <= 0;
    end
    else if (ricezione_count==2080) begin
        troppo_lungo <= 1;
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid&i_rx_last) begin
        if (arp) begin
            if (ipaddr_arp_vero&&(intest_count==10||intest_count==14)&&(!troppo_lungo)) begin
                ena_meml <= 1;
            end
            else begin
                ena_meml <= 0;
            end
        end
        else begin
            if (port_f_vero&&ricezione_count>=18&&ricezione_count==pacco_lunghezza_4B_meno1&&(!troppo_lungo)) begin
                ena_meml <= 1;
            end
            else begin
                ena_meml <= 0;
            end
        end
    end
    else begin
        ena_meml <= 0;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    start_addr_wr <= 0;
end
else begin
    if (i_rx_valid&i_rx_last) begin
        if (arp) begin
            if (ipaddr_arp_vero&&(intest_count==10||intest_count==14)&&(!troppo_lungo)) begin
                start_addr_wr <= addra_memd+2;
            end
        end
        else begin
            if (port_f_vero&&ricezione_count>=18&&ricezione_count==pacco_lunghezza_4B_meno1&&(!troppo_lungo)) begin
                start_addr_wr <= addra_memd+2;
            end
        end
    end
end
end
assign w_reading_last = reading_count==pd_meml_dob;
always_ff @(posedge clk)
begin
if (rst__l) begin
    enb_memd <= 0;
end
else begin
    if (enb_memd) begin
        enb_memd <= ~w_reading_last;
    end
    else begin
        enb_memd <= ~pd_meml_empty;
    end
end
end
always_ff @(posedge clk)
begin
    if (enb_memd) begin
        reading_count <= reading_count+1;
    end
    else begin
        reading_count <= 0;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena_memd <= 0;
end
else begin
    ena_memd <= i_rx_valid;
end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        addra_memd <= (pacco_start)?start_addr_wr:addra_memd+1;
    end
end
always_ff @(posedge clk)
begin
    if (i_rx_valid) begin
        dia_memd <= i_rx_data;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addrb_memd <= 0;
end
else begin
    if (enb_memd) begin
        addrb_memd <= addrb_memd+1;
    end
end
end
always_ff @(posedge clk)
begin
    enb_memd_reg <= enb_memd;
end
always_ff @(posedge clk)
begin
    dia_meml <= ricezione_count;
end
assign w_enb_meml = enb_memd&w_reading_last;
always_ff @(posedge clk)
begin
    valid <= enb_memd_reg;
end
always_ff @(posedge clk)
begin
    last <= {last[0],w_reading_last};
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    meml_ovrf <= 0;
end
else begin
    meml_ovrf <= meml_ovrf||(pd_meml_empty==0&&pd_meml_ready==0);
end
end
assign od_valid = valid;
assign od_last = last[1];
assign od_errore_ovrf = meml_ovrf;

endmodule