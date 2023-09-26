`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_FIFO_Fast_Array_O10W14T1022A1 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_write,
    input  bit [13:0] i_data[0:0],
    input  bit i_read,
    output bit [13:0] od_data[0:0],
    output bit od_empty,
    output bit od_wr_ready
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [9:0] addra_bram;
bit [9:0] addrb_bram;
bit [10:0] difference;
bit need_read;
bit internal_read;
bit empty;
bit [2:0] presence;
bit write_ready;
bit [13:0] data_3[0:0];
bit [13:0] data_2[0:0];
bit [13:0] data_1[0:0];
bit enable_read;
bit [13:0] pd_ram_data[0:0];
bit presence_3;
bit [5:0] presence_long;
bit [2:0] presence_count;
bit pip_update;

function automatic bit [2:0] func__countbits_6(input bit [5:0] i_data);
    func__countbits_6 = 0;
    for (int i=0; i<6; i++) begin
        if (i_data[i])
            func__countbits_6++;
    end
endfunction

common_bram_reg_array_riduzione_O10W14A1 u_bram_reg
(
    .clk                 (clk),
    .is0_ena             (i_write),
    .is0_addra           (addra_bram),
    .is0_data            (i_data),
    .is1_enb             (enable_read),
    .is1_addrb           (addrb_bram),
    .i_enb_reg           (internal_read),
    .od_data             (pd_ram_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign enable_read = need_read&~difference[10];
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
always_ff @(posedge clk)
begin
if (i_rst) begin
    internal_read <= 0;
end
else begin
    internal_read <= enable_read;
end
end
assign presence_3 = ~empty;
assign presence_long = {presence_3,presence,internal_read,enable_read};
assign presence_count = func__countbits_6(presence_long);
always_ff @(posedge clk)
begin
if (i_rst) begin
    need_read <= 0;
end
else begin
    need_read <= (presence_count<4)|i_read;
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
    if (~difference[10]&(difference[9:0]>1022)) begin
        write_ready <= 0;
    end
    else begin
        write_ready <= 1;
    end
end
end
assign pip_update = empty|(~empty&i_read);
always_ff @(posedge clk)
begin
if (i_rst) begin
    empty <= 1;
end
else begin
    if (pip_update) begin
        empty <= ~(|presence);
    end
    else begin
        empty <= 0;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    presence <= 0;
end
else begin
    if (pip_update) begin
        presence[2] <= &presence[2:1];
        presence[1] <= (presence[2])?presence[0]:&presence[1:0];
        presence[0] <= internal_read;
    end
    else begin
        presence[2] <= |presence[2:1];
        presence[1] <= (presence[2])?|presence[1:0]:presence[0];
        presence[0] <= (&presence[2:1])?presence[0]|internal_read:internal_read;
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (pip_update) begin
            if (presence[2]) begin
                data_3[i] <= data_2[i];
            end
            else if (presence[1]) begin
                data_3[i] <= data_1[i];
            end
            else begin
                data_3[i] <= pd_ram_data[i];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (pip_update) begin
            if (&presence[2:1]) begin
                data_2[i] <= data_1[i];
            end
        end
        else begin
            if (presence[2:1]==2'b01) begin
                data_2[i] <= data_1[i];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (pip_update) begin
            if (|presence[2:1]&presence[0]) begin
                data_1[i] <= pd_ram_data[i];
            end
        end
        else begin
            if ((presence[2:1]!=2'b11)&presence[0]) begin
                data_1[i] <= pd_ram_data[i];
            end
        end
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data[i] = data_3[i];
    end
end
assign od_empty = empty;
assign od_wr_ready = write_ready;

endmodule