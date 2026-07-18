//------------------------------------------------------------------------------
// mux4.sv
// Multiplexor 4:1 parametrizado combinacional (Lab I del laboratorio Synopsys).
// Interfaz mandatoria del lab. select codifica el input activo:
//   00 -> din1, 01 -> din2, 10 -> din3, 11 -> din4
//------------------------------------------------------------------------------
module mux4 #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] din1,
    input  logic [WIDTH-1:0] din2,
    input  logic [WIDTH-1:0] din3,
    input  logic [WIDTH-1:0] din4,
    input  logic [1:0]       select,
    output logic [WIDTH-1:0] dout
);

    always_comb begin
        unique case (select)
            2'b00: dout = din1;
            2'b01: dout = din2;
            2'b10: dout = din3;
            2'b11: dout = din4;
            // VCS coverage off
            // Default unreachable-by-design: select de 2 bits con los 4
            // patrones enumerados. Existe como defensa contra corrupcion de X.
            default: dout = '0;
            // VCS coverage on
        endcase
    end

endmodule
