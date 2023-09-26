`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_busmaker_compressione_L3_W14C3C4 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[2:0],
    input  bit [3:0] i_valid,
    output bit [13:0] od_data[5:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [1:0] addra;
bit [1:0] addrb;
bit ena;
bit enb;
bit [13:0] pd_data[5:0];

common_distrib_reg_array_O2W14A3 u_shift__0
(
    .clk                 (clk),
    .is0_ena             (ena),
    .is0_addra           (addra),
    .is0_data            (i_data),
    .is1_enb             (enb),
    .is1_addrb           (addrb),
    .od_data             (pd_data[0+2:0])
);

genvar i;
generate
for (i=1; i<2; i++) begin : gen__common_distrib_reg_array_O2W14A3
    common_distrib_reg_array_O2W14A3 u_shift
    (
        .clk                 (clk),
        .is0_ena             (ena),
        .is0_addra           (addra),
        .is0_data            (pd_data[i*3-3+2:i*3-3]),
        .is1_enb             (enb),
        .is1_addrb           (addrb),
        .od_data             (pd_data[i*3+2:i*3])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign ena = i_valid[3];
assign enb = i_valid[2];
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra <= 0;
end
else begin
    addra <= (ena)?addra+1:addra;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb <= -4;
end
else begin
    addrb <= (enb)?addrb+1:addrb;
end
end
always_comb
begin
    for (int i=0; i<6; i++) begin
        od_data[i] = pd_data[i];
    end
end

endmodule