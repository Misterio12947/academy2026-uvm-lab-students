//------------------------------------------------------------------------------
// alu.sv
// ALU parametrizada per lab spec (op 4 bits, out 2*WIDTH, -1 en error).
//------------------------------------------------------------------------------
module ALU #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0]     in1, in2,
    input  logic [3:0]           op,            // 4 bits per lab spec
    input  logic                 invalid_data,
    output logic [2*WIDTH-1:0]   out,
    output logic                 zero,
    output logic                 error
);

    // ISA: opcodes en 3 bits (op[2:0]). op[3] reservado.
    localparam logic [2:0] ADD   = 3'b000;
    localparam logic [2:0] SUB   = 3'b001;
    localparam logic [2:0] MUL   = 3'b010;
    localparam logic [2:0] DIV   = 3'b011;
    localparam logic [2:0] NOP0  = 3'b100;
    localparam logic [2:0] LOAD  = 3'b101;
    localparam logic [2:0] STORE = 3'b110;
    localparam logic [2:0] NOP1  = 3'b111;

    // -1 en 2*WIDTH bits = all-ones (complemento a dos)
    localparam logic [2*WIDTH-1:0] MINUS_ONE = {(2*WIDTH){1'b1}};

    always_comb begin
        // Defaults defensivos: previenen latches inferidos
        out   = '0;
        zero  = 1'b0;
        error = 1'b0;

        if (invalid_data) begin
            error = 1'b1;
            out   = MINUS_ONE;
            zero  = 1'b0;
        end
        else begin
            unique case (op[2:0])
                ADD: begin
                    out  = in1 + in2;
                    zero = (out == '0);
                end
                SUB: begin
                    out  = in1 - in2;
                    zero = (out == '0);
                end
                MUL: begin
                    out  = in1 * in2;
                    zero = (out == '0);
                end
                DIV: begin
                    if (in2 == '0) begin
                        error = 1'b1;
                        out   = MINUS_ONE;
                        zero  = 1'b0;
                    end
                    else begin
                        out  = in1 / in2;
                        zero = (out == '0);
                    end
                end
                LOAD, STORE: begin
                    out  = in2;
                    zero = (out == '0);
                end
                NOP0, NOP1: begin
                    out   = '0;
                    zero  = 1'b1;
                    error = 1'b0;
                end
                // VCS coverage off
                // Default unreachable-by-design: opcode 3-bit enumerado
                // completo (8/8 patrones). Existe como practica defensiva
                // contra corrupcion de X. No cuenta en coverage porque no se
                // ejecuta en 2-estados con opcode valido.
                default: begin
                    out   = MINUS_ONE;
                    zero  = 1'b0;
                    error = 1'b1;
                end
                // VCS coverage on
            endcase
        end
    end

endmodule