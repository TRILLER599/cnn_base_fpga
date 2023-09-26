`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_int_vld_unsign_W16N6 (
    input  bit clk,
    input  bit i_rst,
    input  bit [15:0] i_data[5:0],
    input  bit i_valid,
    input  bit [2:0] i_mux,
    output bit [15:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [1:0] valid;
bit [15:0] data0[1:0];
bit mux0;
bit [15:0] data1;
bit [1:0] w_mux0;
bit w_mux1;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= (valid<<<1)|i_valid;
end
end
assign w_mux0 = i_mux;
always_ff @(posedge clk)
begin
    mux0 <= i_mux>>>2;
end
assign w_mux1 = mux0;
always_ff @(posedge clk)
begin
    for (int i=0; i<1; i++) begin
        if (w_mux0==0) begin
            data0[i] <= i_data[4*i];
        end
        else if (w_mux0==1) begin
            data0[i] <= i_data[4*i+1];
        end
        else if (w_mux0==2) begin
            data0[i] <= i_data[4*i+2];
        end
        else begin
            data0[i] <= i_data[4*i+3];
        end
    end
    if (w_mux0==0) begin
        data0[1] <= i_data[4];
    end
    else if (w_mux0==1) begin
        data0[1] <= i_data[5];
    end
    else begin
        data0[1] <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (w_mux1==0) begin
        data1 <= data0[0];
    end
    else begin
        data1 <= data0[1];
    end
end
assign od_data = data1;
assign od_valid = valid[1];

endmodule