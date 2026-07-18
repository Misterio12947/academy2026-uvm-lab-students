//------------------------------------------------------------------------------
// mux2_registered.sv
// Mux2 con registro de salida sincrono. Composicion de dos bloques ya
// verificados:
//   - mux2 (combinacional 2:1 parametrizado)
//   - register_bank (registro D con enable y reset asincrono activo alto)
//
// Bus de datos de 2*WIDTH bits (para conectar salidas de la ALU y datos
// hacia/desde memoria en el top del CPU). El register_bank se instancia con
// WIDTH_INTERNO = 2*WIDTH.
//
// Modulo derivado (no aparece en Lab I explicitamente) necesario para el
// top del CPU: la senal 'selmux2' del control unit selecciona entre dos
// buses de 2*WIDTH bits y los captura en un registro.
//------------------------------------------------------------------------------
module mux2_registered #(
    parameter int WIDTH = 8   // Ancho base; el bus interno es 2*WIDTH
) (
    input  logic                     clk,
    input  logic                     rst,     // Reset asincrono activo alto
    input  logic                     sel,
    input  logic                     wr_en,   // Enable de captura del registro
    input  logic [2*WIDTH-1:0]       in1,
    input  logic [2*WIDTH-1:0]       in2,
    output logic [2*WIDTH-1:0]       out
);

    // Salida combinacional del mux (interna al bloque compuesto)
    logic [2*WIDTH-1:0] mux_out;

    mux2 #(.WIDTH(2*WIDTH)) u_mux2 (
        .din1   (in1),
        .din2   (in2),
        .select (sel),
        .dout   (mux_out)
    );

    register_bank #(.WIDTH(2*WIDTH)) u_reg_bank (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .in    (mux_out),
        .out   (out)
    );

endmodule
