`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_host_fpga_indirizio (
    input  bit clk,
    input  bit [7:0] i_data[3:0],
    input  bit i_valid,
    input  bit [3:0] i_ricezione_count,
    input  bit i_arp,
    output bit [7:0] od_host_mac[5:0],
    output bit [7:0] od_fpga_mac[5:0],
    output bit [7:0] od_host_ip[3:0],
    output bit [7:0] od_fpga_ip[3:0],
    output bit od_mac_f_vero,
    output bit od_ip_f_vero
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [7:0] mac[6] = '{51,17,34,0,170,187};
localparam bit [7:0] ip[4] = '{192,168,19,128};
bit [7:0] host_mac[5:0];
bit [7:0] fpga_mac[5:0];
bit [7:0] host_ip[3:0];
bit [7:0] fpga_ip[3:0];
bit mac_f_vero;
bit ip_f_vero;
bit [5:0] w_mac_f_vero;
bit [3:0] w_ip_f_vero;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_ricezione_count==0) begin
            fpga_mac[0] <= i_data[0];
            fpga_mac[1] <= i_data[1];
            fpga_mac[2] <= i_data[2];
            fpga_mac[3] <= i_data[3];
        end
        if (i_ricezione_count==1) begin
            fpga_mac[4] <= i_data[0];
            fpga_mac[5] <= i_data[1];
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_ricezione_count==1) begin
            host_mac[0] <= i_data[2];
            host_mac[1] <= i_data[3];
        end
        if (i_ricezione_count==2) begin
            host_mac[2] <= i_data[0];
            host_mac[3] <= i_data[1];
            host_mac[4] <= i_data[2];
            host_mac[5] <= i_data[3];
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_arp) begin
            if (i_ricezione_count==7) begin
                host_ip[0] <= i_data[0];
                host_ip[1] <= i_data[1];
                host_ip[2] <= i_data[2];
                host_ip[3] <= i_data[3];
            end
        end
        else begin
            if (i_ricezione_count==6) begin
                host_ip[0] <= i_data[2];
                host_ip[1] <= i_data[3];
            end
            if (i_ricezione_count==7) begin
                host_ip[2] <= i_data[0];
                host_ip[3] <= i_data[1];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_arp) begin
            if (i_ricezione_count==9) begin
                fpga_ip[0] <= i_data[2];
                fpga_ip[1] <= i_data[3];
            end
            if (i_ricezione_count==10) begin
                fpga_ip[2] <= i_data[0];
                fpga_ip[3] <= i_data[1];
            end
        end
        else begin
            if (i_ricezione_count==7) begin
                fpga_ip[0] <= i_data[2];
                fpga_ip[1] <= i_data[3];
            end
            if (i_ricezione_count==8) begin
                fpga_ip[2] <= i_data[0];
                fpga_ip[3] <= i_data[1];
            end
        end
    end
end
always_comb
begin
    for (int i=0; i<6; i++) begin
        w_mac_f_vero[i] = (fpga_mac[i]==mac[i]);
    end
end
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_ricezione_count==9) begin
            mac_f_vero <= &w_mac_f_vero;
        end
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        w_ip_f_vero[i] = (fpga_ip[i]==ip[i]);
    end
end
always_ff @(posedge clk)
begin
    if (i_valid) begin
        if (i_ricezione_count==9) begin
            ip_f_vero <= &w_ip_f_vero;
        end
    end
end
always_comb
begin
    for (int i=0; i<6; i++) begin
        od_host_mac[i] = host_mac[i];
    end
end
always_comb
begin
    for (int i=0; i<6; i++) begin
        od_fpga_mac[i] = fpga_mac[i];
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_host_ip[i] = host_ip[i];
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_fpga_ip[i] = fpga_ip[i];
    end
end
assign od_mac_f_vero = mac_f_vero;
assign od_ip_f_vero = ip_f_vero;

endmodule