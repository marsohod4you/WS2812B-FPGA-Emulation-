`timescale 1ns / 1ns

module LED_tape_TB;

// Inputs
reg clk = 0;
always
	begin
		#206;
		clk = ~clk;
	end

// Outputs
wire data;
wire [15:0] w_num;
wire w_req;
wire w_sync;

reg [1:0]r_sync =0;
always @(posedge clk )
	r_sync <= { r_sync[0], w_sync };

reg [7:0]color = 8'h31;
always @(posedge clk )
	if( r_sync==2'b01 )
		color<=color+1;
		
reg [23:0]rgb = 0;
always @(posedge clk )
	if( w_req )
		rgb <= { 8'hA5, 8'hB6, color };

// Instantiate the LED TAPE control Unit
LED_tape #( .NUM_LEDS(7), .NUM_RESET_LEDS(10) )uut (
	.clk(clk), 
	.RGB(rgb), 
	.data(data), 
	.num(w_num), 
	.sync(w_sync),
	.req(w_req)
);

reg clk100 = 0;
always
	begin
		#5;
		clk100 = ~clk100;
	end
	
wire out0;
wire [23:0]q0;
WS2812B WS2812B_0(
	.clk( clk100 ),
	.in( data ),
	.out( out0 ),
	.q( q0 ),
	.r(),
	.g(),
	.b()
);

wire out1;
wire [23:0]q1;
WS2812B WS2812B_1(
	.clk( clk100 ),
	.in( out0 ),
	.out( out1 ),
	.q( q1 ),
	.r(),
	.g(),
	.b()
);

wire out2;
wire [23:0]q2;
WS2812B WS2812B_2(
	.clk( clk100 ),
	.in( out1 ),
	.out( out2 ),
	.q( q2 ),
	.r(),
	.g(),
	.b()
);


wire out3;
wire [23:0]q3;
WS2812B WS2812B_3(
	.clk( clk100 ),
	.in( out2 ),
	.out( out3 ),
	.q( q3 ),
	.r(),
	.g(),
	.b()
);

initial begin
	$dumpfile("out.vcd");
	$dumpvars(0,LED_tape_TB);

	#2000000;
	$finish(0);
end

endmodule

