///////////////////////////////////////////////////////////////////////////////////////////////////////
// Testbench evaluate the BRAM organizing pattern when rd&wr port width is different
// By: Chen Yang
// 12/11/2017
///////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module Channel_Buffer_BRAM_tb;

	reg [15:0] indata;
	reg inclk, outclk;
	reg [6:0]rdaddr;
	reg rden, wren;
	reg [10:0] wraddr;
	wire [255:0] outdata;


	Channel_Buffer_BRAM UUT(
		.data(indata),
		.inclock(inclk),
		.outclock(outclk),
		.rdaddress(rdaddr),
		.rden(rden),
		.wraddress(wraddr),
		.wren(wren),
		.q(outdata));
		
	
	always #1 inclk <= ~inclk;
	always #10 outclk <= ~outclk;
	
	initial begin
		inclk <= 1;
		outclk <= 1;
		indata <= 16'd0;
		rdaddr <= 7'd0;
		rden <= 1'b0;
		wren <= 1'b0;
		wraddr <= 11'd0;
		
		// write
		#10
		wren <= 1'b1;
		indata <= 16'd1;
		wraddr <= 11'd0;
		#2
		indata <= 16'd2;
		wraddr <= 11'd16;
		#2
		indata <= 16'd3;
		wraddr <= 11'd32;
		#2
		indata <= 16'd4;
		wraddr <= 11'd48;
		#2
		indata <= 16'hA;
		wraddr <= 11'd1;
		#2
		indata <= 16'hB;
		wraddr <= 11'd2;
	
		// read
		#20
		wren <= 1'b0;
		rden <= 1'b1;
		rdaddr <= 7'd0;
		#20
		rdaddr <= 7'd1;
		#20
		rdaddr <= 7'd2;
		#20
		rdaddr <= 7'd3;
		#20
		rdaddr <= 7'd125;
		#20
		rdaddr <= 7'd126;
		
		#1200
		$stop;
	
	end
	
	
endmodule