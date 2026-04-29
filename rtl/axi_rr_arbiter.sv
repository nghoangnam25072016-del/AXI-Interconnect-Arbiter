module axi_rr_arbiter (
    input  logic clk,
    input  logic rst_n,

    input  logic req0,
    input  logic req1,

    output logic grant0,
    output logic grant1
);

    logic last_grant;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            last_grant <= 1'b0;
        else if (grant0)
            last_grant <= 1'b0;
        else if (grant1)
            last_grant <= 1'b1;
    end

    always_comb begin
        grant0 = 1'b0;
        grant1 = 1'b0;

        case ({req1, req0})
            2'b01: grant0 = 1'b1;
            2'b10: grant1 = 1'b1;
            2'b11: begin
                if (last_grant == 1'b0)
                    grant1 = 1'b1;
                else
                    grant0 = 1'b1;
            end
            default: begin
                grant0 = 1'b0;
                grant1 = 1'b0;
            end
        endcase
    end

endmodule
