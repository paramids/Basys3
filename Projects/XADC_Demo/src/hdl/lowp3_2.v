`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	
// 
// Create Date:    12:57:28 11/23/2016 
// Design Name: 
// Module Name:    lowp2 
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
module lowp3_2(signal_in,signal_out, clock_in,reset,enable);

input enable;// enable
input   signed  [27:0]  signal_in;// X[n]
output  reg signed  [27:0]  signal_out;//Y[n]
input   clock_in;  //Input clock
input   reset;          //reset filter on reset high.
integer z;

function integer log2(input integer v); begin log2=0; while(v>>log2) log2=log2+1; end endfunction// This function calcualtes the logarithm of the input. This function is used to determine the register lengths.

parameter N=1024;//Total number of samples
parameter N2=log2(N)-1; //Required register size for N



parameter down_sample=1;//The amount by which to down sample the signal.
reg signed[27:0] signal_in_1; //Register to hold X[n].
parameter N_down_sample=4;//Amount by which to down sample signal.
parameter N2_down_sample=log2(N_down_sample)-1;//Calculate the reg size to hold downsample value.
reg[N2_down_sample:0] down_sample_clk;//Definition of the clock to down sample the clock value.

reg[N2:0] count;//Definition of the register to hold the total number of samples
reg signed [28+N2-1:0]  signal_out_tmp; //Definition of the reg to temporary hold the intermediate sum.


//Sampling & Down-sampling
always@(posedge clock_in) //Act on the positive edge of the clock
begin
	if(reset) //Define reset condition
	begin
		signal_in_1<=0;
		down_sample_clk<=0;
	end
	else	//Normal Cconditon
	begin
		if(enable) //Check whether the module is enabled
		begin
			if(down_sample_clk<N_down_sample)
			begin
				down_sample_clk<=down_sample_clk+1'b1;	//Increment the clock without latching in the input signal		
			end
			else
			begin
				signal_in_1<=signal_in; //Latch the signal when down_sample clock equals N_down_samples
				down_sample_clk<=0;
			end
		end
	end
end


//Accumulation and Assignment
always@(posedge clock_in)
begin
	if(reset)
	begin
		signal_out_tmp<=0;
		count<=0;
		signal_out<=0;
	end
	else
	begin
		if(down_sample_clk==N_down_sample)
		begin
			if(count<N)
			begin
				count<=count+1'b1; //Increment Counter
				signal_out_tmp<=signal_out_tmp+signal_in; //Accumulate
			end
			else
			begin
				count<=0;//Reset counter
				signal_out<=signal_out_tmp[27+N2:N2]; //Output Assignment & division by N is also handled here.
				signal_out_tmp<=0; //Reset temp register
			end
		end
	end
end



endmodule
