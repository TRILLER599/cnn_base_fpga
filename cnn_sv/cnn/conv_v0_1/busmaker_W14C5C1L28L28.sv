`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_busmaker_W14C5C1L28L28 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    output bit [13:0] od_data[4:0],
    output bit od_data_vld[0:0],
    output bit od_str_end[0:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [4:0] counnter_str;
bit [4:0] counnter_img;
bit counnter_str_end;
bit counnter_img_end;
bit w_str_end;
bit w_img_end;
bit pd_bsl_img_end[0:0];
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0; i<1; i++) begin : gen__conv_v0_1_busmaker_w64_bram_W14C5O5
    conv_v0_1_busmaker_w64_bram_W14C5O5 u_busmaker_lenght
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (i_data[i]),
        .i_data_vld          (i_data_vld[i]),
        .i_str_end           (w_str_end),
        .i_img_end           (w_img_end),
        .od_data             (od_data[i*5+4:i*5]),
        .od_data_vld         (od_data_vld[i]),
        .od_str_end          (od_str_end[i]),
        .od_img_end          (pd_bsl_img_end[i])
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
    counnter_str <= 0;
end
else begin
    if (i_data_vld[0]) begin
        counnter_str <= (counnter_str_end)?0:counnter_str+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    counnter_str_end <= 0;
end
else begin
    if (i_data_vld[0]) begin
        counnter_str_end <= (counnter_str==(28-2));
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    counnter_img <= 0;
end
else begin
    if (i_data_vld[0]) begin
        if (counnter_str_end) begin
            counnter_img <= (counnter_img_end)?0:counnter_img+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    counnter_img_end <= 0;
end
else begin
    if (i_data_vld[0]) begin
        if (counnter_str_end) begin
            counnter_img_end <= (counnter_img==(28-2));
        end
    end
end
end
assign w_str_end = i_data_vld[0]&counnter_str_end;
assign w_img_end = i_data_vld[0]&counnter_str_end&counnter_img_end;

endmodule