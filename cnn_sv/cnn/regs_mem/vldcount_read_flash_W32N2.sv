`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module regs_mem_vldcount_read_flash_W32N2 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_count_en[1:0],
    input  bit i_read,
    output bit [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [31:0] data[1:0];
bit addr_rd;
bit [1:0] std_rd;

separ_union_mux_int_vld_unsign_W32N2 u_omux
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
    if (i_read) begin
        addr_rd <= (addr_rd==2-1)?0:addr_rd+1;
    end
    else begin
        addr_rd <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (i_read) begin
        std_rd <= {std_rd[0:0],std_rd[1]};
    end
    else begin
        std_rd <= 1;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data[0] <= 0;
    data[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        data[i] <= (std_rd[i]&i_read)?i_count_en[i]:data[i]+i_count_en[i];
    end
end
end

endmodule