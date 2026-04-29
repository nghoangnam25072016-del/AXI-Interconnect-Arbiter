`timescale 1ns/1ps

module axi_interconnect_tb;

    logic clk;
    logic rst_n;

    logic [31:0] m0_awaddr;
    logic        m0_awvalid;
    logic        m0_awready;
    logic [31:0] m0_wdata;
    logic        m0_wvalid;
    logic        m0_wready;

    logic [31:0] m1_awaddr;
    logic        m1_awvalid;
    logic        m1_awready;
    logic [31:0] m1_wdata;
    logic        m1_wvalid;
    logic        m1_wready;

    logic [31:0] s_awaddr;
    logic        s_awvalid;
    logic        s_awready;
    logic [31:0] s_wdata;
    logic        s_wvalid;
    logic        s_wready;

    axi_interconnect_2x1 dut (
        .clk(clk),
        .rst_n(rst_n),

        .m0_awaddr(m0_awaddr),
        .m0_awvalid(m0_awvalid),
        .m0_awready(m0_awready),
        .m0_wdata(m0_wdata),
        .m0_wvalid(m0_wvalid),
        .m0_wready(m0_wready),

        .m1_awaddr(m1_awaddr),
        .m1_awvalid(m1_awvalid),
        .m1_awready(m1_awready),
        .m1_wdata(m1_wdata),
        .m1_wvalid(m1_wvalid),
        .m1_wready(m1_wready),

        .s_awaddr(s_awaddr),
        .s_awvalid(s_awvalid),
        .s_awready(s_awready),
        .s_wdata(s_wdata),
        .s_wvalid(s_wvalid),
        .s_wready(s_wready)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        m0_awaddr  = 32'h1000;
        m0_awvalid = 0;
        m0_wdata   = 32'hAAAA0000;
        m0_wvalid  = 0;

        m1_awaddr  = 32'h2000;
        m1_awvalid = 0;
        m1_wdata   = 32'hBBBB0000;
        m1_wvalid  = 0;

        s_awready = 1;
        s_wready  = 1;

        repeat (3) @(posedge clk);
        rst_n = 1;

        // Both masters request at the same time
        @(posedge clk);
        m0_awvalid = 1;
        m0_wvalid  = 1;
        m1_awvalid = 1;
        m1_wvalid  = 1;

        repeat (6) @(posedge clk);

        m0_awvalid = 0;
        m0_wvalid  = 0;
        m1_awvalid = 0;
        m1_wvalid  = 0;

        #50;
        $finish;
    end

    always @(posedge clk) begin
        if (s_awvalid && s_awready && s_wvalid && s_wready) begin
            $display("SLAVE WRITE: addr=%h data=%h", s_awaddr, s_wdata);
        end

        if (m0_awready && m0_wready) begin
            $display("MASTER 0 GRANTED");
        end

        if (m1_awready && m1_wready) begin
            $display("MASTER 1 GRANTED");
        end
    end

    initial begin
        $dumpfile("axi_interconnect.vcd");
        $dumpvars(0, axi_interconnect_tb);
    end

endmodule
