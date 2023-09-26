`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module common_FIFO_L1D_O5W4T0 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_write,
    input  bit [3:0] i_data,
    input  bit i_read,
    output bit [3:0] od_data,
    output bit od_valid,
    output bit od_empty,
    output bit od_wr_ready
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [5:0] difference;
bit [4:0] addra_bram;
bit [4:0] addrb_bram;
bit valid;
bit write_ready;
bit w_enable_read;

common_distrib_reg_O5W4 u_mem_distrib
(
    .clk                 (clk),
    .i_ena               (i_write),
    .i_addra             (addra_bram),
    .i_data              (i_data),
    .i_enb               (w_enable_read),
    .i_addrb             (addrb_bram),
    .od_ram              (od_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign w_enable_read = i_read&~difference[5];
always_ff @(posedge clk)
begin
if (i_rst) begin
    difference <= -1;
end
else begin
    if (i_write==w_enable_read) begin
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
    addrb_bram <= (w_enable_read)?addrb_bram+1:addrb_bram;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= w_enable_read;
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