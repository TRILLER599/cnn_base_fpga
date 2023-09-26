`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl0_fully_weight_memory_W11L400 (
    input  bit clk,
    input  bit i_rst,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    input  bit i_weight_start,
    input  bit [10:0] i_weight_mod,
    input  bit i_weight_mod_vld,
    input  bit i_read,
    input  bit i_read2update,
    output bit [10:0] od_weight,
    output bit od_load,
    output bit od_reading
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [10:0] dia_load;
bit enab_load;
bit load;
bit reading;
bit [8:0] addrab_load;
bit [8:0] addrb_read;
bit [8:0] addra_mem;
bit [8:0] addrb_mem;
bit ena_mem;
bit enb_mem;
bit [10:0] dia_mem;
bit [10:0] pd_mem_dob;

common_bram_O9W11 u_memory
(
    .clk                 (clk),
    .i_ena               (ena_mem),
    .i_addra             (addra_mem),
    .i_data              (dia_mem),
    .i_enb               (enb_mem),
    .i_addrb             (addrb_mem),
    .od_ram              (pd_mem_dob)
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign ena_mem = enab_load|i_weight_mod_vld;
assign addra_mem = addrab_load;
always_comb
begin
    if (enab_load) begin
        dia_mem = dia_load;
    end
    else begin
        dia_mem = i_weight_mod;
    end
end
always_comb
begin
    if (enab_load) begin
        addrb_mem = addrab_load;
    end
    else begin
        addrb_mem = addrb_read;
    end
end
assign enb_mem = enab_load|i_read|i_read2update;
always_ff @(posedge clk)
begin
if (i_rst) begin
    enab_load <= 0;
end
else begin
    enab_load <= i_weight_vld;
end
end
always_ff @(posedge clk)
begin
    if (i_weight_vld) begin
        dia_load <= i_weight;
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrab_load <= 0;
end
else begin
    if (i_weight_vld&i_weight_start) begin
        addrab_load <= 0;
    end
    else begin
        if (enab_load|i_weight_mod_vld) begin
            addrab_load <= (addrab_load==(400-1))?0:addrab_load+1;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    load <= 0;
end
else begin
    load <= enab_load;
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    addrb_read <= 0;
end
else begin
    if (i_read|i_read2update) begin
        addrb_read <= (addrb_read==(400-1))?0:addrb_read+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    reading <= 0;
end
else begin
    reading <= i_read;
end
end
assign od_weight = pd_mem_dob;
assign od_load = load;
assign od_reading = reading;

endmodule