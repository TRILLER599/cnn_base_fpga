`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_dw_arrot_dsp_W14W14S16W8 (
    input  bit clk,
    input  bit signed [13:0] i_data,
    input  bit i_data_en[15:0],
    input  bit signed [13:0] i_grad,
    input  bit i_grad_en[15:0],
    input  bit signed [7:0] i_arrot[15:0],
    input  bit i_arrot_vld[15:0],
    output bit signed [27:0] od_data[15:0]
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit signed [13:0] data[15:0];
bit signed [13:0] gradiente[15:0];
bit signed [27:0] mult[15:0];
bit signed [27:0] mult_arrot[15:0];
bit signed [7:0] arrot[15:0];


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
    data[0] <= (i_data_en[0])?i_data:data[0];
    for (int i=1; i<16; i++) begin
        data[i] <= (i_data_en[i])?data[i-1]:data[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        gradiente[i] <= (i_grad_en[i])?i_grad:gradiente[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        arrot[i] <= (i_arrot_vld[i])?i_arrot[i]:arrot[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        mult[i] <= data[i]*gradiente[i];
    end
end
always_ff @(posedge clk)
begin
    for (int i=0; i<16; i++) begin
        mult_arrot[i] <= mult[i]+arrot[i];
    end
end
always_comb
begin
    for (int i=0; i<16; i++) begin
        od_data[i] = mult_arrot[i];
    end
end

endmodule