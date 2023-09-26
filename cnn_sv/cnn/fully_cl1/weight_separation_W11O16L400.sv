`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl1_weight_separation_W11O16L400 (
    input  bit clk,
    input  bit i_rst,
    input  bit [10:0] i_weight,
    input  bit i_weight_vld,
    input  bit i_weight_start,
    output bit [10:0] od_weight,
    output bit od_weight_vld[15:0],
    output bit od_weight_start
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [8:0] counter;
bit vld_std_sh[15:0];
bit weight_vld;
bit weight_vld_std[15:0];
bit [10:0] weight[1:0];
bit weight_start;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    weight[0] <= i_weight;
    weight[1] <= weight[0];
end
always_ff @(posedge clk)
begin
    weight_vld <= i_weight_vld;
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter <= 0;
end
else begin
    if (i_weight_vld&i_weight_start) begin
        counter <= 0;
    end
    else if (weight_vld) begin
        counter <= (counter==(400-1))?0:counter+1;
    end
end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    vld_std_sh[0] <= 1;
    vld_std_sh[1] <= 0;
    vld_std_sh[2] <= 0;
    vld_std_sh[3] <= 0;
    vld_std_sh[4] <= 0;
    vld_std_sh[5] <= 0;
    vld_std_sh[6] <= 0;
    vld_std_sh[7] <= 0;
    vld_std_sh[8] <= 0;
    vld_std_sh[9] <= 0;
    vld_std_sh[10] <= 0;
    vld_std_sh[11] <= 0;
    vld_std_sh[12] <= 0;
    vld_std_sh[13] <= 0;
    vld_std_sh[14] <= 0;
    vld_std_sh[15] <= 0;
end
else begin
    if (i_weight_vld&i_weight_start) begin
        vld_std_sh[0] <= 1;
        for (int i=1; i<16; i++) begin
            vld_std_sh[i] <= 0;
        end
    end
    else if (weight_vld) begin
        if (counter==(400-1)) begin
            vld_std_sh[0] <= vld_std_sh[16-1];
            for (int i=1; i<16; i++) begin
                vld_std_sh[i] <= vld_std_sh[i-1];
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        weight_vld_std[i] <= vld_std_sh[i]&weight_vld;
    end
end
always_ff @(posedge clk)
begin
    if (weight_vld) begin
        weight_start <= (counter==0);
    end
end
assign od_weight = weight[1];
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_weight_vld[i] = weight_vld_std[i];
    end
end
assign od_weight_start = weight_start;

endmodule