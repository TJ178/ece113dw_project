`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:12:59 03/01/2022 
// Design Name: 
// Module Name:    vga 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
		input vgaclk,					//pixel clock: 25MHz
		input rst,					//asynchronous reset
		input image[0:255][0:39][15:0],
		output hsync,				//horizontal sync out
		output vsync,				//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue	//blue vga output
   );
	
	// video structure constants
	parameter hpixels = 800;// horizontal pixels per line
	parameter hpulse = 96; 	// hsync pulse length
	parameter hbp = 144; 	// end of horizontal back porch
	parameter hfp = 784; 	// beginning of horizontal front porch
	
	parameter vlines = 525; // vertical lines per frame
	parameter vpulse = 2; 	// vsync pulse length
	parameter vbp = 33; 		// end of vertical back porch
	parameter vfp = 515; 	// beginning of vertical front porch
	
	// registers for storing the horizontal & vertical counters
	reg [9:0] hc;
	reg [9:0] vc;

	always @(posedge vgaclk, posedge rst)
	begin
		 //reset condition
		if (rst == 1)
		begin
			hc <= 0;
			vc <= 0;
		end
		else
		begin
			// keep counting until the end of the line
			if (hc < hpixels - 1)
				hc <= hc + 1;
			else
			begin
				hc <= 0;
				if (vc < vlines - 1)
					vc <= vc + 1;
				else
					vc <= 0;
			end
			
		end
	end

	assign hsync = (hc < hpulse) ? 0:1;
	assign vsync = (vc < vpulse) ? 0:1;
	
	//convert to input address space:
	reg [$clog2[256]-1:0] h_addr;
	reg [$clog2[40]-1:0] v_addr;
	assign h_addr = hc > 512 ? 0 : h_addr >> 1;
	assign v_addr = vc > 480 ? 0 : vc / 12;

	always @(*)
	begin
		// first check if we're within vertical active video range
		if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp)
		begin
			//addrb = ((((vc - vbp) / 10) * 64) + ((hc - hbp) / 10));
			if(hc > 512) begin
				red  = 'b0;
				green = 'b0;
				blue = b'0;
			end else begin
				red = image[h_addr][v_addr] > 512 ? 4'b1111 : image[h_addr][v_addr][4:1];
				green = image[h_addr][v_addr] < 512 ? 4'b0 : image[h_addr][v_addr][15:12];
				blue = image[h_addr][v_addr] < 512 ? 4'b0 : image[h_addr][v_addr][15:12];
			end
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
			//addrb = 0;
		end
	end

endmodule
