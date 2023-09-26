`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_busmaker_w64_bram_W14C5O5 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_data_vld,
    input  bit i_str_end,
    input  bit i_img_end,
    output bit [13:0] od_data[4:0],
    output bit od_data_vld,
    output bit od_str_end,
    output bit od_img_end
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] data[3:0];
bit [2:0] data_vld;
bit [3:0] str_end;
bit [3:0] img_end;
bit [2:0] valid_count;
bit ena_shbuf;
bit [4:0] addra_shbuf;
bit [4:0] addrb_shbuf;
bit [13:0] dia_shbuf[3:0];
bit [13:0] data_out[3:0];
bit data_out_vld;
bit [13:0] pd_shbuf_dob[3:0];
bit enb_shbuf;
bit enb_reg_shbuf;
bit w_valid_count_limit;

genvar i;
generate
for (i=0;i<4;i++) begin : gen__common_bram_reg_O5W14
    common_bram_reg_O5W14 u_shift_buf
    (
        .clk                 (clk),
        .is0_ena             (ena_shbuf),
        .is0_addra           (addra_shbuf),
        .is0_data            (dia_shbuf[i]),
        .is1_enb             (enb_shbuf),
        .is1_addrb           (addrb_shbuf),
        .i_enb_reg           (enb_reg_shbuf),
        .od_ram              (pd_shbuf_dob[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    data[0] <= i_data;
    for (int i=1; i<4; i++) begin
        data[i] <= data[i-1];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_vld <= 0;
end
else begin
    data_vld <= {data_vld[1:0],i_data_vld};
end
end
always_ff @(posedge clk)
begin
    str_end <= {str_end[2:0],i_str_end};
end
always_ff @(posedge clk)
begin
    img_end <= {img_end[2:0],i_img_end};
end
assign enb_shbuf = data_vld[0];
assign enb_reg_shbuf = data_vld[1];
always_ff @(posedge clk)
begin
if (i_rst) begin
    ena_shbuf <= 0;
end
else begin
    ena_shbuf <= data_vld[2];
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra_shbuf <= 0;
end
else begin
    if (ena_shbuf) begin
        addra_shbuf <= (str_end[3])?0:addra_shbuf+1;
    end
end
end
always_ff @(posedge clk)
begin
    if (data_vld[2]) begin
        dia_shbuf[0] <= data[2];
    end
    for (int i=1; i<4; i++) begin
        if (data_vld[2]) begin
            dia_shbuf[i] <= pd_shbuf_dob[i-1];
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb_shbuf <= 0;
end
else begin
    if (enb_shbuf) begin
        addrb_shbuf <= (str_end[0])?0:addrb_shbuf+1;
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        data_out[i] <= pd_shbuf_dob[i];
    end
end
assign w_valid_count_limit = (valid_count==5-1);
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid_count <= 0;
end
else begin
    if (data_vld[2]) begin
        if (img_end[2]) begin
            valid_count <= 0;
        end
        else if (str_end[2]&~w_valid_count_limit) begin
            valid_count <= valid_count+1;
        end
        else begin
            valid_count <= valid_count;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_out_vld <= 0;
end
else begin
    data_out_vld <= data_vld[2]&w_valid_count_limit;
end
end
always_comb
begin
    od_data[0] = data[3];
    for (int i=1; i<5; i++) begin
        od_data[i] = data_out[i-1];
    end
end
assign od_data_vld = data_out_vld;
assign od_str_end = str_end[3];
assign od_img_end = img_end[3];

endmodule