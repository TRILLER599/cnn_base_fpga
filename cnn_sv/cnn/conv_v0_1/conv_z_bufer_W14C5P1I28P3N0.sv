`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_conv_z_bufer_W14C5P1I28P3N0 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_valid[0:0],
    input  bit i_read[0:0],
    output bit [13:0] od_data[4:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [9:0] addra[4:0];
bit [9:0] addrb[4:0];
bit [4:0] linea_a;
bit [4:0] count_b_linea;
bit [4:0] count_b_img;
bit [4:0] ena_muxstd;
bit [4:0] enb_muxstd;
bit [4:0] errore_lungo;
bit errore;
bit linea_a_end;
bit end_b_linea;
bit end_b_img;
bit rst__pip;
bit rst__l;

genvar i;
generate
for (i=0;i<1;i++) begin : gen__conv_v0_1_conv_z_bufer_uno_W14C5I28O10
    conv_v0_1_conv_z_bufer_uno_W14C5I28O10 u_bufer_separato
    (
        .clk                 (clk),
        .i_rst               (rst__l),
        .i_data              (i_data[i]),
        .i_valid             (i_valid[i]),
        .i_read              (i_read[i]),
        .od_data             (od_data[i*5+4:i*5])
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

assign linea_a_end = (linea_a==(28-1));
always_ff @(posedge clk)
begin
if (rst__l) begin
    linea_a <= 0;
end
else begin
    if (i_valid[0]) begin
        linea_a <= (linea_a_end)?0:linea_a+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ena_muxstd <= 1;
end
else begin
    if (i_valid[0]&linea_a_end) begin
        ena_muxstd <= {ena_muxstd[3:0],ena_muxstd[4]};
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addra[0] <= 1;
    addra[1] <= 1;
    addra[2] <= 1;
    addra[3] <= 1;
    addra[4] <= 1;
end
else begin
    for (int i=0; i<5; i++) begin
        addra[i] <= addra[i]+(i_valid[0]&ena_muxstd[i]);
    end
end
end
assign end_b_linea = (count_b_linea==(28-1));
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_b_linea <= 0;
end
else begin
    if (i_read[0]) begin
        count_b_linea <= (end_b_linea)?0:count_b_linea+1;
    end
end
end
assign end_b_img = (count_b_img==(28-5+1-1));
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_b_img <= 0;
end
else begin
    if (i_read[0]&end_b_linea) begin
        count_b_img <= (end_b_img)?0:count_b_img+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    enb_muxstd <= 1;
end
else begin
    if (i_read[0]&end_b_linea&~end_b_img) begin
        enb_muxstd <= {enb_muxstd[3:0],enb_muxstd[4]};
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    addrb[0] <= 0;
    addrb[1] <= 0;
    addrb[2] <= 0;
    addrb[3] <= 0;
    addrb[4] <= 0;
end
else begin
    for (int i=0; i<5; i++) begin
        if (i_read[0]) begin
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
if (rst__l) begin
    errore_lungo <= 0;
end
else begin
    for (int i=0; i<5; i++) begin
        if (i_valid[0]&ena_muxstd[i]) begin
            errore_lungo[i] <= (addra[i]==addrb[i]);
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore <= 0;
end
else begin
    errore <= (|errore_lungo);
end
end
assign od_errore = errore;

endmodule