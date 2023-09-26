`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module pool_v0_compressione_linea_W14C4C1P2L24 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit [13:0] i_data[3:0],
    input  bit i_valid[3:0],
    output bit od_valid_m1,
    output bit signed [13:0] od_data[1:0],
    output bit [1:0] od_index[1:0],
    output bit od_valid[1:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit pool_count;
bit pool_zero;
bit pool_end;
bit quadrato_end;
bit [1:0] quadrato_count;
bit [4:0] linea_count;
bit linea_end;
bit signed [13:0] data[3:0];
bit signed [13:0] data_sh[3:0];
bit [1:0] index[3:0];
bit [1:0] index_sh[3:0];
bit start_sh[1:0];
bit valid[1:0];
bit compr_count;
bit compr_count_pre;
bit compr_end;
bit pre_valid;
bit pre_end;
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
    pool_zero <= 1;
end
else begin
    if (i_valid[0]) begin
        pool_zero <= pool_end;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pool_end <= 0;
end
else begin
    if (i_valid[0]) begin
        pool_end <= (pool_count==2-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pool_count <= 0;
end
else begin
    if (i_valid[0]) begin
        pool_count <= (pool_end)?0:pool_count+1;
    end
end
end
always_ff @(posedge clk)
begin
    if (i_valid[0]) begin
        quadrato_end <= (quadrato_count==2*(2-1));
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    linea_end <= 0;
end
else begin
    if (i_valid[0]) begin
        linea_end <= (linea_count==24-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    linea_count <= 0;
end
else begin
    if (i_valid[0]) begin
        linea_count <= (linea_end)?0:linea_count+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    quadrato_count <= 0;
end
else begin
    if (i_valid[0]) begin
        if (linea_end) begin
            quadrato_count <= (quadrato_end)?0:quadrato_count+2;
        end
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        if (i_valid[i]) begin
            if (pool_zero|($signed(i_data[i])>data[i])) begin
                data[i] <= i_data[i];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<4; i++) begin
        if (i_valid[i]) begin
            if (pool_zero|($signed(i_data[i])>data[i])) begin
                index[i] <= quadrato_count+pool_count;
            end
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compr_count <= 0;
end
else begin
    if (valid[0]) begin
        compr_count <= (compr_end)?0:compr_count+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    compr_end <= 0;
end
else begin
    if (valid[0]) begin
        compr_end <= (compr_count==2-2);
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    start_sh[0] <= 0;
    start_sh[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        start_sh[i] <= i_valid[0]&pool_end;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    valid[0] <= 0;
    valid[1] <= 0;
end
else begin
    for (int i=0; i<2; i++) begin
        if (start_sh[i]) begin
            valid[i] <= 1;
        end
        else begin
            valid[i] <= valid[i]&~compr_end;
        end
    end
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (start_sh[i]) begin
            for (int k=0; k<2; k++) begin
                data_sh[i*2+k] <= data[i*2+k];
            end
        end
        else if (valid[i]) begin
            data_sh[(i+1)*2-1] <= data[(i+1)*2-1];
            for (int k=0; k<1; k++) begin
                data_sh[i*2+k] <= data_sh[i*2+k+1];
            end
        end
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<2; i++) begin
        if (start_sh[i]) begin
            for (int k=0; k<2; k++) begin
                index_sh[i*2+k] <= index[i*2+k];
            end
        end
        else if (valid[i]) begin
            index_sh[(i+1)*2-1] <= index[(i+1)*2-1];
            for (int k=0; k<1; k++) begin
                index_sh[i*2+k] <= index_sh[i*2+k+1];
            end
        end
    end
end
assign pre_end = (compr_count_pre==2-1);
always_ff @(posedge clk)
begin
if (rst__l) begin
    compr_count_pre <= 0;
end
else begin
    if (pre_valid) begin
        compr_count_pre <= (pre_end)?0:compr_count_pre+1;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    pre_valid <= 0;
end
else begin
    if (i_valid[0]&pool_end) begin
        pre_valid <= 1;
    end
    else begin
        pre_valid <= pre_valid&~pre_end;
    end
end
end
assign od_valid_m1 = pre_valid;
always_comb
begin
    for (int i=0; i<2; i++) begin
        od_data[i] = data_sh[i*2];
    end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        od_index[i] = index_sh[i*2];
    end
end
always_comb
begin
    for (int i=0; i<2; i++) begin
        od_valid[i] = valid[i];
    end
end

endmodule