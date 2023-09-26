`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_errore_B_risposta (
    input  bit clk,
    input  bit i_rst,
    input  bit [15:0] i_errore,
    input  bit i_errore_event,
    input  bit i_tutti_disp,
    input  bit [13:0] i_comando,
    input  bit [31:0] i_pacco_ricevuto,
    input  bit [31:0] i_pacco_ultimo,
    input  bit i_lung8k,
    output bit [31:0] od_data,
    output bit od_valid
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
localparam bit [14:0] numero_disp = 0;
localparam bit [1:0] c_2b10 = 2;
bit [2:0] counter;
bit counter_en;
bit valid;
bit [31:0] data;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
always_ff @(posedge clk)
begin
if (i_rst) begin
    counter_en <= 0;
end
else begin
    if (counter_en) begin
        counter_en <= ~(&counter);
    end
    else begin
        counter_en <= i_errore_event;
    end
end
end
always_ff @(posedge clk)
begin
    if (counter_en) begin
        counter <= counter+1;
    end
    else begin
        counter <= 0;
    end
end
always_ff @(posedge clk)
begin
    if (counter_en) begin
        if (counter==0) begin
            data <= {c_2b10,i_comando,i_tutti_disp,numero_disp};
        end
        else if (counter==1) begin
            data <= i_pacco_ricevuto;
        end
        else if (counter==2) begin
            data[31:16] <= (i_lung8k)?8192:1024;
            data[15:0] <= i_errore;
        end
        else if (counter==3) begin
            data <= i_pacco_ultimo;
        end
        else begin
            data <= 0;
        end
    end
end
always_ff @(posedge clk)
begin
if (i_rst) begin
    valid <= 0;
end
else begin
    valid <= counter_en;
end
end
assign od_data = data;
assign od_valid = valid;

endmodule