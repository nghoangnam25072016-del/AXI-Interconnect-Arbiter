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

// Master 0 Read Address
input  logic [31:0] m0_araddr,
input  logic        m0_arvalid,
output logic        m0_arready,

// Master 0 Read Data
output logic [31:0] m0_rdata,
output logic        m0_rvalid,
input  logic        m0_rready,
    // Master 1 Read Address
input  logic [31:0] m1_araddr,
input  logic        m1_arvalid,
output logic        m1_arready,

// Master 1 Read Data
output logic [31:0] m1_rdata,
output logic        m1_rvalid,
input  logic        m1_rready,

    // Slave Read Address
output logic [31:0] s_araddr,
output logic        s_arvalid,
input  logic        s_arready,

// Slave Read Data
input  logic [31:0] s_rdata,
input  logic        s_rvalid,
output logic        s_rready,

    logic r_req0, r_req1;
logic r_grant0, r_grant1;
logic selected_read_master;

    assign r_req0 = m0_arvalid;
assign r_req1 = m1_arvalid;

axi_rr_arbiter u_read_arbiter (
    .clk(clk),
    .rst_n(rst_n),
    .req0(r_req0),
    .req1(r_req1),
    .grant0(r_grant0),
    .grant1(r_grant1)
);

    always_comb begin
    s_araddr  = 32'h0;
    s_arvalid = 1'b0;

    m0_arready = 1'b0;
    m1_arready = 1'b0;

    if (r_grant0) begin
        s_araddr   = m0_araddr;
        s_arvalid  = m0_arvalid;
        m0_arready = s_arready;
    end
    else if (r_grant1) begin
        s_araddr   = m1_araddr;
        s_arvalid  = m1_arvalid;
        m1_arready = s_arready;
    end
end

    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        selected_read_master <= 1'b0;
    else if (r_grant0 && s_arready)
        selected_read_master <= 1'b0;
    else if (r_grant1 && s_arready)
        selected_read_master <= 1'b1;
end

always_comb begin
    m0_rdata  = 32'h0;
    m0_rvalid = 1'b0;
    m1_rdata  = 32'h0;
    m1_rvalid = 1'b0;
    s_rready  = 1'b0;

    if (selected_read_master == 1'b0) begin
        m0_rdata  = s_rdata;
        m0_rvalid = s_rvalid;
        s_rready  = m0_rready;
    end
    else begin
        m1_rdata  = s_rdata;
        m1_rvalid = s_rvalid;
        s_rready  = m1_rready;
    end
end


    // Read address channel
assign s_arvalid = (grant0 & m0_arvalid) |
                   (grant1 & m1_arvalid);

assign s_araddr  = grant1 ? m1_araddr :
                   grant0 ? m0_araddr :
                   32'h0;

// Ready back to masters
assign m0_arready = grant0 & s_arready;
assign m1_arready = grant1 & s_arready;
endmodule
