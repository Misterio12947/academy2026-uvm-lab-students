//------------------------------------------------------------------------------
// register_bank.sv
// Registro D parametrizado en WIDTH con enable y reset asincrono activo alto.
// Nota: el nombre "register_bank" se conserva por respeto a la interfaz
// mandatoria del lab, pero arquitecturalmente es un unico registro D-type,
// no un banco de N registros direccionables (no hay port de address).
//------------------------------------------------------------------------------
module register_bank #(
    parameter int WIDTH = 8
) (
    input  logic              clk,
    input  logic              rst,     // Reset asincrono activo alto
    input  logic              wr_en,   // Enable: captura solo cuando wr_en=1
    input  logic [WIDTH-1:0]  in,
    output logic [WIDTH-1:0]  out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= '0;             // Reset asincrono domina sobre wr_en
        else if (wr_en)
            out <= in;             // Captura en flanco de clk
        // else: retencion implicita del valor previo
    end

endmodule
