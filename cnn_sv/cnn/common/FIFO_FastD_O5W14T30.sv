`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_FIFO_FastD_O5W14T30 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_write,
    input  bit [13:0] i_data,
    input  bit i_read,
    output bit [13:0] od_data,
    output bit od_empty,
    output bit od_wr_ready
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [4:0] addra_bram;
bit [4:0] addrb_bram;
bit [5:0] difference;
bit need_read;
bit empty;
bit presence_1;
bit presence_0;
bit write_ready;
bit [13:0] data_2;
bit [13:0] data_1;
bit enable_read;
bit [13:0] pd_ram_data;
bit presence_2;
bit [3:0] presence_long;
bit [2:0] presence_count;

function automatic bit [2:0] func__countbits_4(input bit [3:0] i_data);
    func__countbits_4 = 0;
    for (int i=0; i<4; i++) begin
        if (i_data[i])
            func__countbits_4++;
    end
endfunction

common_distrib_reg_O5W14 u_distrib
(
    .clk                 (clk),
    .i_ena               (i_write),
    .i_addra             (addra_bram),
    .i_data              (i_data),
    .i_enb               (enable_read),
    .i_addrb             (addrb_bram),
    .od_ram              (pd_ram_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign enable_read = need_read&~difference[5];
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra_bram <= 0;
end
else begin
    addra_bram <= (i_write)?addra_bram+1:addra_bram;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb_bram <= 0;
end
else begin
    addrb_bram <= (enable_read)?addrb_bram+1:addrb_bram;
end
end
assign presence_2 = ~empty;
assign presence_long = {presence_2,presence_1,presence_0,enable_read};
assign presence_count = func__countbits_4(presence_long);
always_ff @(posedge clk)
begin
if (i_rst) begin
    need_read <= 0;
end
else begin
    need_read <= (presence_count<3)|i_read;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    difference <= -1;
end
else begin
    if (i_write==enable_read) begin
        difference <= difference;
    end
    else if (i_write) begin
        difference <= difference+1;
    end
    else begin
        difference <= difference-1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    write_ready <= 0;
end
else begin
    if (~difference[5]&(difference[4:0]>30)) begin
        write_ready <= 0;
    end
    else begin
        write_ready <= 1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    empty <= 1;
end
else begin
    if (empty==0) begin
        if (i_read) begin
            empty <= ~(presence_1|presence_0);
        end
        else begin
            empty <= 0;
        end
    end
    else begin
        empty <= ~(presence_1|presence_0);
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    presence_1 <= 0;
end
else begin
    if (empty==0) begin
        if (i_read) begin
            presence_1 <= presence_1&presence_0;
        end
        else begin
            presence_1 <= presence_1|presence_0;
        end
    end
    else begin
        presence_1 <= presence_1&presence_0;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    presence_0 <= 0;
end
else begin
    if (empty==0) begin
        if (i_read) begin
            presence_0 <= enable_read;
        end
        else begin
            presence_0 <= (presence_1)?(presence_0|enable_read):enable_read;
        end
    end
    else begin
        presence_0 <= enable_read;
    end
end
end
always_ff @(posedge clk)
begin
    if (empty|(~empty&i_read)) begin
        data_2 <= (presence_1)?data_1:pd_ram_data;
    end
end
always_ff @(posedge clk)
begin
    if ((empty|(~empty&i_read)|(~presence_1))&presence_0) begin
        data_1 <= pd_ram_data;
    end
end
assign od_data = data_2;
assign od_empty = empty;
assign od_wr_ready = write_ready;

endmodule