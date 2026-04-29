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


task random_master0();
    forever begin
        @(posedge clk);
        if ($urandom_range(0,1)) begin
            m0_awvalid <= 1;
            m0_wvalid  <= 1;
        end else begin
            m0_awvalid <= 0;
            m0_wvalid  <= 0;
        end
    end
endtask

task random_master1();
    forever begin
        @(posedge clk);
        if ($urandom_range(0,1)) begin
            m1_awvalid <= 1;
            m1_wvalid  <= 1;
        end else begin
            m1_awvalid <= 0;
            m1_wvalid  <= 0;
        end
    end
endtask


initial begin
    @(posedge rst_n);

    m0_awvalid = 1;
    m0_wvalid  = 1;

    m1_awvalid = 1;
    m1_wvalid  = 1;
end


always @(posedge clk) begin
    s_awready <= $urandom_range(0,1);
    s_wready  <= $urandom_range(0,1);
end


int m0_count = 0;
int m1_count = 0;

always @(posedge clk) begin
    if (m0_awready && m0_wready)
        m0_count++;

    if (m1_awready && m1_wready)
        m1_count++;
end

final begin
    $display("M0 count = %0d", m0_count);
    $display("M1 count = %0d", m1_count);
end

    endmodule
