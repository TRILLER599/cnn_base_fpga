`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_errore1_risposta_4B (
    input  bit clk,
    input  bit i_rst,
    input  bit [7:0] i_mac_host[5:0],
    input  bit [7:0] i_ip_host,
    input  bit [7:0] i_port_host[1:0],
    input  bit [15:0] i_lunghezza,
    input  bit [31:0] i_pacco_ultimo,
    input  bit i_start_risp,
    input  bit i_ready,
    output bit [31:0] od_data,
    output bit od_valid,
    output bit od_last
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [7:0] mac_fpga_const[6] = '{51,17,34,0,170,187};
localparam bit [7:0] ip_fpga_const[4] = '{192,168,19,128};
bit [4:0] counter_risp;
bit [3:0] counter_risp_corto;
bit busy_risp;
bit valid;
bit last;
bit [15:0] ip_crc;
bit [7:0] data[3:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    busy_risp <= 0;
end
else begin
    if (busy_risp) begin
        if (i_ready) begin
            if (counter_risp==18) begin
                busy_risp <= 0;
            end
        end
    end
    else begin
        busy_risp <= i_start_risp;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    last <= 0;
end
else begin
    if (busy_risp) begin
        if (i_ready) begin
            if (counter_risp==18) begin
                last <= 1;
            end
            else begin
                last <= 0;
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
    if (busy_risp) begin
        if (i_ready) begin
            counter_risp <= counter_risp+1;
        end
    end
    else begin
        counter_risp <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (busy_risp) begin
        if (i_ready) begin
            if (counter_risp_corto!=15) begin
                counter_risp_corto <= counter_risp_corto+1;
            end
        end
    end
    else begin
        counter_risp_corto <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (i_start_risp&(~busy_risp)) begin
        ip_crc <= ~(i_ip_host+11551);
    end
end
always_ff @(posedge clk)
begin
    if (counter_risp_corto==0) begin
        data[0] <= i_mac_host[0];
        data[1] <= i_mac_host[1];
        data[2] <= i_mac_host[2];
        data[3] <= i_mac_host[3];
    end
    else if (counter_risp_corto==1) begin
        data[0] <= i_mac_host[4];
        data[1] <= i_mac_host[5];
        data[2] <= mac_fpga_const[0];
        data[3] <= mac_fpga_const[1];
    end
    else if (counter_risp_corto==2) begin
        data[0] <= mac_fpga_const[2];
        data[1] <= mac_fpga_const[3];
        data[2] <= mac_fpga_const[4];
        data[3] <= mac_fpga_const[5];
    end
    else if (counter_risp_corto==3) begin
        data[0] <= 8;
        data[1] <= 0;
        data[2] <= 69;
        data[3] <= 0;
    end
    else if (counter_risp_corto==4) begin
        data[0] <= 0;
        data[1] <= 60;
        data[2] <= 0;
        data[3] <= 0;
    end
    else if (counter_risp_corto==5) begin
        data[0] <= 0<<<5;
        data[1] <= 0;
        data[2] <= 64;
        data[3] <= 17;
    end
    else if (counter_risp_corto==6) begin
        data[0] <= ip_crc[15:8];
        data[1] <= ip_crc[7:0];
        data[2] <= ip_fpga_const[0];
        data[3] <= ip_fpga_const[1];
    end
    else if (counter_risp_corto==7) begin
        data[0] <= ip_fpga_const[2];
        data[1] <= ip_fpga_const[3];
        data[2] <= ip_fpga_const[0];
        data[3] <= ip_fpga_const[1];
    end
    else if (counter_risp_corto==8) begin
        data[0] <= ip_fpga_const[2];
        data[1] <= i_ip_host;
        data[2] <= 27;
        data[3] <= 95;
    end
    else if (counter_risp_corto==9) begin
        data[0] <= i_port_host[0];
        data[1] <= i_port_host[1];
        data[2] <= 0;
        data[3] <= 40;
    end
    else if (counter_risp_corto==10) begin
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= 0;
        data[3] <= 0;
    end
    else if (counter_risp_corto==11) begin
        data[0] <= 0;
        data[1] <= 128;
        data[2] <= 0;
        data[3] <= 0;
    end
    else if (counter_risp_corto==12) begin
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= 1;
        data[3] <= 0;
    end
    else if (counter_risp_corto==13) begin
        data[0] <= i_lunghezza[7:0];
        data[1] <= i_lunghezza[15:8];
        data[2] <= i_pacco_ultimo[7:0];
        data[3] <= i_pacco_ultimo[15:8];
    end
    else if (counter_risp_corto==14) begin
        data[0] <= i_pacco_ultimo[23:16];
        data[1] <= i_pacco_ultimo[31:24];
        data[2] <= 0;
        data[3] <= 0;
    end
    else begin
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= 0;
        data[3] <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= i_ready&busy_risp;
end
end
assign od_data = {data[3],data[2],data[1],data[0]};
assign od_valid = valid;
assign od_last = last;

endmodule