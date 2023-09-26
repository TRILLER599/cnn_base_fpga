`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module conv_v2_controllo_generale_C3C16S1C4I12S16O9M10 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_valid,
    input  bit i_gradient_vld,
    input  bit [9:0] i_minibatch_min1,
    input  bit i_modalita,
    output bit od_weight_enb_l2[15:0],
    output bit od_valid_diretto_l5[15:0],
    output bit o_gradient_enb_l0,
    output bit od_gradient_vld_l5[15:0],
    output bit od_imgdir_enb_l2,
    output bit od_imgdir_vld_l4[15:0],
    output bit od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
enum bit[1:0] {LAVORO = 2'd0, ATTESA_GRADIENT = 2'd1, LETTURA = 2'd2} fsm;
bit [5:0] larg_count;
bit [3:0] lung_count;
bit larg_end;
bit lung_end;
bit lung_start;
bit [9:0] count_minibatch;
bit [9:0] ritorno_count;
bit minibatch_end;
bit ritorno_end;
bit [8:0] gradient_buf;
bit gradient_disponibile;
bit gradient_congelato;
bit weight_enb_l1;
bit weight_enb_l2[15:0];
bit valid_diretto_l1;
bit valid_diretto_l2;
bit valid_diretto_l3;
bit valid_diretto_l4;
bit valid_diretto_l5[15:0];
bit [1:0] compres_count;
bit [3:0] gradient_vld_l1_4;
bit gradient_vld_l5[15:0];
bit imgdir_vld_l4[15:0];
bit errore;
bit [8:0] w_gradient_buf;
bit w_gradient_enb_l0;
bit rst__pip;
bit rst__l;


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
    fsm <= LAVORO;
end
else begin
    case (fsm)
        LAVORO : begin
            if (i_valid&larg_end&lung_end&minibatch_end) begin
                fsm <= (gradient_disponibile)?LETTURA:ATTESA_GRADIENT;
            end
        end
        ATTESA_GRADIENT : begin
            if (gradient_disponibile) begin
                fsm <= LETTURA;
            end
        end
        LETTURA : begin
            if (larg_end&lung_end) begin
                if (ritorno_end) begin
                    fsm <= LAVORO;
                end
                else if (~gradient_disponibile) begin
                    fsm <= ATTESA_GRADIENT;
                end
            end
        end
    endcase
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    larg_end <= 0;
end
else begin
    if (i_valid|(fsm==LETTURA)) begin
        larg_end <= (larg_count==(48-2));
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    larg_count <= 0;
end
else begin
    if (i_valid|(fsm==LETTURA)) begin
        larg_count <= (larg_end)?0:larg_count+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    lung_end <= 0;
end
else begin
    if (i_valid|(fsm==LETTURA)) begin
        if (larg_end) begin
            lung_end <= (lung_count==(12-2));
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    lung_count <= 0;
end
else begin
    if (i_valid|(fsm==LETTURA)) begin
        if (larg_end) begin
            lung_count <= (lung_end)?0:lung_count+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    lung_start <= 1;
end
else begin
    if (i_valid|(fsm==LETTURA)) begin
        lung_start <= larg_end&lung_end;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    count_minibatch <= 0;
end
else begin
    if (i_valid&larg_end&lung_end) begin
        count_minibatch <= (minibatch_end)?0:count_minibatch+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    minibatch_end <= 0;
end
else begin
    minibatch_end <= (count_minibatch==i_minibatch_min1);
end
end
always_comb
begin
    if (gradient_disponibile&(i_valid|(fsm==LETTURA))&lung_start) begin
        w_gradient_buf = (i_gradient_vld)?gradient_buf+1-100:gradient_buf-100;
    end
    else begin
        w_gradient_buf = (i_gradient_vld)?gradient_buf+1:gradient_buf;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_buf <= 0;
end
else begin
    gradient_buf <= w_gradient_buf;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_disponibile <= 0;
end
else begin
    gradient_disponibile <= (w_gradient_buf>=100);
end
end
always_ff @(posedge clk)
begin
    if (i_valid&lung_start) begin
        gradient_congelato <= gradient_disponibile;
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ritorno_count <= 0;
end
else begin
    if (larg_end&lung_end&((i_valid&gradient_congelato)|(fsm==LETTURA))) begin
        ritorno_count <= (ritorno_end)?0:ritorno_count+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    ritorno_end <= 0;
end
else begin
    ritorno_end <= (ritorno_count==i_minibatch_min1);
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_enb_l1 <= 0;
end
else begin
    weight_enb_l1 <= (i_valid|(fsm==LETTURA));
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_enb_l2[0] <= 0;
    weight_enb_l2[1] <= 0;
    weight_enb_l2[2] <= 0;
    weight_enb_l2[3] <= 0;
    weight_enb_l2[4] <= 0;
    weight_enb_l2[5] <= 0;
    weight_enb_l2[6] <= 0;
    weight_enb_l2[7] <= 0;
    weight_enb_l2[8] <= 0;
    weight_enb_l2[9] <= 0;
    weight_enb_l2[10] <= 0;
    weight_enb_l2[11] <= 0;
    weight_enb_l2[12] <= 0;
    weight_enb_l2[13] <= 0;
    weight_enb_l2[14] <= 0;
    weight_enb_l2[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        weight_enb_l2[i] <= weight_enb_l1;
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_weight_enb_l2[i] = weight_enb_l2[i];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_diretto_l1 <= 0;
end
else begin
    valid_diretto_l1 <= i_valid&(larg_count>((3-1)*4-1))&(lung_count>(3-2));
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_diretto_l2 <= 0;
end
else begin
    valid_diretto_l2 <= valid_diretto_l1;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_diretto_l3 <= 0;
end
else begin
    valid_diretto_l3 <= valid_diretto_l2;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_diretto_l4 <= 0;
end
else begin
    valid_diretto_l4 <= valid_diretto_l3;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid_diretto_l5[0] <= 0;
    valid_diretto_l5[1] <= 0;
    valid_diretto_l5[2] <= 0;
    valid_diretto_l5[3] <= 0;
    valid_diretto_l5[4] <= 0;
    valid_diretto_l5[5] <= 0;
    valid_diretto_l5[6] <= 0;
    valid_diretto_l5[7] <= 0;
    valid_diretto_l5[8] <= 0;
    valid_diretto_l5[9] <= 0;
    valid_diretto_l5[10] <= 0;
    valid_diretto_l5[11] <= 0;
    valid_diretto_l5[12] <= 0;
    valid_diretto_l5[13] <= 0;
    valid_diretto_l5[14] <= 0;
    valid_diretto_l5[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        valid_diretto_l5[i] <= valid_diretto_l4;
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_valid_diretto_l5[i] = valid_diretto_l5[i];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compres_count <= 0;
end
else begin
    if (fsm==LETTURA) begin
        compres_count <= (compres_count==(4-1))?0:compres_count+1;
    end
    else if (i_valid&((lung_start&gradient_disponibile)|(~lung_start&gradient_congelato))) begin
        compres_count <= (compres_count==(4-1))?0:compres_count+1;
    end
end
end
always_comb
begin
    if (fsm==LETTURA) begin
        w_gradient_enb_l0 = (compres_count==0);
    end
    else if (i_valid&((lung_start&gradient_disponibile)|(~lung_start&gradient_congelato))) begin
        w_gradient_enb_l0 = (compres_count==0);
    end
    else begin
        w_gradient_enb_l0 = 0;
    end
end
assign o_gradient_enb_l0 = w_gradient_enb_l0;
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_vld_l1_4 <= 0;
end
else begin
    gradient_vld_l1_4[0] <= (fsm==LETTURA)|(i_valid&((lung_start&gradient_disponibile)|(~lung_start&gradient_congelato)));
    gradient_vld_l1_4[3:1] <= gradient_vld_l1_4[2:0];
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    gradient_vld_l5[0] <= 0;
    gradient_vld_l5[1] <= 0;
    gradient_vld_l5[2] <= 0;
    gradient_vld_l5[3] <= 0;
    gradient_vld_l5[4] <= 0;
    gradient_vld_l5[5] <= 0;
    gradient_vld_l5[6] <= 0;
    gradient_vld_l5[7] <= 0;
    gradient_vld_l5[8] <= 0;
    gradient_vld_l5[9] <= 0;
    gradient_vld_l5[10] <= 0;
    gradient_vld_l5[11] <= 0;
    gradient_vld_l5[12] <= 0;
    gradient_vld_l5[13] <= 0;
    gradient_vld_l5[14] <= 0;
    gradient_vld_l5[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        gradient_vld_l5[i] <= gradient_vld_l1_4[3];
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_gradient_vld_l5[i] = gradient_vld_l5[i];
    end
end
assign od_imgdir_enb_l2 = gradient_vld_l1_4[1];
always_ff @(posedge clk)
begin
if (rst__l) begin
    imgdir_vld_l4[0] <= 0;
    imgdir_vld_l4[1] <= 0;
    imgdir_vld_l4[2] <= 0;
    imgdir_vld_l4[3] <= 0;
    imgdir_vld_l4[4] <= 0;
    imgdir_vld_l4[5] <= 0;
    imgdir_vld_l4[6] <= 0;
    imgdir_vld_l4[7] <= 0;
    imgdir_vld_l4[8] <= 0;
    imgdir_vld_l4[9] <= 0;
    imgdir_vld_l4[10] <= 0;
    imgdir_vld_l4[11] <= 0;
    imgdir_vld_l4[12] <= 0;
    imgdir_vld_l4[13] <= 0;
    imgdir_vld_l4[14] <= 0;
    imgdir_vld_l4[15] <= 0;
end
else begin
    for (int i=0; i<16; i++) begin
        imgdir_vld_l4[i] <= gradient_vld_l1_4[2]&(!i_modalita);
    end
end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_imgdir_vld_l4[i] = imgdir_vld_l4[i];
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore <= 0;
end
else begin
    errore <= i_valid&(fsm!=LAVORO);
end
end
assign od_errore = errore;

endmodule