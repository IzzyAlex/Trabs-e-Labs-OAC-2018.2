`ifndef PARAM
	`include "../Parametros.v"
`endif

// *
// * Unidade de Forwards e Hazards
// *

module FwdHazardUnitM (
	input 		iCLK,
	input [4:0] iID_Rs1,
	input [4:0] iID_Rs2,
	input [4:0] iID_Rd,

	input [4:0] iEX_Rs1,
	input [4:0] iEX_Rs2,	
	input [4:0] iEX_Rd,	
	
	input [4:0] iMEM_Rd,
	
	input [4:0] iWB_Rd,
	
	input [9:0] iID_InstrType, // {Load,Store,TipoR ou TipoRPadrão,TipoI ou INT2FP,Jal FP2INT,Jalr,Branch,DivRem}
	input [9:0] iEX_InstrType,
	input [9:0] iMEM_InstrType,
	input [9:0] iWB_InstrType,
		
	input iBranch,				// resultado do branch em ID
	
	output oIF_Stall,			
	output oID_Stall,			
	output oEX_Stall,			
	output oIFID_Flush,		
	output oIDEX_Flush,			
	output oEXMEM_Flush,

	output [2:0] oFwdRs1,
	output [2:0] oFwdRs2,	
	output [2:0] oFwdA,
	output [2:0] oFwdB

);
	
// Aqui deve ter todos os sinais possíveis para detectar qualquer hazard
// Nem todos estão sendo usados, logo gera warnings

wire wID_TipoFP	= iID_InstrType[8];
wire wID_DivRem	= iID_InstrType[7];	
wire wID_Load 	 	= iID_InstrType[6];
wire wID_Store  	= iID_InstrType[5];
wire wID_TipoR  	= iID_InstrType[4];
wire wID_TipoRFP 	= iID_InstrType[4];
wire wID_TipoI  	= iID_InstrType[3];
wire wID_INT2FP  	= iID_InstrType[3];
wire wID_Jal 	 	= iID_InstrType[2];
wire wID_FP2INT 	= iID_InstrType[2];
wire wID_Jalr 	 	= iID_InstrType[1];
wire wID_Branch 	= iID_InstrType[0];
wire wID_ULA		= wID_TipoR || wID_TipoI; // forward do ULAresult
wire wID_PC4		= wID_Jal   || wID_Jalr;  // forward do PC+4


wire wEX_TipoFP	= iEX_InstrType[8];
wire wEX_DivRem 	= iEX_InstrType[7];
wire wEX_Load 	 	= iEX_InstrType[6];
wire wEX_Store  	= iEX_InstrType[5];
wire wEX_TipoR  	= iEX_InstrType[4];
wire wEX_TipoRFP 	= iEX_InstrType[4];
wire wEX_TipoI  	= iEX_InstrType[3];
wire wEX_INT2FP  	= iEX_InstrType[3];
wire wEX_Jal 	 	= iEX_InstrType[2];
wire wEX_FP2INT 	= iEX_InstrType[2];
wire wEX_Jalr 	 	= iEX_InstrType[1];
wire wEX_Branch 	= iEX_InstrType[0];
wire wEX_ULA 		= wEX_TipoR || wEX_TipoI;
wire wEX_PC4		= wEX_Jal   || wEX_Jalr;


wire wMEM_TipoFP	= iMEM_InstrType[8];
wire wMEM_DivRem 	= iMEM_InstrType[7];
wire wMEM_Load 	= iMEM_InstrType[6];
wire wMEM_Store  	= iMEM_InstrType[5];
wire wMEM_TipoR  	= iMEM_InstrType[4];
wire wMEM_TipoRFP 	= iMEM_InstrType[4];
wire wMEM_TipoI  	= iMEM_InstrType[3];
wire wMEM_INT2FP  	= iMEM_InstrType[3];
wire wMEM_Jal 	 	= iMEM_InstrType[2];
wire wMEM_FP2INT 	= iMEM_InstrType[2];
wire wMEM_Jalr 	= iMEM_InstrType[1];
wire wMEM_Branch 	= iMEM_InstrType[0];
wire wMEM_ULA 		= wMEM_TipoR || wMEM_TipoI;
wire wMEM_PC4		= wMEM_Jal   || wMEM_Jalr;


wire wWB_TipoFP	= iWB_InstrType[8];
wire wWB_DivRem	= iWB_InstrType[7];
wire wWB_Load 		= iWB_InstrType[6];
wire wWB_Store  	= iWB_InstrType[5];
wire wWB_TipoR  	= iWB_InstrType[4];
wire wWB_TipoRFP 	= iWB_InstrType[4];
wire wWB_TipoI  	= iWB_InstrType[3];
wire wWB_INT2FP  	= iWB_InstrType[3];
wire wWB_Jal 	 	= iWB_InstrType[2];
wire wWB_FP2INT 	= iWB_InstrType[2];
wire wWB_Jalr 		= iWB_InstrType[1];
wire wWB_Branch 	= iWB_InstrType[0];
wire wWB_ULA 		= wWB_TipoR || wWB_TipoI;
wire wWB_PC4		= wWB_Jal   || wWB_Jalr;

reg Lock;
wire iLock;

initial Lock <= 1'b0;

always @(posedge iCLK)
	Lock <= iLock;

always @(*)	// Análise de Stalls e Flushes
	begin	
		oIF_Stall 		<= 1'b0;
		oID_Stall 		<= 1'b0;
		oEX_Stall		<= 1'b0;
		oIFID_Flush  	<= 1'b0;
		oIDEX_Flush  	<= 1'b0;
		oEXMEM_Flush 	<= 1'b0;
		iLock				<=	1'b0;

//		if (wEX_DivRem && !Lock)
//		begin
//			oIF_Stall		<= 1'b1;
//			oID_Stall		<= 1'b1;
//			oEXMEM_Flush  	<= 1'b1;
//			iLock 			<=	1'b1;
//		end
//		else
		if ( (iEX_Rd !=5'b0 && wEX_Load && (
			(wID_TipoR  && (iEX_Rd ==iID_Rs1 || iEX_Rd==iID_Rs2))  ||
			(wID_TipoI  && (iEX_Rd ==iID_Rs1							))  ||  // Na verdade AUIPC e LUI não entrariam aqui
			(wID_Jalr   && (iEX_Rd ==iID_Rs1							))	 || 
			(wID_Store  && (iEX_Rd ==iID_Rs1 || iEX_Rd==iID_Rs2))  ||
			(wID_Load   && (iEX_Rd ==iID_Rs1							))	 ||
			(wID_Branch && (iEX_Rd ==iID_Rs1 || iEX_Rd==iID_Rs2))  ))    ||
			  (iMEM_Rd !=5'b0 && wMEM_Load && (
			(wID_Jalr   && (iMEM_Rd ==iID_Rs1 						  ))  ||
			(wID_Branch && (iMEM_Rd ==iID_Rs1 || iMEM_Rd==iID_Rs2))  ))   )
			begin
				oIF_Stall		<= 1'b1;
				oIDEX_Flush  	<= 1'b1;
			end
		else
		if (wID_Jal || wID_Jalr || wID_Branch && iBranch)
				oIFID_Flush  <= 1'b1;


		
	end


always @(*)  // Forwards do Controle de Branches
	begin
		oFwdRs1 	<= 3'b000;
		oFwdRs2 	<= 3'b000;
			
		// fWD Rs1
		if ((iEX_Rd!=5'b0)  && wEX_ULA  && (iEX_Rd==iID_Rs1))										// EX -> ID
			oFwdRs1 <= 3'b001;
		else
		if ((iEX_Rd!=5'b0)  && wEX_PC4  && (iEX_Rd==iID_Rs1))										// EX -> ID
			oFwdRs1 <= 3'b101;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_ULA && (iMEM_Rd==iID_Rs1))									// MEM -> ID
			oFwdRs1 <= 3'b010;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_PC4 && (iMEM_Rd==iID_Rs1))   								// MEM -> ID
			oFwdRs1 <= 3'b110;
		else
		if ((iWB_Rd!=5'b0)  && (wWB_ULA || wWB_PC4 || wWB_Load)  && (iWB_Rd==iID_Rs1))  	// WB -> ID
			oFwdRs1 <= 3'b011;
		else			
			oFwdRs1 <= 3'b000;

		// fWD Rs2
		if ((iEX_Rd!=5'b0)  && wEX_ULA  && (iEX_Rd==iID_Rs2))
			oFwdRs2 <= 3'b001;
		else
		if ((iEX_Rd!=5'b0)  && wEX_PC4  && (iEX_Rd==iID_Rs2))
			oFwdRs2 <= 3'b101;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_ULA && (iMEM_Rd==iID_Rs2))
			oFwdRs2 <= 3'b010;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_PC4 && (iMEM_Rd==iID_Rs2))
			oFwdRs2 <= 3'b110;
		else	
		if ((iWB_Rd!=5'b0)  && (wWB_ULA || wWB_PC4 || wWB_Load)  && (iWB_Rd==iID_Rs2))
			oFwdRs2 <= 3'b011;
		else
			oFwdRs2 <= 3'b000;
		
	end

	

always @(*)  // Forward da ULA
	begin
		oFwdA		<= 3'b000;
		oFwdB		<= 3'b000;
		
		// fWD A
		if ((iMEM_Rd!=5'b0) && wMEM_ULA && (iMEM_Rd==iEX_Rs1))										// MEM -> EX
			oFwdA <= 3'b010;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_PC4 && (iMEM_Rd==iEX_Rs1))										// MEM -> EX
			oFwdA <= 3'b110;			
		else	
		if ((iWB_Rd!=5'b0)  && (wWB_ULA || wWB_PC4 || wWB_Load)  && (iWB_Rd==iEX_Rs1))		// WB -> EX
			oFwdA <= 3'b011;
		else	
			oFwdA <= 3'b000; 

		// fWD B
		if ((iMEM_Rd!=5'b0) && wMEM_ULA && (iMEM_Rd==iEX_Rs2))
			oFwdB <= 3'b010;
		else
		if ((iMEM_Rd!=5'b0) && wMEM_PC4 && (iMEM_Rd==iEX_Rs2))
			oFwdB <= 3'b110;		
		else
		if ((iWB_Rd!=5'b0)  && (wWB_ULA || wWB_PC4 || wWB_Load) && (iWB_Rd==iEX_Rs2))
			oFwdB <= 3'b011;
		else			
			oFwdB <= 3'b000;
		
	end
	
endmodule
