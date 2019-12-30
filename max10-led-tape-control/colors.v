
module colors(
    input clk,
	 input clk100,
	 input button,
	 input wire data_in,
	 input wire [2:0]cnt,
    output data,
	 output [7:0]q
    );

wire [15:0]w_num;
wire w_req;
wire w_sync;

reg [23:0]rgb = 0;

reg [2:0]sss;
always @(posedge clk )
	sss<={ sss[1:0],w_sync };
wire sync_edge;
assign sync_edge = sss==3'b100;

reg dir = 1'b0;
reg [7:0]color;
reg [7:0]counter;
always @(posedge clk )
begin
	if( sync_edge )
	begin
		if( dir )
			color <= color-1;
		else
			color <= color+1;
		if((color==254 && dir==0)||(color==1 && dir==1))
		begin
			dir <= ~dir;
			counter <= counter+1;
		end
	end
end

reg [2:0]color2;
always @(posedge clk )
	color2 <= w_num[2:0]+cnt[2:0];

always @(posedge clk )
	if( w_req )
		if( button )
		begin
			//rgb <= w_sync ? 0 : { {6{color[2]}}, 2'b00, {6{color[1]}}, 2'b00, {6{color[0]}}, 2'b00 };
			case(counter[3:2])
			2'b00: rgb <= w_sync ? 0 : { color[0],color[1],color[2],color[3],color[4],color[5],color[6],color[7], 8'h00, 8'h00 };
			2'b01: rgb <= w_sync ? 0 : { 8'h00, color[0],color[1],color[2],color[3],color[4],color[5],color[6],color[7], 8'h00 };
			2'b10: rgb <= w_sync ? 0 : { 8'h00, 8'h00, color[0],color[1],color[2],color[3],color[4],color[5],color[6],color[7] };
			2'b11: rgb <= w_sync ? 0 : { {6{color2[2]}}, 2'b00, {6{color2[1]}}, 2'b00, {6{color2[0]}}, 2'b00 };
			endcase
		end
		else
			rgb <= 0;

LED_tape #( .NUM_LEDS(304), .NUM_RESET_LEDS(10) ) uut(
    .clk( clk ),
    .RGB( rgb ) ,
    .data( data ),
    .num( w_num ),
	 .sync( w_sync ),
    .req( w_req )
    );

//------------------------------
wire [23:0]q0;
wire data_out1;
wire r0,g0,b0;
WS2812B chip0(
	.clk( clk100 ),
	.in( data_in ),
	.out( data_out1 ),
	.q( q0 ),
	.r( r0 ),
	.g( g0 ),
	.b( b0 )
);

wire [23:0]q1;
wire data_out2;
wire r1,g1,b1;
WS2812B chip1(
	.clk( clk100 ),
	.in( data_out1 ),
	.out( data_out2 ),
	.q( q1 ),
	.r( r1 ),
	.g( g1 ),
	.b( b1 )
);
	
assign q= { 2'b00, r1, g1, b1, r0, g0, b0 };

endmodule
