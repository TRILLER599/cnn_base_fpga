`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_gradiente_buffer_W14C4O11 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[3:0],
    input  bit i_data_vld[3:0],
    input  bit i_read[3:0],
    output bit [13:0] od_data[3:0],
    output bit od_empty,
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [11:0] counter_traboccare;
bit errore_traboccare;
bit pd_valid[3:0];
bit pd_empty[3:0];
bit pd_wr_ready[3:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<4;i++) begin : gen__common_FIFO_L2_O11W14T2046
    common_FIFO_L2_O11W14T2046 u_buffer
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_write             (i_data_vld[i]),
        .i_data              (i_data[i]),
        .i_read              (i_read[i]),
        .od_data             (od_data[i]),
        .od_valid            (pd_valid[i]),
        .od_empty            (pd_empty[i]),
        .od_wr_ready         (pd_wr_ready[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk)
begin
if (rst__l) begin
    counter_traboccare <= 0;
end
else begin
    if (i_read[0]&~pd_empty[0]) begin
        counter_traboccare <= counter_traboccare+i_data_vld[0]-1;
    end
    else begin
        counter_traboccare <= counter_traboccare+i_data_vld[0];
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore_traboccare <= 0;
end
else begin
    if (counter_traboccare[11]) begin
        errore_traboccare <= 1;
    end
end
end
assign od_empty = pd_empty[4-1];
assign od_errore = errore_traboccare;

endmodule