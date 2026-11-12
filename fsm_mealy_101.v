`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2026 17:55:16
// Design Name: 
// Module Name: fsm_mealy_101
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


module mealy_101_non_overlapping (
    input  wire clk,
    input  wire rst_n,     // Active-low asynchronous reset
    input  wire x,         // Serial bit stream input
    output reg  z          // Output: goes HIGH when "101" is detected
);

    // State Encoding using parameters or typedef enum
    parameter S0 = 2'b00; // Idle / No match yet
    parameter S1 = 2'b01; // Got '1'
    parameter S2 = 2'b10; // Got '10'

    reg [1:0] current_state, next_state;

    // ---------------------------------------------------------
    // 1. State Memory Block (Sequential with async reset)
    // ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // ---------------------------------------------------------
    // 2. Next-State Logic Block (Combinational)
    // ---------------------------------------------------------
    always @(*) begin
        // Default assignment to avoid latches
        next_state = current_state; 

        case (current_state)
            S0: begin
                if (x) next_state = S1;
                else   next_state = S0;
            end

            S1: begin
                if (x) next_state = S1; // Stays in S1 if another '1' arrives ('11')
                else   next_state = S2; // Got '10', waiting for final '1'
            end

            S2: begin
                if (x) next_state = S0; // "101" detected! Non-overlapping resets to S0
                else   next_state = S0; // Got "100", sequence broken, reset to S0
            end

            default: next_state = S0;
        endcase
    end

    // ---------------------------------------------------------
    // 3. Output Logic Block (Combinational - Mealy type)
    // ---------------------------------------------------------
    always @(*) begin
        z = 1'b0; // Default output

        // In a Mealy machine, output depends on both state AND input
        case (current_state)
            S0: z = 1'b0;
            S1: z = 1'b0;
            S2: begin
                if (x) z = 1'b1; // Output asserts immediately when input '1' hits state S2
                else   z = 1'b0;
            end
            default: z = 1'b0;
        endcase
    end

endmodule
