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

    // Master 0 Read
logic [31:0] m0_araddr;
logic        m0_arvalid;
logic        m0_arready;
logic [31:0] m0_rdata;
logic        m0_rvalid;
logic        m0_rready;

// Master 1 Read
logic [31:0] m1_araddr;
logic        m1_arvalid;
logic        m1_arready;
logic [31:0] m1_rdata;
logic        m1_rvalid;
logic        m1_rready;

// Slave Read
logic [31:0] s_araddr;
logic        s_arvalid;
logic        s_arready;
logic [31:0] s_rdata;
logic        s_rvalid;
logic        s_rready;

 //  READ PART 
        .m0_araddr(m0_araddr),
        .m0_arvalid(m0_arvalid),
        .m0_arready(m0_arready),
        .m0_rdata(m0_rdata),
        .m0_rvalid(m0_rvalid),
        .m0_rready(m0_rready),

        .m1_araddr(m1_araddr),
        .m1_arvalid(m1_arvalid),
        .m1_arready(m1_arready),
        .m1_rdata(m1_rdata),
        .m1_rvalid(m1_rvalid),
        .m1_rready(m1_rready),

        .s_araddr(s_araddr),
        .s_arvalid(s_arvalid),
        .s_arready(s_arready),
        .s_rdata(s_rdata),
        .s_rvalid(s_rvalid),
        .s_rready(s_rready),

        // Slave write
        .s_awaddr(s_awaddr),
        .s_awvalid(s_awvalid),
        .s_awready(s_awready),

        .s_wdata(s_wdata),
        .s_wvalid(s_wvalid),
        .s_wready(s_wready)

    always @(posedge clk) begin
    s_arready <= 1;

    if (s_arvalid && s_arready) begin
        s_rdata  <= s_araddr + 32'h100;
        s_rvalid <= 1;
    end
    else if (s_rready) begin
        s_rvalid <= 0;
    end
end

    m0_araddr  = 32'h1000;
m0_arvalid = 0;
m0_rready  = 1;

m1_araddr  = 32'h2000;
m1_arvalid = 0;
m1_rready  = 1;
    @(posedge rst_n);

m0_arvalid = 1;
m1_arvalid = 1;

#200;

m0_arvalid = 0;
m1_arvalid = 0;
    
    always @(posedge clk) begin
    if (m0_rvalid)
        $display("M0 READ DATA: %h", m0_rdata);

    if (m1_rvalid)
        $display("M1 READ DATA: %h", m1_rdata);
end

    endmodule
