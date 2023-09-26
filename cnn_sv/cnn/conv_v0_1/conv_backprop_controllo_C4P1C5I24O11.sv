`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v0_1_conv_backprop_controllo_C4P1C5I24O11 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_gradient_wr,
    output bit od_z_read[0:0],
    output bit od_z_vld,
    output bit od_grad_read[3:0],
    output bit od_calc_prec[3:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
enum bit[6:0] {ASPETTATIVA = 7'd1, PRE_LEGGERE = 7'd2, LAVORO = 7'd4, FIN_LINEA = 7'd8, FIN_LINEA_LAST = 7'd16, FIN_IMG = 7'd32, FIN_IMG_PRERD = 7'd64} fsm;
bit [11:0] counter_gradient_buf;
bit img_accessibile;
bit [1:0] counter_pre_leg;
bit [4:0] counter_larg;
bit [4:0] counter_lung;
bit z_read[0:0];
bit grad_read[3:0];
bit calcolo_prec[3:0];
bit z_vld;
bit linea_g_end;
bit linea_end;
bit img_end;
bit w_grad_rd;
bit z_read_wire;
bit grad_read_wire;
bit w_calcolo_prec;
bit rst__pip;
bit rst__l;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    rst__pip <= i_rst_g;
    rst__l   <= rst__pip;
end

assign linea_g_end = (counter_larg==(24-1));
assign linea_end = (counter_larg==(24+5-2));
assign img_end = (counter_lung==(24+5-2));
assign w_grad_rd = img_accessibile&((fsm==ASPETTATIVA)|((fsm==FIN_IMG)&(img_end&(linea_end|linea_g_end))));
always_ff @(posedge clk)
begin
if (rst__l) begin
    counter_gradient_buf <= 0;
end
else begin
    if (w_grad_rd) begin
        counter_gradient_buf <= counter_gradient_buf+i_gradient_wr-576;
    end
    else begin
        counter_gradient_buf <= counter_gradient_buf+i_gradient_wr;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    img_accessibile <= 0;
end
else begin
    img_accessibile <= (counter_gradient_buf>=576);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    fsm <= ASPETTATIVA;
end
else begin
    case (fsm)
        ASPETTATIVA : begin
            if (img_accessibile) begin
                fsm <= PRE_LEGGERE;
            end
        end
        PRE_LEGGERE : begin
            if (counter_pre_leg==(5-2)) begin
                fsm <= LAVORO;
            end
        end
        LAVORO : begin
            if (linea_g_end) begin
                fsm <= (counter_lung==(24-1))?FIN_LINEA_LAST:FIN_LINEA;
            end
        end
        FIN_LINEA : begin
            if (linea_end) begin
                fsm <= LAVORO;
            end
        end
        FIN_LINEA_LAST : begin
            if (linea_end) begin
                fsm <= FIN_IMG;
            end
        end
        FIN_IMG : begin
            if (img_end) begin
                if (linea_end) begin
                    if (img_accessibile) begin
                        fsm <= PRE_LEGGERE;
                    end
                    else begin
                        fsm <= ASPETTATIVA;
                    end
                end
                else if (linea_g_end&img_accessibile) begin
                    fsm <= FIN_IMG_PRERD;
                end
            end
        end
        FIN_IMG_PRERD : begin
            if (linea_end) begin
                fsm <= LAVORO;
            end
        end
    endcase
end
end
always_ff @(posedge clk)
begin
    counter_pre_leg <= (fsm==PRE_LEGGERE)?counter_pre_leg+1:0;
end
always_ff @(posedge clk)
begin
    if ((fsm==LAVORO)||(fsm==FIN_LINEA)||(fsm==FIN_LINEA_LAST)||(fsm==FIN_IMG)||(fsm==FIN_IMG_PRERD)) begin
        counter_larg <= (linea_end)?0:counter_larg+1;
    end
    else begin
        counter_larg <= 0;
    end
end
always_ff @(posedge clk)
begin
    if ((fsm==LAVORO)||(fsm==FIN_LINEA)||(fsm==FIN_LINEA_LAST)||(fsm==FIN_IMG)||(fsm==FIN_IMG_PRERD)) begin
        if (linea_end) begin
            counter_lung <= (img_end)?0:counter_lung+1;
        end
    end
    else begin
        counter_lung <= 0;
    end
end
assign z_read_wire = (fsm==PRE_LEGGERE)||(fsm==LAVORO)||(fsm==FIN_LINEA)||(fsm==FIN_IMG_PRERD);
always_ff @(posedge clk)
begin
if (rst__l) begin
    z_read[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        z_read[i] <= z_read_wire;
    end
end
end
assign grad_read_wire = (fsm==LAVORO);
assign w_calcolo_prec = (fsm==LAVORO)||(fsm==FIN_LINEA)||(fsm==FIN_LINEA_LAST)||(fsm==FIN_IMG)||(fsm==FIN_IMG_PRERD);
always_ff @(posedge clk)
begin
if (rst__l) begin
    grad_read[0] <= 0;
    grad_read[1] <= 0;
    grad_read[2] <= 0;
    grad_read[3] <= 0;
end
else begin
    for (int i=0; i<4; i++) begin
        grad_read[i] <= grad_read_wire;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    calcolo_prec[0] <= 0;
    calcolo_prec[1] <= 0;
    calcolo_prec[2] <= 0;
    calcolo_prec[3] <= 0;
end
else begin
    for (int i=0; i<4; i++) begin
        calcolo_prec[i] <= w_calcolo_prec;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    z_vld <= 0;
end
else begin
    z_vld <= z_read[0];
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_z_read[i] = z_read[i];
    end
end
assign od_z_vld = z_vld;
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_grad_read[i] = grad_read[i];
    end
end
always_comb
begin
    for (int i=0; i<4; i++) begin
        od_calc_prec[i] = calcolo_prec[i];
    end
end

endmodule