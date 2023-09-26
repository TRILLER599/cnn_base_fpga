`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl2_permutazione_diretto_W14P400C16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data,
    input  bit i_valid,
    output bit [13:0] od_data,
    output bit od_valid,
    output bit od_img_end
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [8:0] counter_wr;
bit [8:0] counter_len;
bit stbit_wr;
bit [3:0] counter_compr;
bit ultimo_len;
bit ultimo_compr;
bit enb_reg;
bit ultimo_rd_1;
bit [8:0] counter_rd;
bit reading_lungo;
bit ultimo_rd;
bit stbit_rd;
bit valid;
bit img_end;
bit v_start_rd;
bit enb;
bit [9:0] addra;
bit [9:0] addrb;

common_bram_reg_O10W14 u_ram
(
    .clk                 (clk),
    .is0_ena             (i_valid),
    .is0_addra           (addra),
    .is0_data            (i_data),
    .is1_enb             (enb),
    .is1_addrb           (addrb),
    .i_enb_reg           (enb_reg),
    .od_ram              (od_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    ultimo_compr <= 0;
end
else begin
    if (i_valid) begin
        ultimo_compr <= (counter_compr==(16-2));
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_compr <= 0;
end
else begin
    if (i_valid) begin
        counter_compr <= (ultimo_compr)?0:counter_compr+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ultimo_len <= 0;
end
else begin
    if (i_valid) begin
        ultimo_len <= (counter_len==(400-2));
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_len <= 0;
end
else begin
    if (i_valid) begin
        counter_len <= (ultimo_len)?0:counter_len+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_wr <= 0;
end
else begin
    if (i_valid) begin
        if (ultimo_len) begin
            counter_wr <= 0;
        end
        else begin
            counter_wr <= (ultimo_compr)?counter_wr-25*(16-1)+1:counter_wr+25;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    stbit_wr <= 0;
end
else begin
    if (i_valid) begin
        stbit_wr <= (ultimo_len)?~stbit_wr:stbit_wr;
    end
end
end
assign v_start_rd = i_valid&ultimo_len;
assign enb = v_start_rd|reading_lungo;
assign addra = {stbit_wr,counter_wr};
assign addrb = {stbit_rd,counter_rd};
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_reg <= 0;
end
else begin
    enb_reg <= enb;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    reading_lungo <= 0;
end
else begin
    if (v_start_rd) begin
        reading_lungo <= 1;
    end
    else begin
        reading_lungo <= (ultimo_rd)?0:reading_lungo;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ultimo_rd <= 0;
end
else begin
    if (v_start_rd|reading_lungo) begin
        ultimo_rd <= (counter_rd==(400-2));
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_rd <= 0;
end
else begin
    if (v_start_rd|reading_lungo) begin
        counter_rd <= (ultimo_rd)?0:counter_rd+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    stbit_rd <= 0;
end
else begin
    if (v_start_rd|reading_lungo) begin
        stbit_rd <= (ultimo_rd)?~stbit_rd:stbit_rd;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= enb_reg;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ultimo_rd_1 <= 0;
end
else begin
    ultimo_rd_1 <= ultimo_rd;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    img_end <= 0;
end
else begin
    img_end <= ultimo_rd_1;
end
end
assign od_valid = valid;
assign od_img_end = img_end;

endmodule