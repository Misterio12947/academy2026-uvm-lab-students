//------------------------------------------------------------------------------
// top.sv
// CPU multiciclo top-level. Integra 7 submodulos ya firmados:
//   - mux4_registered (mux A y mux B)
//   - ALU
//   - register_bank (flags zero, error, y cmd)
//   - memory
//   - mux2_registered (mux de salida ALU vs memoria)
//   - control (FSM 4 estados)
//
// Composicion basada en las imagenes del spec del lab:
//   - Feedback loop: muxA<-dout_high, muxB<-dout_low
//   - Address de memoria: mux_a_out (registrado)
//   - Data-in de memoria: {dout_high, dout_low}
//   - p_error del control: registrado desde 'error' de la ALU
//------------------------------------------------------------------------------
module top #(
    parameter int WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 rst,
    input  logic [6:0]           cmd_in,
    input  logic [WIDTH-1:0]     din_1,
    input  logic [WIDTH-1:0]     din_2,
    input  logic [WIDTH-1:0]     din_3,
    output logic [WIDTH-1:0]     dout_low,
    output logic [WIDTH-1:0]     dout_high,
    output logic                 cpu_rdy,
    output logic                 zero,
    output logic                 error
);

    // Datapath wires
    logic [WIDTH-1:0]     mux_a_out;      // salida del mux A registrado
    logic [WIDTH-1:0]     mux_b_out;      // salida del mux B registrado
    logic [2*WIDTH-1:0]   alu_out;        // salida combinacional del ALU
    logic                 alu_zero;
    logic                 alu_error;
    logic [2*WIDTH-1:0]   mem_data_out;   // salida asincrona de memoria
    logic [6:0]           cmd_reg_out;    // cmd_in registrado (feed al control)

    // Control signals del control unit
    logic [1:0]           in_select_a;
    logic [1:0]           in_select_b;
    logic                 selmux2;
    logic [3:0]           opcode;
    logic                 memoryWrite;
    logic                 memoryRead;
    logic                 aluin_reg_en;
    logic                 datain_reg_en;
    logic                 aluout_reg_en;
    logic                 nvalid_data;

    //--------------------------------------------------------------------------
    // Mux A (con registro): din_1/2/3 y dout_high (feedback)
    //--------------------------------------------------------------------------
    mux4_registered #(.WIDTH(WIDTH)) mux_A (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluin_reg_en),
        .sel   (in_select_a),
        .in1   (din_1),
        .in2   (din_2),
        .in3   (din_3),
        .in4   (dout_high),
        .out   (mux_a_out)
    );

    //--------------------------------------------------------------------------
    // Mux B (con registro): din_1/2/3 y dout_low (feedback)
    //--------------------------------------------------------------------------
    mux4_registered #(.WIDTH(WIDTH)) mux_B (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluin_reg_en),
        .sel   (in_select_b),
        .in1   (din_1),
        .in2   (din_2),
        .in3   (din_3),
        .in4   (dout_low),
        .out   (mux_b_out)
    );

    //--------------------------------------------------------------------------
    // ALU (combinacional)
    //--------------------------------------------------------------------------
    ALU #(.WIDTH(WIDTH)) u_alu (
        .in1          (mux_a_out),
        .in2          (mux_b_out),
        .op           (opcode),
        .invalid_data (nvalid_data),
        .out          (alu_out),
        .zero         (alu_zero),
        .error        (alu_error)
    );

    //--------------------------------------------------------------------------
    // Registros de flags (capturan con aluout_reg_en)
    //--------------------------------------------------------------------------
    register_bank #(.WIDTH(1)) reg_zero (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluout_reg_en),
        .in    (alu_zero),
        .out   (zero)
    );

    register_bank #(.WIDTH(1)) reg_error (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluout_reg_en),
        .in    (alu_error),
        .out   (error)
    );

    //--------------------------------------------------------------------------
    // Memoria: address = mux_a_out (per diagramas del spec)
    //--------------------------------------------------------------------------
    memory #(.WIDTH(WIDTH)) u_memory (
        .clk             (clk),
        .memoryWrite     (memoryWrite),
        .memoryRead      (memoryRead),
        .memoryAddress   (mux_a_out),
        .memoryWriteData ({dout_high, dout_low}),
        .memoryOutData   (mem_data_out)
    );

    //--------------------------------------------------------------------------
    // Mux2 registrado de salida: selecciona entre ALU y memoria
    //--------------------------------------------------------------------------
    mux2_registered #(.WIDTH(WIDTH)) mux_out (
        .clk   (clk),
        .rst   (rst),
        .wr_en (aluout_reg_en),
        .sel   (selmux2),
        .in1   (alu_out),
        .in2   (mem_data_out),
        .out   ({dout_high, dout_low})
    );

    //--------------------------------------------------------------------------
    // Registro de cmd_in (captura con datain_reg_en)
    //--------------------------------------------------------------------------
    register_bank #(.WIDTH(7)) reg_cmd (
        .clk   (clk),
        .rst   (rst),
        .wr_en (datain_reg_en),
        .in    (cmd_in),
        .out   (cmd_reg_out)
    );

    //--------------------------------------------------------------------------
    // Unidad de control (p_error <- error registrado, feedback loop)
    //--------------------------------------------------------------------------
    control u_control (
        .clk           (clk),
        .rst           (rst),
        .cmd_in        (cmd_reg_out),
        .p_error       (error),
        .aluin_reg_en  (aluin_reg_en),
        .datain_reg_en (datain_reg_en),
        .memoryWrite   (memoryWrite),
        .memoryRead    (memoryRead),
        .selmux2       (selmux2),
        .cpu_rdy       (cpu_rdy),
        .aluout_reg_en (aluout_reg_en),
        .nvalid_data   (nvalid_data),
        .in_select_a   (in_select_a),
        .in_select_b   (in_select_b),
        .opcode        (opcode)
    );

endmodule
