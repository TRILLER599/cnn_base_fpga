`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module separ_union_mux_int_vld_sign_W33N16 (
    input  bit clk,
    input  bit i_rst,
    input  bit signed [32:0] i_data[15:0],
    input  bit i_valid,
    input  bit [3:0] i_mux,
    output bit signed [32:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [1:0] valid;
bit signed [32:0] data0[3:0];
bit [1:0] mux0;
bit signed [32:0] data1;
bit [1:0] w_mux0;
bit [1:0] w_mux1;


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
    for (int i=0; i<4; i++) begin
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
end
always_ff @(posedge clk)
begin
    if (w_mux1==0) begin
        data1 <= data0[0];
    end
    else if (w_mux1==1) begin
        data1 <= data0[1];
    end
    else if (w_mux1==2) begin
        data1 <= data0[2];
    end
    else begin
        data1 <= data0[3];
    end
end
assign od_data = data1;
assign od_valid = valid[1];

endmodule