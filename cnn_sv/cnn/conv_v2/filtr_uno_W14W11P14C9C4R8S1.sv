`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_filtr_uno_W14W11P14C9C4R8S1 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[8:0],
    input  bit [10:0] i_weight[8:0],
    input  bit i_valid[0:0],
    output bit [13:0] od_data,
    output bit od_valid,
    output bit od_errore_traboccare
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [29:0] compressione_data;
bit [1:0] compressione_count;
bit compressione_valid;
bit [13:0] data;
bit valid;
bit errore;
bit signed [27:0] pd_fm_data[0:0];
bit pd_fm_valid[0:0];
bit signed [27:0] pd_ssum_data;
bit pd_ssum_valid;
bit [14:0] w_data_arrot;
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0; i<1; i++) begin : gen__conv_v2_filtr_math_W14W14W11C9
    conv_v2_filtr_math_W14W14W11C9 u_filtr_math
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (i_data[i*9+8:i*9]),
        .i_weight            (i_weight[i*9+8:i*9]),
        .i_valid             (i_valid[i]),
        .od_data             (pd_fm_data[i]),
        .od_valid            (pd_fm_valid[i])
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

assign pd_ssum_data = pd_fm_data[0];
assign pd_ssum_valid = pd_fm_valid[0];
always_ff @(posedge clk)
begin
    if (pd_ssum_valid) begin
        compressione_data <= (compressione_count==0)?pd_ssum_data:compressione_data+pd_ssum_data;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compressione_count <= 0;
end
else begin
    if (pd_ssum_valid) begin
        compressione_count <= (compressione_count==4-1)?0:compressione_count+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compressione_valid <= 0;
end
else begin
    compressione_valid <= (compressione_count==4-1)&pd_ssum_valid;
end
end
assign w_data_arrot = $signed(compressione_data[29:7])+1;
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore <= 0;
end
else begin
    if (compressione_valid) begin
        if (~(!compressione_data[29:21]|&compressione_data[29:21])) begin
            errore <= 1;
        end
    end
end
end
always_ff @(posedge clk)
begin
    if (compressione_valid) begin
        data <= w_data_arrot[14:1];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid <= 0;
end
else begin
    valid <= compressione_valid;
end
end
assign od_data = data;
assign od_valid = valid;
assign od_errore_traboccare = errore;

endmodule