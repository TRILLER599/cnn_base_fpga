`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_arp_risposta_4B (
    input  bit clk,
    input  bit i_rst,
    input  bit [7:0] i_mac_host[5:0],
    input  bit [7:0] i_ip_host[3:0],
    input  bit i_start_risp,
    input  bit i_ready,
    output bit [31:0] od_data,
    output bit od_valid,
    output bit od_last
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [7:0] mac_fpga[6] = '{51,17,34,0,170,187};
localparam bit [7:0] ip_fpga[4] = '{192,168,19,128};
bit [7:0] mac_host[5:0];
bit [7:0] ip_host[3:0];
bit [3:0] counter_risp;
bit busy_risp;
bit valid;
bit last;
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
            if (counter_risp==10) begin
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
            if (counter_risp==10) begin
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
if (i_rst) begin
    counter_risp <= 0;
end
else begin
    if (busy_risp) begin
        if (i_ready) begin
            counter_risp <= counter_risp+1;
        end
    end
    else begin
        counter_risp <= 0;
    end
end
end
always_ff @(posedge clk)
begin
    if (i_start_risp&(~busy_risp)) begin
        for (int i=0; i<6; i++) begin
            mac_host[i] <= i_mac_host[i];
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_start_risp&(~busy_risp)) begin
        ip_host[0] <= i_ip_host[0];
        ip_host[1] <= i_ip_host[1];
        ip_host[2] <= i_ip_host[2];
        ip_host[3] <= i_ip_host[3];
    end
end
always_ff @(posedge clk)
begin
    if (counter_risp==0) begin
        data[0] <= mac_host[0];
        data[1] <= mac_host[1];
        data[2] <= mac_host[2];
        data[3] <= mac_host[3];
    end
    else if (counter_risp==1) begin
        data[0] <= mac_host[4];
        data[1] <= mac_host[5];
        data[2] <= mac_fpga[0];
        data[3] <= mac_fpga[1];
    end
    else if (counter_risp==2) begin
        data[0] <= mac_fpga[2];
        data[1] <= mac_fpga[3];
        data[2] <= mac_fpga[4];
        data[3] <= mac_fpga[5];
    end
    else if (counter_risp==3) begin
        data[0] <= 8;
        data[1] <= 6;
        data[2] <= 0;
        data[3] <= 1;
    end
    else if (counter_risp==4) begin
        data[0] <= 8;
        data[1] <= 0;
        data[2] <= 6;
        data[3] <= 4;
    end
    else if (counter_risp==5) begin
        data[0] <= 0;
        data[1] <= 2;
        data[2] <= mac_fpga[0];
        data[3] <= mac_fpga[1];
    end
    else if (counter_risp==6) begin
        data[0] <= mac_fpga[2];
        data[1] <= mac_fpga[3];
        data[2] <= mac_fpga[4];
        data[3] <= mac_fpga[5];
    end
    else if (counter_risp==7) begin
        data[0] <= ip_fpga[0];
        data[1] <= ip_fpga[1];
        data[2] <= ip_fpga[2];
        data[3] <= ip_fpga[3];
    end
    else if (counter_risp==8) begin
        data[0] <= mac_host[0];
        data[1] <= mac_host[1];
        data[2] <= mac_host[2];
        data[3] <= mac_host[3];
    end
    else if (counter_risp==9) begin
        data[0] <= mac_host[4];
        data[1] <= mac_host[5];
        data[2] <= ip_host[0];
        data[3] <= ip_host[1];
    end
    else if (counter_risp==10) begin
        data[0] <= ip_host[2];
        data[1] <= ip_host[3];
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