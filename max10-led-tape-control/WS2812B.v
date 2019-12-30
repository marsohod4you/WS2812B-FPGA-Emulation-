`timescale 1ns / 1ns

module WS2812B(
	input wire clk,
	input wire in,
	output wire out,
	output wire [23:0]q,
	output reg r,
	output reg g,
	output reg b
);

localparam reset_level = 3000;
localparam fix_level   = 50;

//reg clk = 0;
//always #26 clk = ~clk;

//capture "in" signal into shift register
reg [1:0]r_in = 0;
always @( posedge clk )
	r_in <= { r_in[0],in };

//detect zero-to-one transition in "in" signal via shift register
wire in_pos_edge; assign in_pos_edge = (r_in==2'b01);

//count how long "in" signal stays in zero
reg [15:0]reset_counter = 0;
always @( posedge clk )
	if( r_in[0] )
		reset_counter <= 0;
	else
	if( reset_counter<reset_level )
		reset_counter <= reset_counter+1;

//if "in" signal stays in zero for long time -> reset condition
wire reset; assign reset = (reset_counter==reset_level);

//every zero-to-one signal "in" transition mean start of new bit
reg [7:0]bit_length_cnt;
always @( posedge clk )
	if( in_pos_edge )
		bit_length_cnt <= 0;
	else
	if( bit_length_cnt<(fix_level+1) && !pass )
		bit_length_cnt <= bit_length_cnt + 1;

//get impulse of bit capture
wire bit_fix; assign bit_fix = (bit_length_cnt==fix_level);

reg pass = 0;
reg [5:0]bits_captured = 0;

//count number of bits captured
always @( posedge clk )
	if( reset )
		bits_captured <= 1'b0;
	else
	if( ~pass && bit_fix )
		bits_captured <= bits_captured+1'b1;

//after capturing 24 bits this chip is locked and pass input to output
always @( posedge clk )
	if( reset )
		pass <= 1'b0;
	else
	if( bits_captured==23 && bit_fix )
		pass <= 1'b1;
		
//actual pass after last bit receive (falling edge)
reg pass_final;
always @( posedge clk )
	if( reset )
		pass_final <= 1'b0;
	else
	if( r_in!=2'b11 )
		pass_final <= pass;
	
//accumulating shift register for RGB bits
reg [23:0]shift_rgb;
always @( posedge clk )
	if( bit_fix )
		shift_rgb <= { in, shift_rgb[23:1] };

//final capture register for RGB bits
reg [23:0]fix_rgb;
always @( posedge clk )
	if( bits_captured==23 && bit_fix )
		fix_rgb <= { in, shift_rgb[23:1] };

//when this chip captured 24 bits of RGB it becomes transparent
//and passes all input to output without change
assign out = pass_final ? in : 1'b0;

assign q = fix_rgb;

wire [7:0]wgreen; assign wgreen = { fix_rgb[0 ], fix_rgb[1 ], fix_rgb[2 ], fix_rgb[3 ], fix_rgb[4 ], fix_rgb[5 ], fix_rgb[6 ], fix_rgb[7 ] };
wire [7:0]wred;   assign wred   = { fix_rgb[8 ], fix_rgb[9 ], fix_rgb[10], fix_rgb[11], fix_rgb[12], fix_rgb[13], fix_rgb[14], fix_rgb[15] };
wire [7:0]wblue;  assign wblue  = { fix_rgb[16], fix_rgb[17], fix_rgb[18], fix_rgb[19], fix_rgb[20], fix_rgb[21], fix_rgb[22], fix_rgb[23] };

//pulse-width-modulation
reg [7:0]pwm_cnt;

always @( posedge clk )
begin
	pwm_cnt <= pwm_cnt+1;
	r <= pwm_cnt<wred;
	g <= pwm_cnt<wgreen;
	b <= pwm_cnt<wblue;
end

endmodule
