`timescale 100ps/100ps

(* keep_hierarchy = "yes" *) module fully_cl3_fully_backprop_controllo_D14P3N2P1P400S1 (
    input  bit clk,
    input  bit i_rst_g,
    input  bit i_rst,
    input  bit [13:0] i_data[0:0],
    input  bit i_data_vld[0:0],
    input  bit i_img_end,
    input  bit [15:0] i_minibatch,
    input  bit i_aggiorntamento,
    input  bit i_backfifo_empty,
    output bit od_backfifo_start,
    output bit od_weight_reading,
    output bit [13:0] od_data[0:0],
    output bit od_data_vld,
    output bit od_buf_diretto_empty,
    output bit [1:0] od_errore
);


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
enum bit[1:0] {LAVORO = 2'd0, ATTESA_CALCOLO = 2'd1, CALCOLO = 2'd2} fsm;
bit stream_start;
bit reading_lungo;
bit buff_reading;
bit [15:0] minibatch;
bit [15:0] minibatch_count;
bit [15:0] calcolo_count;
bit [8:0] buff_reading_count;
bit backfifo_start;
bit weight_reading;
bit errore_traboc;
bit errore;
bit fin_minib;
bit buff_reading_fin;
bit pd_buff_empty;
bit pd_buff_ready;
bit rst__pip;
bit rst__l;

common_FIFO_Fast_Array_O10W14T1022A1 u_buff_diretto
(
    .clk                 (clk),
    .i_rst               (rst__l),
    .i_write             (i_data_vld[0]),
    .i_data              (i_data),
    .i_read              (buff_reading),
    .od_data             (od_data),
    .od_empty            (pd_buff_empty),
    .od_wr_ready         (pd_buff_ready)
);


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
    stream_start <= 1;
end
else begin
    stream_start <= (i_data_vld[0])?i_img_end:stream_start;
end
end
always_ff @(posedge clk)
begin
    if (i_aggiorntamento) begin
        minibatch <= i_minibatch;
    end
end
assign fin_minib = (minibatch_count==minibatch);
always_ff @(posedge clk)
begin
if (rst__l) begin
    minibatch_count <= 0;
end
else begin
    if (i_data_vld[0]) begin
        if (i_img_end&fin_minib) begin
            minibatch_count <= 0;
        end
        else begin
            minibatch_count <= minibatch_count+stream_start;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    buff_reading_count <= 0;
end
else begin
    buff_reading_count <= (weight_reading)?buff_reading_count+1:0;
end
end
assign buff_reading_fin = (buff_reading_count==399);
always_ff @(posedge clk)
begin
if (rst__l) begin
    fsm <= LAVORO;
end
else begin
    case (fsm)
        LAVORO : begin
            if (i_data_vld[0]&i_img_end&fin_minib) begin
                fsm <= ATTESA_CALCOLO;
            end
        end
        ATTESA_CALCOLO : begin
            if (calcolo_count==minibatch) begin
                fsm <= LAVORO;
            end
            else if (~i_backfifo_empty) begin
                fsm <= CALCOLO;
            end
        end
        CALCOLO : begin
            if (buff_reading_fin) begin
                fsm <= ATTESA_CALCOLO;
            end
        end
    endcase
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore <= 0;
end
else begin
    if (errore) begin
        errore <= 1;
    end
    else begin
        if (buff_reading&pd_buff_empty) begin
            errore <= 1;
        end
        else if (fsm==ATTESA_CALCOLO) begin
            errore <= i_data_vld[0]|((calcolo_count==minibatch)&~i_backfifo_empty);
            errore <= i_data_vld[0];
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    calcolo_count <= 0;
end
else begin
    if (calcolo_count==minibatch) begin
        calcolo_count <= 0;
    end
    else begin
        if ((i_data_vld[0]&i_img_end&reading_lungo)|buff_reading_fin) begin
            calcolo_count <= calcolo_count+1;
        end
        else begin
            calcolo_count <= calcolo_count;
        end
    end
end
end
always_ff @(posedge clk)
begin
    if (fsm==LAVORO) begin
        if (i_data_vld[0]&stream_start) begin
            reading_lungo <= ~i_backfifo_empty;
        end
    end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    buff_reading <= 0;
end
else begin
    if (fsm==LAVORO) begin
        if (i_data_vld[0]) begin
            buff_reading <= (stream_start)?~i_backfifo_empty:reading_lungo;
        end
        else begin
            buff_reading <= 0;
        end
    end
    else begin
        buff_reading <= weight_reading;
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    weight_reading <= 0;
end
else begin
    if (fsm==LAVORO) begin
        weight_reading <= 0;
    end
    else begin
        if (weight_reading) begin
            weight_reading <= ~buff_reading_fin;
        end
        else begin
            weight_reading <= (fsm==ATTESA_CALCOLO)&~i_backfifo_empty;
        end
    end
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    backfifo_start <= 0;
end
else begin
    backfifo_start <= (fsm==ATTESA_CALCOLO)&~i_backfifo_empty;
end
end
always_ff @(posedge clk)
begin
if (rst__l) begin
    errore_traboc <= 0;
end
else begin
    errore_traboc <= errore_traboc|(~pd_buff_empty&~pd_buff_ready);
end
end
assign od_backfifo_start = backfifo_start;
assign od_weight_reading = weight_reading;
assign od_data_vld = buff_reading;
assign od_buf_diretto_empty = pd_buff_empty;
assign od_errore = {errore_traboc,errore};

endmodule