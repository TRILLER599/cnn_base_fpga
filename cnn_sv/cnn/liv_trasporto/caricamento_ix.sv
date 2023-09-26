`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_caricamento_ix (
    input  bit clk,
    input  bit i_rst,
    input  bit [31:0] i_data,
    input  bit i_start,
    input  bit [15:0] i_quantita_meno1,
    output bit [15:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit write_en;
bit [8:0] count_wr;
bit start_rd;
bit read_en;
bit enb;
bit mux_data;
bit [9:0] count_rd;
bit [2:0] valid;
bit [15:0] data;
bit w_enb;
bit [8:0] w_addrb;
bit [31:0] pd_dob;

common_bram_reg_O9W32 u_bufer
(
    .clk                 (clk),
    .is0_ena             (write_en),
    .is0_addra           (count_wr),
    .is0_data            (i_data),
    .is1_enb             (w_enb),
    .is1_addrb           (w_addrb),
    .i_enb_reg           (enb),
    .od_ram              (pd_dob)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    write_en <= 0;
end
else begin
    if (write_en) begin
        write_en <= ~(count_wr==i_quantita_meno1[9:1]);
    end
    else begin
        write_en <= i_start;
    end
end
end
always_ff @(posedge clk)
begin
    if (write_en) begin
        count_wr <= count_wr+1;
    end
    else begin
        count_wr <= 0;
    end
end
always_ff @(posedge clk)
begin
    start_rd <= i_start;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    read_en <= 0;
end
else begin
    if (read_en) begin
        read_en <= ~(count_rd==i_quantita_meno1);
    end
    else begin
        read_en <= start_rd;
    end
end
end
always_ff @(posedge clk)
begin
    if (read_en) begin
        count_rd <= count_rd+1;
    end
    else begin
        count_rd <= 0;
    end
end
assign w_enb = read_en&(~count_rd[0]);
assign w_addrb = count_rd[9:1];
always_ff @(posedge clk)
begin
    enb <= w_enb;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= {valid[1:0],read_en};
end
end
always_ff @(posedge clk)
begin
    mux_data <= (valid[1])?~mux_data:0;
end
always_ff @(posedge clk)
begin
    if (valid[1]) begin
        data <= (mux_data)?pd_dob[31:16]:pd_dob[15:0];
    end
end
assign od_data = data;
assign od_valid = valid[2];

endmodule