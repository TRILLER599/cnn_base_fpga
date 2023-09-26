`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_dz_busmaker_buf_L2_W14C2I12 (
    input  bit clk,
    input  bit i_rst,
    input  bit i_ena,
    input  bit [13:0] i_dia[1:0],
    input  bit i_enb,
    output bit [13:0] od_dob[1:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] addra;
bit [3:0] addrb;
bit enb_reg;

common_distrib_reg_array_O4W14A2 u_shift
(
    .clk                 (clk),
    .is0_ena             (i_ena),
    .is0_addra           (addra),
    .is0_data            (i_dia),
    .is1_enb             (enb_reg),
    .is1_addrb           (addrb),
    .od_data             (od_dob)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    addra <= 0;
end
else begin
    if (i_ena) begin
        addra <= (addra==(12-1))?0:addra+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_reg <= 0;
end
else begin
    enb_reg <= i_enb;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb <= 0;
end
else begin
    if (enb_reg) begin
        addrb <= (addrb==(12-1))?0:addrb+1;
    end
end
end

endmodule