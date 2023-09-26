`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v1_dz_busmaker_W14C3C16I12 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit i_gradient_enb_l0,
    output bit od_gradient_enb_l1,
    input  bit [13:0] i_gradient_l3[15:0],
    output bit [13:0] od_gradient_l4[143:0],
    output bit [13:0] od_gradient_l5[143:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [3:0] larg;
bit [3:0] lung;
bit gradient_enb_l1;
bit [13:0] gradient_l5[143:0];
bit [13:0] pd_gradient_l4[143:0];

genvar i;
generate
for (i=0; i<16; i++) begin : gen__conv_v1_dz_busmaker_uno_W14C3I12
    conv_v1_dz_busmaker_uno_W14C3I12 u_busmaker_uno
    (
        .clk                 (clk),
        .i_rst_g             (i_rst_g),
        .i_rst               (i_rst),
        .i_gradient_enb_l1   (i_gradient_enb_l0),
        .i_gradient_l4       (i_gradient_l3[i]),
        .od_gradient_l5      (pd_gradient_l4[i*9+8:i*9])
    );
end
endgenerate


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    larg <= 0;
end
else begin
    if (i_gradient_enb_l0) begin
        larg <= (larg==(12-1))?0:larg+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    lung <= 0;
end
else begin
    if (i_gradient_enb_l0) begin
        if (larg==(12-1)) begin
            lung <= (lung==(12-1))?0:lung+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    gradient_enb_l1 <= 0;
end
else begin
    gradient_enb_l1 <= i_gradient_enb_l0&(larg<10)&(lung<10);
end
end
assign od_gradient_enb_l1 = gradient_enb_l1;
always_ff @(posedge clk)
begin
    for (int i=0; i<144; i++) begin
        gradient_l5[i] <= pd_gradient_l4[i];
    end
end
always_comb
begin
    for (int i=0; i<144; i++) begin
        od_gradient_l4[i] = pd_gradient_l4[i];
    end
end
always_comb
begin
    for (int i=0; i<144; i++) begin
        od_gradient_l5[i] = gradient_l5[i];
    end
end

endmodule