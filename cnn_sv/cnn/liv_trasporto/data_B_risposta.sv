`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_data_B_risposta (
    input  bit clk,
    input  bit i_rst,
    input  bit [31:0] i_data_rx,
    input  bit i_reading_rx,
    input  bit i_completamento,
    input  bit i_wd_flag,
    input  bit [2:0] i_counter,
    input  bit [2:0] i_cmd,
    input  bit i_errore_flg,
    input  bit [10:0] i_quantita_W_meno1,
    input  bit [15:0] i_rete_errore,
    input  bit i_rete_errore_vld,
    input  bit [31:0] i_true_false,
    input  bit i_tf_vld,
    input  bit [31:0] i_weight,
    input  bit i_weight_vld,
    output bit [7:0] od_errore_logica,
    output bit [1:0] od_lunghezza_risp,
    output bit [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit rete_errore_dev;
bit ena_wd_flag;
bit [2:0] addr_rete;
bit [15:0] rete_errore;
bit [6:0] addr_tf;
bit ena_mem;
bit enb_mem;
bit enb_reg_mem;
bit valid;
bit weight_vld_1d;
bit [10:0] addra_mem;
bit [10:0] addrb_mem;
bit [10:0] counter_W;
bit [31:0] dia_mem;
bit [1:0] addrb_finish;
bit [6:0] errore_logica;
bit w_start_rd;

common_bram_reg_O11W32 u_mem
(
    .clk                 (clk),
    .is0_ena             (ena_mem),
    .is0_addra           (addra_mem),
    .is0_data            (dia_mem),
    .is1_enb             (enb_mem),
    .is1_addrb           (addrb_mem),
    .i_enb_reg           (enb_reg_mem),
    .od_ram              (od_data)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    if (i_rete_errore_vld) begin
        rete_errore_dev <= ~rete_errore_dev;
    end
    else begin
        rete_errore_dev <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (i_rete_errore_vld) begin
        if (rete_errore_dev) begin
            addr_rete <= addr_rete+1;
        end
    end
    else begin
        addr_rete <= 4;
    end
end
always_ff @(posedge clk)
begin
    if (i_rete_errore_vld) begin
        rete_errore <= i_rete_errore;
    end
end
always_ff @(posedge clk)
begin
    ena_wd_flag <= rete_errore_dev&(addr_rete==4);
end
always_ff @(posedge clk)
begin
    addr_tf <= (i_tf_vld)?addr_tf+1:68;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    ena_mem <= 0;
end
else begin
    if ((i_counter<4)&i_reading_rx) begin
        ena_mem <= ~i_completamento;
    end
    else if (i_cmd==1) begin
        ena_mem <= i_tf_vld|rete_errore_dev|ena_wd_flag;
    end
    else if (i_cmd==2) begin
        ena_mem <= i_weight_vld;
    end
    else begin
        ena_mem <= 0;
    end
end
end
always_ff @(posedge clk)
begin
    if ((i_counter<4)&i_reading_rx) begin
        addra_mem <= i_counter[1:0];
    end
    else if (i_cmd==1) begin
        if (i_tf_vld) begin
            addra_mem <= addr_tf;
        end
        else if (ena_wd_flag) begin
            addra_mem <= 12;
        end
        else begin
            addra_mem <= addr_rete;
        end
    end
    else if (i_cmd==2) begin
        addra_mem <= addra_mem+i_weight_vld;
    end
end
always_ff @(posedge clk)
begin
    if ((i_counter<4)&i_reading_rx) begin
        dia_mem <= i_data_rx;
    end
    else if (i_cmd==1) begin
        if (i_tf_vld) begin
            dia_mem <= i_true_false;
        end
        else if (ena_wd_flag) begin
            dia_mem <= i_wd_flag;
        end
        else begin
            dia_mem <= {i_rete_errore,rete_errore};
        end
    end
    else if (i_cmd==2) begin
        dia_mem <= i_weight;
    end
end
always_ff @(posedge clk)
begin
    if (i_counter==3) begin
        if (i_cmd==1) begin
            addrb_finish <= 1;
        end
        else if (i_cmd==2) begin
            addrb_finish <= (i_quantita_W_meno1<252)?1:2;
        end
        else begin
            addrb_finish <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_W <= 0;
end
else begin
    if ((i_cmd==2)&i_weight_vld) begin
        counter_W <= (counter_W==i_quantita_W_meno1)?0:counter_W+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    weight_vld_1d <= 0;
end
else begin
    weight_vld_1d <= i_weight_vld;
end
end
always_comb
begin
    if (i_cmd==1) begin
        w_start_rd = i_tf_vld;
    end
    else if (i_cmd==2) begin
        w_start_rd = i_weight_vld&(~weight_vld_1d);
    end
    else if (i_cmd==4) begin
        w_start_rd = (i_counter==3)&(~i_errore_flg);
    end
    else begin
        w_start_rd = 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_mem <= 0;
end
else begin
    if (enb_mem) begin
        if (addrb_finish==2) begin
            enb_mem <= ~(addrb_mem==2047);
        end
        else if (addrb_finish==1) begin
            enb_mem <= ~(addrb_mem==255);
        end
        else begin
            enb_mem <= ~(addrb_mem==7);
        end
    end
    else begin
        enb_mem <= w_start_rd;
    end
end
end
always_ff @(posedge clk)
begin
    if (enb_mem) begin
        addrb_mem <= addrb_mem+1;
    end
    else begin
        addrb_mem <= 0;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    enb_reg_mem <= 0;
end
else begin
    enb_reg_mem <= enb_mem;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= enb_reg_mem;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    errore_logica <= 0;
end
else begin
    if (i_counter<4) begin
        if (i_rete_errore_vld|i_tf_vld) begin
            errore_logica[0] <= 1;
        end
    end
    if (i_cmd==1) begin
        if (i_rete_errore_vld&i_tf_vld) begin
            errore_logica[1] <= 1;
        end
        if (i_weight_vld) begin
            errore_logica[2] <= 1;
        end
    end
    if (i_cmd==2) begin
        if (i_rete_errore_vld|i_tf_vld) begin
            errore_logica[3] <= 1;
        end
    end
    if (i_cmd!=2) begin
        if (|counter_W) begin
            errore_logica[4] <= 1;
        end
    end
    if (i_rete_errore_vld&(&addr_rete)) begin
        errore_logica[5] <= 1;
    end
    if (i_tf_vld&(addr_tf==70)) begin
        errore_logica[6] <= 1;
    end
end
end
assign od_errore_logica = {1'd0, errore_logica};
assign od_lunghezza_risp = addrb_finish;
assign od_valid = valid;

endmodule