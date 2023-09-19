`timescale 100ps/100ps

module distrib
#(
parameter ORDER           = 5,
parameter WIDTH           = 6
)
(
    input                 clk,
    input                 ena,
    input  [ORDER-1:0]    addra,
    input  [WIDTH-1:0]    dia,
    input  [ORDER-1:0]    addrb,
    output [WIDTH-1:0]    dob
);

bit [WIDTH-1:0]           ram[2**ORDER-1:0];

always_ff @(posedge clk)
begin
    if (ena)
        ram[addra] <= dia;
end

assign dob = ram[addrb];

endmodule