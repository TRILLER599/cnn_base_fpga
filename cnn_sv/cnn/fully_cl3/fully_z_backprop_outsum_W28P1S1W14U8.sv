`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_fully_z_backprop_outsum_W28P1S1W14U8 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [27:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    input  bit i_img_end,
    output bit [13:0] od_data[0:0],
    output bit od_valid[0:0],
    output bit od_img_end,
    output bit od_traboc
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [13:0] z_backprop[0:0];
bit z_backprop_vld[0:0];
bit z_backprop_img_end;
bit [6:0] z_eccesso[0:0];
bit signed [21:0] z_arrot[0:0];

manipolazione_traboccare_1vld_N1W7 u_traboccare
(
    .clk                 (clk),
    .i_rst               (i_rst),
    .i_data              (z_eccesso),
    .i_valid             (z_backprop_vld[0]),
    .od_data             (od_traboc)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_comb
begin
    for (int i=0; i<1; i++) begin
        if (i_data[i][27]) begin
            z_arrot[i] = i_data[i][21:0]+127;
        end
        else begin
            z_arrot[i] = i_data[i][21:0]+127+1;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        z_backprop[i] <= z_arrot[i][21:8];
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    z_backprop_vld[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        z_backprop_vld[i] <= i_data_vld[0];
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        z_eccesso[i] <= i_data[i][27:21];
    end
end
always_ff @(posedge clk)
begin
    z_backprop_img_end <= i_img_end;
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data[i] = z_backprop[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_valid[i] = z_backprop_vld[i];
    end
end
assign od_img_end = z_backprop_img_end;

endmodule