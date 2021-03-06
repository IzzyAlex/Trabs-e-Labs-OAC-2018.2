
`ifndef PARAM
	`include "Parametros.v"
`endif

`timescale 1 ns / 10 ps

module FPALU_tb;

reg ICLOCK;
reg [31:0] IA, IB;
reg [4:0] ICONTROL;
wire [31:0] ORESULT,ORESULT0,ORESULT1,ORESULT2,ORESULT3;
wire OZERO,ONAN,OOVERFLOW,OUNDERFLOW,OCOMPRESULT;

always
	#10 ICLOCK = ~ICLOCK;	// T=10+10 Clock de 50MHz

FPALU fpalu0 (
	.iclock(ICLOCK),
	.idataa(IA),
	.idatab(IB),
	.icontrol(ICONTROL),
	.oresult(ORESULT),
	.onan(ONAN),
	.ozero(OZERO), 
	.ooverflow(OOVERFLOW), 
	.ounderflow(OUNDERFLOW),
	.oCompResult(OCOMPRESULT)
	);

	
initial
	begin
	
		$display($time, " << Início da Simulação >> ");
		ICLOCK=1'b0;

		IA = 32'h3F800000; // 1.0
		IB = 32'h40000000; // 2.0
		ICONTROL = FOPADD;
	
		#200 
		IA = 32'h40000000;  //2.0 
		IB = 32'h40800000;  // 4.0
		ICONTROL = FOPSUB;
		
		#200
		IA = 32'h40400000;  //3.0
		IB = 32'h3FC00000;  // 1.5
		ICONTROL = FOPMUL;
		
		#200
		IA = 32'h40000000; // 3.0
		IB = 32'h40400000; // 2.0
		ICONTROL = FOPDIV;

		#200
		IA = 32'h41500000; // 13.0
		IB = 32'h0;
		ICONTROL = FOPSQRT;

		#200
		IA = 32'hBF800000;  //-1.0
		IB = 32'h0;
		ICONTROL = FOPABS;
		
		#20
		IA = 32'h3F800000;  //1.0
		IB = 32'h0;
		ICONTROL = FOPNEG;
		
		#200
		IA = 32'h3F800000;  //1.0
		IB = 32'h3F800000;  //1.0
		ICONTROL = FOPCEQ;
		
		#200
		IA = 32'h3F800000;  // 1.0
		IB = 32'h40000000;  //2.0
		ICONTROL = FOPCLT;
		
		#200
		IA = 32'hBF800000;  // -1.0
		IB = 32'h3F800000;  // 1.0
		ICONTROL = FOPCLE;
		
		#200
		IA = 32'h4;			// 4
		IB = 32'h0;
		ICONTROL = FOPCVTSW;

		#200
		IA = 32'h40800000; // 4.0
		IB = 32'h0;
		ICONTROL = FOPCVTWS;
		
		#200
		$display($time, "<< Final da Simulação >>");
		$stop;
	end

	
initial
	begin
//		$display("                 time, Clock, iA,       iB,       iControl, oResult,      oZero, oNaN, oVerflow, oUnderflow, oCompResult"); 
//		$monitor("%d,   %b,    %h, %h, %d,       %h,      %b,    %b,    %b,        %b,          %b",$time, ICLOCK, IA, IB, ICONTROL, ORESULT, 
//				   OZERO,ONAN,OOVERFLOW,OUNDERFLOW,OCOMPRESULT);	
					
		$display("                 time, iA,       iB,       iControl, oResult,      oZero, oNaN, oVerflow, oUnderflow, oCompResult"); 
		$monitor("%d,  %h, %h, %d,       %h,      %b,    %b,    %b,        %b,          %b",$time, IA, IB, ICONTROL, ORESULT, 
				   OZERO,ONAN,OOVERFLOW,OUNDERFLOW,OCOMPRESULT);	
	
	end


endmodule
