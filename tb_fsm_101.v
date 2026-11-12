`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 18:52:24
// Design Name: 
// Module Name: tb_fsm_101
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_mealy_101_non_overlapping;

    // Inputs to the DUT (Design Under Test)
    reg clk;
    reg rst_n;
    reg x;

    // Output from the DUT
    wire z;

    // Instantiate the Mealy FSM Module
    mealy_101_non_overlapping uut (
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .z(z)
    );

    // ---------------------------------------------------------
    // Clock Generation: 10ns clock period (100 MHz)
    // ---------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // Stimulus Generation
    // ---------------------------------------------------------
    initial begin
        // Initialize signals
        rst_n = 1'b0;
        x     = 1'b0;

        // Apply asynchronous reset for 20ns
        #20;
        rst_n = 1'b1;
        #10;

        // Test Vector Sequence: 
        // We want to feed: 0 -> 1 -> 0 -> 1 (Detect 1) -> 1 -> 0 -> 1 (Detect 1 non-overlapping)
        
        @(posedge clk); x = 1'b0; // Time: ~35ns
        @(posedge clk); x = 1'b1; // Time: ~45ns (Got '1')
        @(posedge clk); x = 1'b0; // Time: ~55ns (Got '10')
        @(posedge clk); x = 1'b1; // Time: ~65ns (Got '101' -> z should pulse HIGH!)
        
        // Testing non-overlapping behavior immediately after
        @(posedge clk); x = 1'b1; // Time: ~75ns (Starts new sequence attempt)
        @(posedge clk); x = 1'b0; // Time: ~85ns (Got '10')
        @(posedge clk); x = 1'b1; // Time: ~95ns (Got '101' -> z should pulse HIGH again!)
        
        // Feed random bits to verify stability
        @(posedge clk); x = 1'b0; // Time: ~105ns
        @(posedge clk); x = 1'b0; // Time: ~115ns
        @(posedge clk); x = 1'b1; // Time: ~125ns

        // End simulation after observing outputs
        #50;
        $display("Simulation completed successfully.");
        $finish;
    end

    // ---------------------------------------------------------
    // Monitor Output / Debug Display
    // ---------------------------------------------------------
    initial begin
        $monitor("Time = %0t ns | rst_n = %b | x = %b | State = %b | z = %b", 
                 $time, rst_n, x, uut.current_state, z);
    end

endmodule