

module top_testbench;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //import apb_pkg::*;
    //import algn_pkg::*;
    import algn_test_pkg::*;

    reg clk;

    initial begin
        clk = 0;
    end
  
    apb_if apb_inf(.pclk(clk));

    cfs_aligner dut(
        .clk(clk),
        .reset_n(apb_inf.preset_n),
        .paddr(apb_inf.paddr),
        .pwrite(apb_inf.pwrite),
        .psel(apb_inf.psel),
        .penable(apb_inf.penable),
        .pwdata(apb_inf.pwdata),
        .pready(apb_inf.pready),
        .prdata(apb_inf.prdata),
        .pslverr(apb_inf.pslverr)
    );

    always #5 clk = ~clk;

    initial begin
        apb_inf.preset_n = 1;
        #3;
        apb_inf.preset_n = 0;
        #30;
        apb_inf.preset_n = 1;
    end

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.agent_apb", "vif", apb_inf);

        run_test();
    end

endmodule
