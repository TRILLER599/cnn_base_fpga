`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module pool_v0_passaggio_ritorno_W14C4C1C2P2L12P3N0 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_valid[0:0],
    input  bit [1:0] i_index[1:0],
    input  bit i_index_vld[3:0],
    output bit [13:0] od_data[3:0],
    output bit od_valid[3:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit const_read_en_decompr = 1;
bit [1:0] read_counter;
bit data_lungo_vld[3:0];
bit [13:0] pd_ritorno_data[0:0];
bit pd_ritorno_valid[0:0];
bit pd_ritorno_empty[0:0];
bit pd_ritorno_wr_ready[0:0];
bit [13:0] pd_data_lungo[3:0];
bit w_read_end;
bit [1:0] w_index[3:0];
bit pd_decompr_ready[3:0];
bit pd_decompr_presence[3:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<1;i++) begin : gen__common_FIFO_L2_O5W14T0
    common_FIFO_L2_O5W14T0 u_ritorno_data
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_write             (i_valid[i]),
        .i_data              (i_data[i]),
        .i_read              (pd_decompr_ready[i*4]),
        .od_data             (pd_ritorno_data[i]),
        .od_valid            (pd_ritorno_valid[i]),
        .od_empty            (pd_ritorno_empty[i]),
        .od_wr_ready         (pd_ritorno_wr_ready[i])
    );
end
endgenerate

generate
for (i=0;i<1;i++) begin : gen__shift_ureg_multi_vld_W14L4D1R0
    shift_ureg_multi_vld_W14L4D1R0 u_data_lungo
    (
        .clk                 (clk),
        .i_data              (pd_ritorno_data[i]),
        .i_valid             (pd_ritorno_valid[i]),
        .od_data             (pd_data_lungo[i*4+3:i*4])
    );
end
endgenerate

generate
for (i=0;i<4;i++) begin : gen__pool_v0_decompressione_W14P2L12P3N0
    pool_v0_decompressione_W14P2L12P3N0 u_decompressione
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (rst__l),
        .i_data              (pd_data_lungo[i]),
        .i_valid             (data_lungo_vld[i]),
        .i_index             (w_index[i]),
        .i_index_vld         (i_index_vld[i]),
        .od_ready            (pd_decompr_ready[i]),
        .i_read_en           (const_read_en_decompr),
        .od_presence         (pd_decompr_presence[i]),
        .od_data             (od_data[i]),
        .od_valid            (od_valid[i])
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

assign w_read_end = (read_counter==4-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    read_counter <= 0;
end
else begin
    if (pd_ritorno_valid[0]) begin
        read_counter <= (w_read_end)?0:read_counter+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    data_lungo_vld[0] <= 0;
    data_lungo_vld[1] <= 0;
    data_lungo_vld[2] <= 0;
    data_lungo_vld[3] <= 0;
end
else begin
    for (int i=0; i<4; i++) begin
        data_lungo_vld[i] <= w_read_end&pd_ritorno_valid[0];
    end
end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        for (int k=0; k<2; k++) begin
            w_index[i*2+k] = i_index[i];
        end
    end
end

endmodule