//------------------------------------------------------------------------------
// mux2.sv
// Multiplexor 2:1 parametrizado combinacional. Modulo derivado (no aparece
// en Lab I explicitamente pero se necesita en el top del CPU para el selmux2
// del control unit).
// select codifica el input activo:
//   0 -> din1, 1 -> din2
//------------------------------------------------------------------------------
module mux2 #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] din1,
    input  logic [WIDTH-1:0] din2,
    input  logic             select,
    output logic [WIDTH-1:0] dout
);

    always_comb begin
        unique case (select)
            1'b0: dout = din1;
            1'b1: dout = din2;
            // VCS coverage off
            // Default unreachable-by-design: select de 1 bit con ambos
            // patrones enumerados. Existe como defensa contra corrupcion de X.
            default: dout = '0;
            // VCS coverage on
        endcase
    end

endmodule
