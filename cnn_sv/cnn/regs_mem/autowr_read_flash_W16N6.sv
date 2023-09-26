`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module regs_mem_autowr_read_flash_W16N6 (
    input  bit clk,
    input  bit i_rst,
    input  bit [15:0] i_data[5:0],
    input  bit i_read,
    output bit [15:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit flash_inizio;
bit [15:0] data[5:0];
bit [2:0] addr_rd;
bit [5:0] std_rd;

separ_union_mux_int_vld_unsign_W16N6 u_omux
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (data),
    .i_valid             (i_read),
    .i_mux               (addr_rd),
    .od_data             (od_data),
    .od_valid            (od_valid)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    flash_inizio <= 1;
end
else begin
    flash_inizio <= 0;
end
end
always_ff @(posedge clk)
begin
    if (i_read) begin
        addr_rd <= (addr_rd==6-1)?0:addr_rd+1;
    end
    else begin
        addr_rd <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (i_read) begin
        std_rd <= {std_rd[4:0],std_rd[5]};
    end
    else begin
        std_rd <= 1;
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<6; i++) begin
        if (flash_inizio|(std_rd[i]&i_read)) begin
            data[i] <= i_data[i];
        end
        else begin
            data[i] <= i_data[i]|data[i];
        end
    end
end

endmodule