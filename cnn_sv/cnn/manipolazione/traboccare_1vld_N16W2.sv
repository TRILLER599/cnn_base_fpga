`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module manipolazione_traboccare_1vld_N16W2 (
    input  bit clk,
    input  bit i_rst,
    input  bit [1:0] i_data[15:0],
    input  bit i_valid,
    output bit od_data
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit [15:0] data_molto;
bit valid;
bit data_uno;

function automatic bit func__bit_simile_2(input bit [1:0] i_data);
    func__bit_simile_2 = 0;
    for (int i=1; i<2; i++) begin
        if (i_data[i] != i_data[0])
            func__bit_simile_2 = 1;
    end
endfunction


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= i_valid;
end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        data_molto[i] <= func__bit_simile_2(i_data[i]);
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    data_uno <= 0;
end
else begin
    data_uno <= |data_molto&valid;
end
end
assign od_data = data_uno;

endmodule