//------------------------------------------------------------------------------
// memory.sv
// Memoria per spec del lab: 8 palabras de 2*WIDTH bits.
//   - Escritura sincrona (posedge clk) cuando memoryWrite=1
//   - Lectura asincrona (combinacional) — data_out siempre refleja mem[addr]
//   - memoryRead habilita la salida; cuando =0, data_out=0 (evita fuga de dato)
//------------------------------------------------------------------------------
module memory #(
    parameter WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 memoryWrite,
    input  logic                 memoryRead,
    input  logic [2*WIDTH-1:0]   memoryWriteData,
    input  logic [7:0]           memoryAddress,
    output logic [2*WIDTH-1:0]   memoryOutData
);

    // 8 palabras direccionables (solo se usan los 3 LSB de memoryAddress).
    localparam int DEPTH = 8;
    logic [2*WIDTH-1:0] mem_array [0:DEPTH-1];

    // Escritura sincrona
    always_ff @(posedge clk) begin
        if (memoryWrite)
            mem_array[memoryAddress[2:0]] <= memoryWriteData;
    end

    // Lectura asincrona con gating por memoryRead
    always_comb begin
        if (memoryRead)
            memoryOutData = mem_array[memoryAddress[2:0]];
        else
            memoryOutData = '0;
    end

endmodule
