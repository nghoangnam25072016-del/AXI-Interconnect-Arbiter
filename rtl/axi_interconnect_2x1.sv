module axi_interconnect_2x1 (
    input  logic clk,
    input  logic rst_n,

    // Master 0 Write Address
    input  logic [31:0] m0_awaddr,
    input  logic        m0_awvalid,
    output logic        m0_awready,

    // Master 0 Write Data
    input  logic [31:0] m0_wdata,
    input  logic        m0_wvalid,
    output logic        m0_wready,

    // Master 1 Write Address
    input  logic [31:0] m1_awaddr,
    input  logic        m1_awvalid,
    output logic        m1_awready,

    // Master 1 Write Data
    input  logic [31:0] m1_wdata,
    input  logic        m1_wvalid,
    output logic        m1_wready,

    // Slave Write Address
    output logic [31:0] s_awaddr,
    output logic        s_awvalid,
    input  logic        s_awready,

    // Slave Write Data
    output logic [31:0] s_wdata,
    output logic        s_wvalid,
    input  logic        s_wready
);

    logic req0, req1;
    logic grant0, grant1;

    assign req0 = m0_awvalid && m0_wvalid;
    assign req1 = m1_awvalid && m1_wvalid;

    axi_rr_arbiter u_arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .req0(req0),
        .req1(req1),
        .grant0(grant0),
        .grant1(grant1)
    );

    always_comb begin
        // defaults
        s_awaddr  = 32'h0;
        s_awvalid = 1'b0;
        s_wdata   = 32'h0;
        s_wvalid  = 1'b0;

        m0_awready = 1'b0;
        m0_wready  = 1'b0;
        m1_awready = 1'b0;
        m1_wready  = 1'b0;

        if (grant0) begin
            s_awaddr  = m0_awaddr;
            s_awvalid = m0_awvalid;
            s_wdata   = m0_wdata;
            s_wvalid  = m0_wvalid;

            m0_awready = s_awready;
            m0_wready  = s_wready;
        end
        else if (grant1) begin
            s_awaddr  = m1_awaddr;
            s_awvalid = m1_awvalid;
            s_wdata   = m1_wdata;
            s_wvalid  = m1_wvalid;

            m1_awready = s_awready;
            m1_wready  = s_wready;
        end
    end

endmodule
