`timescale 1ns / 1ps


module BasicParkingAssistSystem(
    input CLK, //100 MHz
    input RESET,
	// Bluetooth
	input RX,
	output [7:0] received_data,
	output [3:0] action,
	// LCD
	output reg LCM_RW,
    output wire LCM_EN,
    output reg LCM_RS,
	output reg [7:0] LCM_DATA,
	// buzzer
	output reg SOUND
    );

	reg [4:0] lcm_count;
    reg [25:0] divider;
    
    /***********************
     * Time Base Generator *
     ***********************/
    always @(posedge CLK or posedge RESET)
        if (RESET)
            divider <= {18'h00000, 1'b0};
        else
            divider <= divider + 1;

    assign init_clk = divider[17];
    assign LCM_EN = init_clk;
//	assign SOUND_CLK = divider[25];
	
	/******************************
     * Initial And Write LCM Data *
     ******************************/	
	always @(posedge init_clk or posedge RESET)
		if (RESET) begin
			lcm_count <= 5'b00000;
			LCM_RW <= 1'b0;
		end 
	   else begin
			if (lcm_count < 5'b11100)
			   lcm_count <= lcm_count + 1;
			else
               lcm_count <= 5'b10100;
				case (lcm_count)
				   5'b00000: 	begin
								   LCM_RS <= 1'b0;
								   LCM_RW <= 1'b0;
								   LCM_DATA <= 8'h38;
								end
					5'b00010: LCM_DATA <= 8'h01;
					5'b00011: LCM_DATA <= 8'h06;
					5'b00100: LCM_DATA <= 8'h0C;
					5'b00101: LCM_DATA <= 8'h81;
					5'b00110: 	begin
									LCM_RS <= 1'b1;
									LCM_DATA <= 8'h4E; // N
								end
					5'b00111: LCM_DATA <= 8'h6F; // o
					5'b01000: LCM_DATA <= 8'h77; // w
					5'b01001: LCM_DATA <= 8'h20; // space
					5'b01010: LCM_DATA <= 8'h64; // d
					5'b01011: LCM_DATA <= 8'h69; // i
					5'b01100: LCM_DATA <= 8'h73; // s
					5'b01101: LCM_DATA <= 8'h74; // t
					5'b01110: LCM_DATA <= 8'h61; // a
					5'b01111: LCM_DATA <= 8'h6E; // n
					5'b10000: LCM_DATA <= 8'h63; // c
					5'b10001: LCM_DATA <= 8'h65; // e
					5'b10010: LCM_DATA <= 8'h20; // space
					5'b10011: LCM_DATA <= 8'h3A; // :
					5'b10100: 	begin
									LCM_RS <= 1'b0;
									LCM_DATA <= 8'hC6;
								end
					5'b10101:	begin
									LCM_RS <= 1'b1; 
									if(DISTANCE[7:4] == 4'h0) LCM_DATA <= 8'h20;
									else LCM_DATA <= {4'h3, DISTANCE[7:4]};
								end
					5'b10110: LCM_DATA <= {4'h3, DISTANCE[3:0]};
					5'b10111: LCM_DATA <= 8'h30;
					5'b11000: LCM_DATA <= 8'h20;
					5'b11001: LCM_DATA <= 8'h20;
					5'b11010: LCM_DATA <= 8'h20;
					5'b11011: LCM_DATA <= 8'h20;
					5'b11100: LCM_DATA <= 8'h20;
				endcase
			end
	
	/******************************
     * 		  Make Sound 		  *
     ******************************/
	wire [21:0] tone_counter;
	wire sound_next;
	wire sound_invert;

	reg [21:0] num;
	reg [25:0] toggle_num; // Counter for toggling sound ON/OFF
	reg enable_sound; // Control whether sound is ON or OFF
	wire [21:0] next_num;
	wire toggle_enable;
	reg [25:0] toggle_num_limit;

	// Toggle 0.5-second ON/OFF logic
	always @(posedge CLK) begin
		if (DISTANCE[7:4] == 4'b0) begin
			if (toggle_num == toggle_num_limit) begin // Assuming 100 MHz clock d50000000 -> HIGH d50000 -> LOW
				toggle_num <= 26'd0;
				enable_sound <= ~enable_sound; // Toggle sound ON/OFF
			end else begin
				toggle_num <= toggle_num + 1;
			end
		end
	end

	assign toggle_enable = enable_sound;

	// Tone generation logic
	always @(posedge CLK) begin
		if (num == tone_counter) begin
			SOUND <= sound_invert & toggle_enable; // Sound only if toggle_enable is HIGH
			num <= 22'd0;
		end else begin
			SOUND <= sound_next & toggle_enable; // Maintain state when OFF
			num <= next_num;
		end
	end
	
	always @(posedge CLK) begin
		if (DISTANCE[7:4] == 4'h0) begin
			if (DISTANCE[3:0] <= 4'h2) begin
				tonecounter_reg <= 22'd10000;
				toggle_num_limit <= 26'd20000000;
			end else if (DISTANCE[3:0] <= 4'h5) begin
				tonecounter_reg <= 22'd90909;
				toggle_num_limit <= 26'd30000000;
			end else if (DISTANCE[3:0] <= 4'h8) begin
				tonecounter_reg <= 22'd200000;
				toggle_num_limit <= 26'd40000000;
			end else begin
				tonecounter_reg <= 22'd500000;
				toggle_num_limit <= 26'd50000000;
			end
		end else begin
			tonecounter_reg <= 0;
		end
	end

	reg [21:0] tonecounter_reg;
	assign tone_counter = tonecounter_reg; // Adjust for desired tone frequency (e.g., 800 Hz)
	assign next_num = num + 22'b1;
	assign sound_next = SOUND;
	assign sound_invert = ~SOUND;


	/******************************
	 *      Measure Distance      *
	 ******************************/
	// UART receiver to accept data from Bluetooth and transfer to FPGA
	wire RxD_data_ready;
	async_receiver inst0(
		.clk(CLK), 
		.RxD(RX), 
		.RxD_data_ready(RxD_data_ready), 
		.RxD_data(received_data), 
		.RxD_endofpacket(), 
		.RxD_idle());

	// Translate the received data
	action_code inst1(.ASCII_code(received_data), .action(action));
	
    // Control distance
	reg [7:0] DISTANCE;
	always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            DISTANCE <= 8'h10;
        end else if (RxD_data_ready) begin
            case (action)
                4'b0001: // ADD
                    if (DISTANCE[3:0] == 4'h9) begin
                        DISTANCE[3:0] <= 4'h0;
                        DISTANCE[7:4] <= DISTANCE[7:4] + 4'h1;
                    end else begin
                        DISTANCE[3:0] <= DISTANCE[3:0] + 4'h1;
                    end
                4'b0010: // SUB
                    if (DISTANCE[3:0] == 4'h0) begin
						if (DISTANCE[7:4] != 4'h0) begin
							DISTANCE[3:0] <= 4'h9;
							DISTANCE[7:4] <= DISTANCE[7:4] - 4'h1;
						end
                    end else begin
                        DISTANCE[3:0] <= DISTANCE[3:0] - 4'h1;
                    end
				default: 
					DISTANCE <= DISTANCE;
            endcase
        end
    end
endmodule
