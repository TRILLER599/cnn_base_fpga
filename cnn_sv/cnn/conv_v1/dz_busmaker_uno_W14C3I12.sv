`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_dz_busmaker_uno_W14C3I12 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit i_gradient_enb_l1,
    input  bit [13:0] i_gradient_l4,
    output bit [13:0] od_gradient_l5[8:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] gradient_enb;
bit [13:0] gradient_l5[8:0];
bit [3:0] larg;
bit [3:0] lung;
bit w_ena2buf;
bit w_enb2buf;
bit [13:0] w_data2buf[1:0];
bit [13:0] pd_buf_data[1:0];
bit w_valid_l4;
bit rst__pip;
bit rst__l;

conv_v1_dz_busmaker_buf_L2_W14C2I12 u_shift_buf
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_ena               (w_ena2buf),
    .i_dia               (w_data2buf),
    .i_enb               (w_enb2buf),
    .od_dob              (pd_buf_data)
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
if (rst__l) begin
    gradient_enb <= 0;
end
else begin
    gradient_enb <= {gradient_enb[2:0],i_gradient_enb_l1};
end
end
assign w_ena2buf = gradient_enb[3];
assign w_enb2buf = gradient_enb[0];
always_comb
begin
    for (int i=0; i<2; i++) begin
        w_data2buf[i] = gradient_l5[i*3];
    end
end
assign w_valid_l4 = gradient_enb[2];
always_ff @(posedge clk)
begin
if (rst__l) begin
    larg <= 0;
end
else begin
    if (w_valid_l4) begin
        larg <= (larg==(12-1))?0:larg+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    lung <= 0;
end
else begin
    if (w_valid_l4) begin
        if (larg==(12-1)) begin
            lung <= (lung==(12-1))?0:lung+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_l5[0] <= 0;
    gradient_l5[1] <= 0;
    gradient_l5[2] <= 0;
    gradient_l5[3] <= 0;
    gradient_l5[4] <= 0;
    gradient_l5[5] <= 0;
    gradient_l5[6] <= 0;
    gradient_l5[7] <= 0;
    gradient_l5[8] <= 0;
end
else begin
    if (w_valid_l4) begin
        gradient_l5[0] <= ((larg>=10)|(lung>=10))?0:i_gradient_l4;
        gradient_l5[3] <= (lung<1)?0:pd_buf_data[0];
        gradient_l5[6] <= (lung<2)?0:pd_buf_data[1];
        for (int i=0; i<3; i++) begin
            for (int k=1; k<3; k++) begin
                gradient_l5[i*3+k] <= gradient_l5[i*3+k-1];
            end
        end
    end
end
end
always_comb
begin
    for (int i=0; i<9; i++) begin
        od_gradient_l5[i] = gradient_l5[9-i-1];
    end
end

endmodule