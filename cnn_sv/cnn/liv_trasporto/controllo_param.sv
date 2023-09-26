`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module liv_trasporto_controllo_param (
    input  bit clk,
    input  bit i_rst,
    input  bit [31:0] i_data,
    input  bit i_reading,
    input  bit i_completamento,
    input  bit [2:0] i_counter,
    input  bit i_questo_disp,
    input  bit i_comando_hard,
    input  bit [31:0] i_pacco_prossimo,
    input  bit [2:0] i_cmd,
    input  bit [6:0] i_profondita_attuale,
    input  bit [15:0] i_strato_ultimo_attuale,
    output bit [15:0] od_errore,
    output bit od_errore_flg
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
bit errore_flg;
bit [15:0] errore;
bit [15:0] w_data_15_0;
bit [15:0] w_data_31_16;


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
assign w_data_15_0 = i_data[15:0];
assign w_data_31_16 = i_data[31:16];
always_ff @(posedge clk)
begin
if (i_rst) begin
    errore_flg <= 0;
end
else begin
    if (i_counter==0) begin
        if (i_reading) begin
            if (~i_data[30]&(!i_data[29:16]|(i_data[29:16]>4))&(i_data[15]|(i_data[14:0]==0))) begin
                errore_flg <= 1;
            end
            else begin
                errore_flg <= 0;
            end
        end
    end
    else begin
        if (i_questo_disp&(~i_comando_hard)&(~errore_flg)) begin
            if (i_counter==1) begin
                if (i_pacco_prossimo!=i_data) begin
                    errore_flg <= 1;
                end
            end
            else if (i_counter==2) begin
                if (~i_completamento) begin
                    if (i_cmd==1) begin
                        if ((w_data_15_0>i_strato_ultimo_attuale)|(w_data_15_0<2)) begin
                            errore_flg <= 1;
                        end
                        else if (!w_data_31_16|(w_data_31_16>1024)) begin
                            errore_flg <= 1;
                        end
                    end
                    else if (i_cmd==2) begin
                        if (w_data_15_0>2044) begin
                            errore_flg <= 1;
                        end
                        else if (w_data_31_16>=i_profondita_attuale) begin
                            errore_flg <= 1;
                        end
                        else if (w_data_31_16>=16) begin
                            errore_flg <= 1;
                        end
                    end
                    else if (i_cmd==3) begin
                        if (w_data_15_0>4088) begin
                            errore_flg <= 1;
                        end
                    end
                    else if (i_cmd==4) begin
                        if (i_data[23:16]==1) begin
                            if (w_data_15_0>8176) begin
                                errore_flg <= 1;
                            end
                        end
                        else if (i_data[23:16]==2) begin
                            if (w_data_15_0>4088) begin
                                errore_flg <= 1;
                            end
                        end
                        else if (i_data[23:16]==4) begin
                            if (w_data_15_0>2044) begin
                                errore_flg <= 1;
                            end
                        end
                        else begin
                            errore_flg <= 1;
                        end
                    end
                end
            end
            else if (i_counter==3) begin
                if (i_cmd==1) begin
                    if (w_data_15_0<8) begin
                        errore_flg <= 1;
                    end
                    else if (w_data_15_0>15) begin
                        errore_flg <= 1;
                    end
                    else if (w_data_31_16!=i_profondita_attuale) begin
                        errore_flg <= 1;
                    end
                end
                else if (i_cmd==4) begin
                    if (w_data_15_0>=64) begin
                        errore_flg <= 1;
                    end
                end
            end
            else if (i_counter==4) begin
                if (i_cmd==1) begin
                    if (i_data<2) begin
                        errore_flg <= 1;
                    end
                    else if (i_data>1048576) begin
                        errore_flg <= 1;
                    end
                end
            end
        end
    end
end
end
always_ff @(posedge clk)
begin
    if (i_counter==0) begin
        if (i_reading) begin
            if (~i_data[30]&(!i_data[29:16]|(i_data[29:16]>4))&(i_data[15]|(i_data[14:0]==0))) begin
                errore <= 3;
            end
        end
    end
    else begin
        if (i_questo_disp&(~i_comando_hard)&(~errore_flg)) begin
            if (i_counter==1) begin
                if (i_pacco_prossimo!=i_data) begin
                    errore <= 2;
                end
            end
            else if (i_counter==2) begin
                if (~i_completamento) begin
                    if (i_cmd==1) begin
                        if ((w_data_15_0>i_strato_ultimo_attuale)|(w_data_15_0<2)) begin
                            errore <= 10;
                        end
                        else if (!w_data_31_16|(w_data_31_16>1024)) begin
                            errore <= 11;
                        end
                    end
                    else if (i_cmd==2) begin
                        if (w_data_15_0>2044) begin
                            errore <= 20;
                        end
                        else if (w_data_31_16>=i_profondita_attuale) begin
                            errore <= 21;
                        end
                        else if (w_data_31_16>=16) begin
                            errore <= 22;
                        end
                    end
                    else if (i_cmd==3) begin
                        if (w_data_15_0>4088) begin
                            errore <= 30;
                        end
                    end
                    else if (i_cmd==4) begin
                        if (i_data[23:16]==1) begin
                            if (w_data_15_0>8176) begin
                                errore <= 41;
                            end
                        end
                        else if (i_data[23:16]==2) begin
                            if (w_data_15_0>4088) begin
                                errore <= 41;
                            end
                        end
                        else if (i_data[23:16]==4) begin
                            if (w_data_15_0>2044) begin
                                errore <= 41;
                            end
                        end
                        else begin
                            errore <= 40;
                        end
                    end
                end
            end
            else if (i_counter==3) begin
                if (i_cmd==1) begin
                    if (w_data_15_0<8) begin
                        errore <= 12;
                    end
                    else if (w_data_15_0>15) begin
                        errore <= 13;
                    end
                    else if (w_data_31_16!=i_profondita_attuale) begin
                        errore <= 14;
                    end
                end
                else if (i_cmd==4) begin
                    if (w_data_15_0>=64) begin
                        errore <= 42;
                    end
                end
            end
            else if (i_counter==4) begin
                if (i_cmd==1) begin
                    if (i_data<2) begin
                        errore <= 15;
                    end
                    else if (i_data>1048576) begin
                        errore <= 16;
                    end
                end
            end
        end
    end
end
assign od_errore = errore;
assign od_errore_flg = errore_flg;

endmodule