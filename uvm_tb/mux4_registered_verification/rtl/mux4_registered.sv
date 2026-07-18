//------------------------------------------------------------------------------
// mux4_registered.sv
// Mux4 con registro de salida sincrono. Composicion de dos bloques ya
// verificados:
//   - mux4 (combinacional 4:1 parametrizado)
//   - register_bank (registro D con enable y reset asincrono activo alto)
//
// Interfaz mandatoria del Lab I. La salida 'out' es una version registrada
// de la entrada seleccionada, capturada en posedge clk cuando wr_en=1.
//------------------------------------------------------------------------------
module mux4_registered #(
    parameter int WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 rst,     // Reset asincrono activo alto
    input  logic                 wr_en,   // Enable de captura del registro
    input  logic [1:0]           sel,
    input  logic [WIDTH-1:0]     in1,
    input  logic [WIDTH-1:0]     in2,
    input  logic [WIDTH-1:0]     in3,
    input  logic [WIDTH-1:0]     in4,
    output logic [WIDTH-1:0]     out
);

    // Salida combinacional del mux (interna al bloque compuesto)
    logic [WIDTH-1:0] mux_out;

    mux4 #(.WIDTH(WIDTH)) u_mux4 (
        .din1   (in1),
        .din2   (in2),
        .din3   (in3),
        .din4   (in4),
        .select (sel),
        .dout   (mux_out)
    );

    register_bank #(.WIDTH(WIDTH)) u_reg_bank (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .in    (mux_out),
        .out   (out)
    );

endmodule
