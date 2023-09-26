`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module ferrore_ferr_2soglie_limitato_W14C16S1S16 (
    input  bit clk,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    input  bit i_start,
    input  bit [15:0] i_maschera,
    input  bit [13:0] i_Y1,
    input  bit [13:0] i_Y0,
    input  bit [13:0] i_Y_limit,
    input  bit [15:0] i_rilevanza,
    output bit [13:0] od_data[0:0],
    output bit od_data_vld[0:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] Y_limit_m;
bit [15:0] maschera;
bit [15:0] rilevanza;
bit [15:0] rilevanza_pip0;
bit signed [13:0] data[0:0];
bit valid;
bit valid_pip0[0:0];
bit valid_pip1[0:0];
bit signed [13:0] y_err_tm[0:0];
bit [13:0] y_err[0:0];
bit signed [13:0] Y_limit;
bit signed [13:0] y_err_t[0:0];
bit signed [13:0] y_err_tr[0:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign Y_limit = i_Y_limit;
always_ff @(posedge clk)
begin
    Y_limit_m <= -Y_limit;
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (i_data_vld[i]) begin
            data[i] <= i_data[i];
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= i_data_vld[0];
end
end
always_ff @(posedge clk)
begin
    if (i_data_vld[0]) begin
        if (i_start) begin
            maschera <= i_maschera;
        end
        else begin
            for (int i=0; i<15; i++) begin
                maschera[i] <= maschera[i+1];
            end
            maschera[16-1] <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
    if (i_data_vld[0]) begin
        if (i_start) begin
            rilevanza <= i_rilevanza;
        end
        else begin
            for (int i=0; i<15; i++) begin
                rilevanza[i] <= rilevanza[i+1];
            end
            rilevanza[16-1] <= 0;
        end
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        y_err_t[i] = (maschera[i*16])?($signed(i_Y1)-data[i]):($signed(i_Y0)-data[i]);
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (maschera[i*16]) begin
            y_err_tm[i] <= (~y_err_t[i][13])?y_err_t[i]:0;
        end
        else begin
            y_err_tm[i] <= (y_err_t[i][13])?y_err_t[i]:0;
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid_pip0[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        valid_pip0[i] <= valid;
    end
end
end
always_ff @(posedge clk)
begin
    if (valid) begin
        rilevanza_pip0 <= rilevanza;
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        if (rilevanza_pip0[i*16]) begin
            if (y_err_tm[i]>Y_limit) begin
                y_err_tr[i] = Y_limit;
            end
            else if (y_err_tm[i]<Y_limit_m) begin
                y_err_tr[i] = Y_limit_m;
            end
            else begin
                y_err_tr[i] = y_err_tm[i];
            end
        end
        else begin
            y_err_tr[i] = 0;
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (valid_pip0[i]) begin
            y_err[i] <= y_err_tr[i];
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid_pip1[0] <= 0;
end
else begin
    for (int i=0; i<1; i++) begin
        valid_pip1[i] <= valid_pip0[i];
    end
end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data[i] = y_err[i];
    end
end
always_comb
begin
    for (int i=0; i<1; i++) begin
        od_data_vld[i] = valid_pip1[i];
    end
end

endmodule