`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_conv_z_bufer_uno_W14C5I28O10 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_valid,
    input  bit i_read,
    output bit [13:0] od_data[4:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [9:0] addra[4:0];
bit [9:0] addrb[4:0];
bit [4:0] linea_a;
bit linea_a_end;
bit [4:0] ena_muxstd;
bit [4:0] count_b_linea;
bit end_b_linea;
bit [4:0] count_b_img;
bit [4:0] enb_muxstd;
bit [2:0] enb_muxint;
bit [2:0] muxint_pip;
bit [13:0] data[4:0];
bit [13:0] pd_buf_dob[4:0];
bit ena_buf[4:0];
bit end_b_img;

genvar i;
generate
for (i=0; i<5; i++) begin : gen__common_bram_O10W14
    common_bram_O10W14 u_buffer
    (
        .clk                 (clk),
        .i_ena               (ena_buf[i]),
        .i_addra             (addra[i]),
        .i_data              (i_data),
        .i_enb               (i_read),
        .i_addrb             (addrb[i]),
        .od_ram              (pd_buf_dob[i])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<5; i++) begin
        ena_buf[i] = i_valid&ena_muxstd[i];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra[0] <= 0;
    addra[1] <= 0;
    addra[2] <= 0;
    addra[3] <= 0;
    addra[4] <= 0;
end
else begin
    for (int i=0; i<5; i++) begin
        addra[i] <= addra[i]+ena_buf[i];
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    linea_a <= 0;
end
else begin
    if (i_valid) begin
        linea_a <= (linea_a_end)?0:linea_a+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    linea_a_end <= 0;
end
else begin
    if (i_valid) begin
        linea_a_end <= (linea_a==(28-2));
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ena_muxstd <= 1;
end
else begin
    if (i_valid&linea_a_end) begin
        ena_muxstd <= {ena_muxstd[3:0],ena_muxstd[4]};
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    count_b_linea <= 0;
end
else begin
    if (i_read) begin
        count_b_linea <= (end_b_linea)?0:count_b_linea+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    end_b_linea <= 0;
end
else begin
    if (i_read) begin
        end_b_linea <= (count_b_linea==(28-2));
    end
end
end
assign end_b_img = (count_b_img==(28-5+1-1));
always_ff @(posedge clk)
begin
if (i_rst) begin
    count_b_img <= 0;
end
else begin
    if (i_read&end_b_linea) begin
        count_b_img <= (end_b_img)?0:count_b_img+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_muxstd <= 1;
end
else begin
    if (i_read&end_b_linea&~end_b_img) begin
        enb_muxstd <= {enb_muxstd[3:0],enb_muxstd[4]};
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_muxint <= 0;
end
else begin
    if (i_read&end_b_linea&~end_b_img) begin
        enb_muxint <= (enb_muxint==(5-1))?0:enb_muxint+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb[0] <= 0;
    addrb[1] <= 0;
    addrb[2] <= 0;
    addrb[3] <= 0;
    addrb[4] <= 0;
end
else begin
    for (int i=0; i<5; i++) begin
        if (i_read) begin
            if (end_b_linea&~end_b_img) begin
                addrb[i] <= (enb_muxstd[i])?addrb[i]+1:addrb[i]+1-28;
            end
            else begin
                addrb[i] <= addrb[i]+1;
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
    muxint_pip <= enb_muxint;
end
always_ff @(posedge clk)
begin
    if (muxint_pip==0) begin
        data[0] <= pd_buf_dob[0];
        data[1] <= pd_buf_dob[1];
        data[2] <= pd_buf_dob[2];
        data[3] <= pd_buf_dob[3];
        data[4] <= pd_buf_dob[4];
    end
    else if (muxint_pip==1) begin
        data[0] <= pd_buf_dob[1];
        data[1] <= pd_buf_dob[2];
        data[2] <= pd_buf_dob[3];
        data[3] <= pd_buf_dob[4];
        data[4] <= pd_buf_dob[0];
    end
    else if (muxint_pip==2) begin
        data[0] <= pd_buf_dob[2];
        data[1] <= pd_buf_dob[3];
        data[2] <= pd_buf_dob[4];
        data[3] <= pd_buf_dob[0];
        data[4] <= pd_buf_dob[1];
    end
    else if (muxint_pip==3) begin
        data[0] <= pd_buf_dob[3];
        data[1] <= pd_buf_dob[4];
        data[2] <= pd_buf_dob[0];
        data[3] <= pd_buf_dob[1];
        data[4] <= pd_buf_dob[2];
    end
    else begin
        data[0] <= pd_buf_dob[4];
        data[1] <= pd_buf_dob[0];
        data[2] <= pd_buf_dob[1];
        data[3] <= pd_buf_dob[2];
        data[4] <= pd_buf_dob[3];
    end
end
always_comb
begin
    for (int i=0; i<5; i++) begin
        od_data[i] = data[i];
    end
end

endmodule