`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_busmaker_uno_semplice_L5_W14C3C4C4I12 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_valid,
    output bit [13:0] od_data_l5[8:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[3:0];
bit [4:0] valid;
bit [13:0] dati_a_compress[2:0];
bit [3:0] valid_buf;
bit [13:0] dati_a_princip[1:0];
bit [13:0] pd_princip_data[1:0];
bit [13:0] pd_compress_data[5:0];
bit rst__pip;
bit rst__l;

conv_v1_busmaker_buf_principale_L3_W14C4I12A2 u_principale
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (dati_a_princip),
    .i_valid             (valid_buf),
    .od_data             (pd_princip_data)
);
conv_v1_busmaker_compressione_L3_W14C3C4 u_compressione
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_data              (dati_a_compress),
    .i_valid             (valid_buf),
    .od_data             (pd_compress_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

always_ff @(posedge clk)
begin
    data[0] <= i_data;
    data[1] <= data[0];
    data[2] <= data[1];
    data[3] <= data[2];
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid <= 0;
end
else begin
    valid <= {valid[3:0],i_valid};
end
end
assign valid_buf = valid[4:1];
always_comb
begin
    for (int i=0; i<2; i++) begin
        dati_a_princip[i] = dati_a_compress[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=1; i<3; i++) begin
        dati_a_compress[i] <= pd_princip_data[i-1];
    end
    dati_a_compress[0] <= data[3];
end
always_comb
begin
    for (int i=1; i<=3; i++) begin
        od_data_l5[3*i-1] = dati_a_compress[3-i];
    end
    for (int i=0; i<3; i++) begin
        for (int k=0; k<2; k++) begin
            od_data_l5[3*i+k] = pd_compress_data[2*3-k*3-i-1];
        end
    end
end

endmodule