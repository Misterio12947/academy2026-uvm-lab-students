//------------------------------------------------------------------------------
// control.sv
// Unidad de control del CPU multiciclo (Lab III del laboratorio Synopsys).
// FSM Moore de 4 estados basada en el diagrama del spec:
//   RST_ST -> FETCH_DECODE -> EXECUTE -> STORE -> FETCH_DECODE (loop)
//
// El estado RST_ST captura el primer cmd_in del master ("avoid losing one
// cycle" per spec) mientras los demas registros del datapath permanecen en 0
// por el reset asincrono.
//
// Decodificacion de cmd_in:
//   [6:5] -> in_select_a (muxA del datapath)
//   [4:3] -> in_select_b (muxB del datapath)
//   [2:0] -> opcode[2:0]  (opcode base ISA; opcode[3] reservado, siempre 0)
//
// nvalid_data se asserta en EXECUTE cuando la instruccion previa termino en
// error (p_error=1) Y algun mux selecciona feedback loop (2'b11).
//------------------------------------------------------------------------------
module control (
    input  logic       clk,
    input  logic       rst,           // Reset asincrono activo alto
    input  logic [6:0] cmd_in,
    input  logic       p_error,       // Error de instruccion previa (ya registrado externamente)
    output logic       aluin_reg_en,
    output logic       datain_reg_en,
    output logic       memoryWrite,
    output logic       memoryRead,
    output logic       selmux2,
    output logic       cpu_rdy,       // Pulso de 1 ciclo en STORE
    output logic       aluout_reg_en,
    output logic       nvalid_data,
    output logic [1:0] in_select_a,
    output logic [1:0] in_select_b,
    output logic [3:0] opcode         // 4 bits per spec del lab
);

    // Opcodes de la ISA (spec del lab)
    localparam logic [2:0] OP_ADD   = 3'b000;
    localparam logic [2:0] OP_SUB   = 3'b001;
    localparam logic [2:0] OP_MUL   = 3'b010;
    localparam logic [2:0] OP_DIV   = 3'b011;
    localparam logic [2:0] OP_NOP0  = 3'b100;
    localparam logic [2:0] OP_LOAD  = 3'b101;
    localparam logic [2:0] OP_STORE = 3'b110;
    localparam logic [2:0] OP_NOP1  = 3'b111;

    // Estados de la FSM (4 estados, incluyendo RST_ST explicito per spec)
    typedef enum logic [1:0] {
        RST_ST       = 2'b00,
        FETCH_DECODE = 2'b01,
        EXECUTE      = 2'b10,
        STORE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Extraccion de campos del cmd_in
    logic [1:0] cmd_muxA;
    logic [1:0] cmd_muxB;
    logic [2:0] cmd_op;
    always_comb begin
        cmd_muxA = cmd_in[6:5];
        cmd_muxB = cmd_in[4:3];
        cmd_op   = cmd_in[2:0];
    end

    //--------------------------------------------------------------------------
    // Registro de estado (reset asincrono activo alto)
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= RST_ST;
        else
            current_state <= next_state;
    end

    //--------------------------------------------------------------------------
    // Logica de transiciones
    //--------------------------------------------------------------------------
    always_comb begin
        unique case (current_state)
            RST_ST:       next_state = FETCH_DECODE;
            FETCH_DECODE: next_state = EXECUTE;
            EXECUTE:      next_state = STORE;
            STORE:        next_state = FETCH_DECODE;
            // VCS coverage off
            default:      next_state = RST_ST;
            // VCS coverage on
        endcase
    end

    //--------------------------------------------------------------------------
    // Logica de salidas (FSM Moore)
    //--------------------------------------------------------------------------
    always_comb begin
        // Defaults defensivos: todas las senales inactivas
        aluin_reg_en   = 1'b0;
        datain_reg_en  = 1'b0;
        memoryWrite    = 1'b0;
        memoryRead     = 1'b0;
        selmux2        = 1'b0;
        cpu_rdy        = 1'b0;
        aluout_reg_en  = 1'b0;
        nvalid_data    = 1'b0;
        // Senales de control del datapath salen siempre con la instruccion actual
        in_select_a    = cmd_muxA;
        in_select_b    = cmd_muxB;
        opcode         = {1'b0, cmd_op};

        unique case (current_state)
            RST_ST: begin
                // Captura el primer cmd_in del master para no perder un ciclo
                // (spec: "instruction stored for next stage").
                datain_reg_en = 1'b1;
            end

            FETCH_DECODE: begin
                // Decodifica y captura operandos A y B en los registros del ALU
                aluin_reg_en = 1'b1;
            end

            EXECUTE: begin
                // ALU computa, resultado se captura al final del ciclo.
                aluout_reg_en = 1'b1;
                // Si la instruccion previa termino en error Y algun mux
                // selecciona feedback loop, notificar a la ALU.
                nvalid_data = p_error &&
                              ((cmd_muxA == 2'b11) || (cmd_muxB == 2'b11));
                // LOAD: leer memoria en paralelo con la ALU
                if (cmd_op == OP_LOAD) begin
                    memoryRead = 1'b1;
                    selmux2    = 1'b1;   // ruta memoria -> registro de salida
                end
            end

            STORE: begin
                // Fase final: pulso cpu_rdy, captura siguiente cmd_in, y si
                // la instruccion es STORE escribe a memoria.
                cpu_rdy       = 1'b1;
                datain_reg_en = 1'b1;
                if (cmd_op == OP_STORE) begin
                    memoryWrite = 1'b1;
                end
            end

            // VCS coverage off
            default: ;
            // VCS coverage on
        endcase
    end

endmodule
