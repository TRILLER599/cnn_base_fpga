`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_peso_corsia_parte (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_caricamento,
    output bit [8:0] od_caricamento_l1[0:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] count_size2_wr;
bit end_size2_wr;
bit [8:0] size2_wr_std;
bit [1:0] count_compress_wr;
bit [8:0] ena[0:0];
bit rst__pip;
bit rst__l;


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
    count_size2_wr <= 0;
end
else begin
    if (i_caricamento) begin
        count_size2_wr <= (end_size2_wr)?0:count_size2_wr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    end_size2_wr <= 0;
end
else begin
    if (i_caricamento) begin
        end_size2_wr <= (count_size2_wr==9-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    size2_wr_std <= 1;
end
else begin
    if (i_caricamento) begin
        size2_wr_std <= {size2_wr_std[7:0],size2_wr_std[8]};
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_compress_wr <= 0;
end
else begin
    if (i_caricamento&end_size2_wr) begin
        count_compress_wr <= (count_compress_wr==(4-1))?0:count_compress_wr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena[0] <= 0;
end
else begin
    ena[0] <= (i_caricamento)?size2_wr_std:0;
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_caricamento_l1[i] = ena[i];
    end
end

endmodule