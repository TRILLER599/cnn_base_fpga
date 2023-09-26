`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_FIFO_L2_O5W14T0 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_write,
    input  bit [13:0] i_data,
    input  bit i_read,
    output bit [13:0] od_data,
    output bit od_valid,
    output bit od_empty,
    output bit od_wr_ready
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [4:0] addra_bram;
bit [4:0] addrb_bram;
bit [5:0] difference;
bit write_ready;
bit internal_read;
bit valid;
bit enable_read;

common_bram_reg_O5W14 u_bram_reg
(
    .clk                 (clk),
    .is0_ena             (i_write),
    .is0_addra           (addra_bram),
    .is0_data            (i_data),
    .is1_enb             (enable_read),
    .is1_addrb           (addrb_bram),
    .i_enb_reg           (internal_read),
    .od_ram              (od_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign enable_read = i_read&~difference[5];
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
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= internal_read;
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
    write_ready <= 1;
end
end
assign od_valid = valid;
assign od_empty = difference[5];
assign od_wr_ready = write_ready;

endmodule