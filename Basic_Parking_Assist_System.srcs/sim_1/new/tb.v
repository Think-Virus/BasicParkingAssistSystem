module tb();

    // Inputs
    reg CLK;
    reg RESET;
    reg [3:0] ACTION;

    // Outputs
    wire [9:0] DISTANCE_RAW;
    wire [3:0] thousands;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    // Instantiate the DistanceController module
    DistanceController uut (
        .CLK(CLK),
        .RESET(RESET),
        .ACTION(ACTION),
        .DISTANCE_RAW(DISTANCE_RAW),
        .thousands(thousands),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    // Clock generation
    always #5 CLK = ~CLK; // Clock period = 10 time units

    initial begin
        // Initialize Inputs
        CLK = 0;
        RESET = 1;
        ACTION = 4'b0000;

        // Apply reset
        #10 RESET = 0; // Release reset after 10 time units

        // Test ADD functionality
        #20 ACTION = 4'b0001; // ADD
        #50 ACTION = 4'b0001;
        #30 ACTION = 4'b0001;

        // Test SUB functionality
        #20 ACTION = 4'b0010; // SUB
        #30 ACTION = 4'b0010;
        #20 ACTION = 4'b0010;

        // Keep default
        #20 ACTION = 4'b0000;

        // End of simulation
        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, DISTANCE_RAW = %d, Thousands = %d, Hundreds = %d, Tens = %d, Ones = %d",
                 $time, DISTANCE_RAW, thousands, hundreds, tens, ones);
    end

endmodule
