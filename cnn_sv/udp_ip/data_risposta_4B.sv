`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_data_risposta_4B (
    input  bit clk,
    input  bit i_rst,
    input  bit [7:0] i_mac_host[5:0],
    input  bit [7:0] i_ip_host,
    input  bit [7:0] i_port_host[1:0],
    input  bit [31:0] i_data,
    input  bit i_valid,
    input  bit [1:0] i_lung_index,
    input  bit i_lung_event,
    input  bit i_ready,
    output bit [31:0] od_data,
    output bit od_valid,
    output bit od_last
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [7:0] mac_fpga_const[6] = '{51,17,34,0,170,187};
localparam bit [7:0] ip_fpga_const[4] = '{192,168,19,128};
bit tx_ready;
bit [1:0] lung_index;
bit [16:0] ip_crc_17b;
bit [15:0] ip_crc;
bit [3:0] counter_risp;
bit start_risp;
bit busy_risp;
bit valid;
bit last;
bit read_pld;
bit last_pld;
bit [10:0] counter_pld;
bit [7:0] data[3:0];
bit [7:0] data_pld_B2;
bit [7:0] data_pld_B3;
bit [10:0] w_lungezza_32b;
bit [15:0] w_ip_lung;
bit [15:0] w_udp_lung;
bit w_read_pld;
bit pd_empty_pld;
bit pd_ready_pld;
bit [31:0] pd_data_pld;

common_FIFO_Fast_O11W32T0 u_fifo_pld
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_write             (i_valid),
    .i_data              (i_data),
    .i_read              (w_read_pld),
    .od_data             (pd_data_pld),
    .od_empty            (pd_empty_pld),
    .od_wr_ready         (pd_ready_pld)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    start_risp <= i_lung_event;
end
always_ff @(posedge clk)
begin
    if (i_lung_event) begin
        lung_index <= i_lung_index;
    end
end
always_ff @(posedge clk)
begin
    tx_ready <= i_ready;
end
always_comb
begin
    if (lung_index==0) begin
        w_lungezza_32b = 7;
    end
    else if (lung_index==1) begin
        w_lungezza_32b = 255;
    end
    else begin
        w_lungezza_32b = 2047;
    end
end
always_comb
begin
    if (lung_index==0) begin
        w_ip_lung = 60;
    end
    else if (lung_index==1) begin
        w_ip_lung = 1052;
    end
    else begin
        w_ip_lung = 8220;
    end
end
always_comb
begin
    if (lung_index==0) begin
        w_udp_lung = 40;
    end
    else if (lung_index==1) begin
        w_udp_lung = 1032;
    end
    else begin
        w_udp_lung = 8200;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    busy_risp <= 0;
end
else begin
    if (busy_risp) begin
        busy_risp <= ~(tx_ready&last_pld);
    end
    else begin
        busy_risp <= i_lung_event;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_risp <= 0;
end
else begin
    if (busy_risp) begin
        if (tx_ready) begin
            if ((counter_risp<10)|((counter_risp==10)&(~pd_empty_pld))) begin
                counter_risp <= counter_risp+1;
            end
        end
    end
    else begin
        counter_risp <= 0;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    read_pld <= 0;
end
else begin
    if (read_pld) begin
        if (tx_ready&(~pd_empty_pld)) begin
            if (counter_pld==w_lungezza_32b) begin
                read_pld <= 0;
            end
        end
    end
    else begin
        read_pld <= tx_ready&(counter_risp==9);
    end
end
end
always_ff @(posedge clk)
begin
    if (read_pld) begin
        if (tx_ready&(~pd_empty_pld)) begin
            counter_pld <= counter_pld+1;
        end
    end
    else begin
        counter_pld <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    last_pld <= 0;
end
else begin
    if (last_pld) begin
        last_pld <= ~tx_ready;
    end
    else begin
        last_pld <= tx_ready&(~pd_empty_pld)&(counter_pld==w_lungezza_32b);
    end
end
end
always_ff @(posedge clk)
begin
    if (i_lung_event) begin
        if (i_lung_index==0) begin
            ip_crc_17b <= i_ip_host+11519+32;
        end
        else if (i_lung_index==1) begin
            ip_crc_17b <= i_ip_host+11519+1024;
        end
        else begin
            ip_crc_17b <= i_ip_host+11519+8192;
        end
    end
end
always_ff @(posedge clk)
begin
    if (start_risp) begin
        ip_crc <= ~(ip_crc_17b[15:0]+ip_crc_17b[16]);
    end
end
always_ff @(posedge clk)
begin
    if (counter_risp==0) begin
        data[0] <= i_mac_host[0];
        data[1] <= i_mac_host[1];
        data[2] <= i_mac_host[2];
        data[3] <= i_mac_host[3];
    end
    else if (counter_risp==1) begin
        data[0] <= i_mac_host[4];
        data[1] <= i_mac_host[5];
        data[2] <= mac_fpga_const[0];
        data[3] <= mac_fpga_const[1];
    end
    else if (counter_risp==2) begin
        data[0] <= mac_fpga_const[2];
        data[1] <= mac_fpga_const[3];
        data[2] <= mac_fpga_const[4];
        data[3] <= mac_fpga_const[5];
    end
    else if (counter_risp==3) begin
        data[0] <= 8;
        data[1] <= 0;
        data[2] <= 69;
        data[3] <= 0;
    end
    else if (counter_risp==4) begin
        data[0] <= w_ip_lung[15:8];
        data[1] <= w_ip_lung[7:0];
        data[2] <= 0;
        data[3] <= 0;
    end
    else if (counter_risp==5) begin
        data[0] <= 0<<<5;
        data[1] <= 0;
        data[2] <= 64;
        data[3] <= 17;
    end
    else if (counter_risp==6) begin
        data[0] <= ip_crc[15:8];
        data[1] <= ip_crc[7:0];
        data[2] <= ip_fpga_const[0];
        data[3] <= ip_fpga_const[1];
    end
    else if (counter_risp==7) begin
        data[0] <= ip_fpga_const[2];
        data[1] <= ip_fpga_const[3];
        data[2] <= ip_fpga_const[0];
        data[3] <= ip_fpga_const[1];
    end
    else if (counter_risp==8) begin
        data[0] <= ip_fpga_const[2];
        data[1] <= i_ip_host;
        data[2] <= 27;
        data[3] <= 95;
    end
    else if (counter_risp==9) begin
        data[0] <= i_port_host[0];
        data[1] <= i_port_host[1];
        data[2] <= w_udp_lung[15:8];
        data[3] <= w_udp_lung[7:0];
    end
    else if (counter_risp==10) begin
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= pd_data_pld[7:0];
        data[3] <= pd_data_pld[15:8];
    end
    else begin
        data[0] <= data_pld_B2;
        data[1] <= data_pld_B3;
        data[2] <= pd_data_pld[7:0];
        data[3] <= pd_data_pld[15:8];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    if (last_pld) begin
        valid <= tx_ready;
    end
    else if (read_pld) begin
        valid <= tx_ready&(~pd_empty_pld);
    end
    else begin
        valid <= tx_ready&busy_risp;
    end
end
end
always_ff @(posedge clk)
begin
    last <= last_pld;
end
assign w_read_pld = tx_ready&read_pld;
always_ff @(posedge clk)
begin
    if (tx_ready&read_pld&(~pd_empty_pld)) begin
        data_pld_B2 <= pd_data_pld[23:16];
    end
end
always_ff @(posedge clk)
begin
    if (tx_ready&read_pld&(~pd_empty_pld)) begin
        data_pld_B3 <= pd_data_pld[31:24];
    end
end
assign od_data = {data[3],data[2],data[1],data[0]};
assign od_valid = valid;
assign od_last = last;

endmodule