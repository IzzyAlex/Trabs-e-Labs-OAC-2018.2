/* Definicao do processador */
`ifndef PARAM
	`include "../Parametros.v"
`endif


module CPU (
    input  wire        iCLK, iCLK50, iRST,
    input  wire [31:0] iInitialPC,
	 
    //sinais de monitoramento
	 output wire [31:0] mPC, 
	 output wire [31:0] mInstr,
	 output wire [31:0] mDebug,
    input  wire [4:0]  mRegDispSelect,
    output wire [31:0] mRegDisp,
    output wire [5:0]  mControlState,
    input  wire [4:0]  mVGASelect,
    output wire [31:0] mVGARead,
	 output wire [31:0] mRead1,
	 output wire [31:0] mRead2,
	 output wire [31:0] mRegWrite,
	 output wire [31:0] mULA,	 
	 
    //barramentos de dados
    output wire        DwReadEnable, DwWriteEnable,
    output wire [3:0]  DwByteEnable,
    output wire [31:0] DwAddress,
    output wire [31:0] DwWriteData,
    input  wire [31:0] DwReadData,

    // barramentos de instrucoes
    output wire        IwReadEnable, IwWriteEnable,
    output wire [3:0]  IwByteEnable,
	 output wire [31:0] IwAddress,
    output wire [31:0] IwWriteData,
    input  wire [31:0] IwReadData

`ifdef PIPELINE
	 ,
	 output wire [      31:0] oiIF_PC,
	 output wire [      31:0] oiIF_Instr,
	 output wire [      31:0] oiIF_PC4,	 
	 output wire [ NIFID-1:0] oRegIFID,
	 output wire [ NIDEX-1:0] oRegIDEX,
	 output wire [NEXMEM-1:0] oRegEXMEM,
	 output wire [NMEMWB-1:0] oRegMEMWB,
	 output wire [      31:0] oWB_RegWrite
`endif
	 
    //interrupcoes
//    input wire [7:0]       iPendingInterrupt
);




/*************  UNICICLO *********************************/
`ifdef UNICICLO

assign mControlState    = 6'b000000;


// Unidade de Controle
wire    	 	 wCOrigAULA; 
wire 			 wCOrigBULA; 
wire			 wCRegWrite; 
wire			 wCMemWrite; 
wire			 wCMemRead;
wire [ 1:0]	 wCMem2Reg; 
wire [ 1:0]	 wCOrigPC;
wire [ 4:0]  wCALUControl;

 Control_UNI CONTROLE0 (
	.iInstr(wInstr), 
   .oOrigAULA(wCOrigAULA), 
	.oOrigBULA(wCOrigBULA), 
	.oRegWrite(wCRegWrite), 
	.oMemWrite(wCMemWrite), 
	.oMemRead(wCMemRead),
	.oMem2Reg(wCMem2Reg), 
	.oOrigPC(wCOrigPC),
	.oALUControl(wCALUControl)
);




// Caminho de Dados
wire [31:0]  wInstr;

Datapath_UNI DATAPATH0 (
    .iCLK(iCLK),
    .iCLK50(iCLK50),
    .iRST(iRST),
    .iInitialPC(iInitialPC),

	 // Sinais de monitoramento
    .mPC(mPC),
    .mInstr(mInstr),
    .mDebug(mDebug),
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
    .mVGASelect(mVGASelect),
    .mVGARead(mVGARead),
	 .mRead1(mRead1),
	 .mRead2(mRead2),
	 .mRegWrite(mRegWrite),
	 .mULA(mULA),

	 // Sinais do Controle
	 .wInstr(wInstr), 
    .wCOrigAULA(wCOrigAULA), 
	 .wCOrigBULA(wCOrigBULA), 
	 .wCRegWrite(wCRegWrite), 
	 .wCMemWrite(wCMemWrite), 
	 .wCMemRead(wCMemRead),
	 .wCMem2Reg(wCMem2Reg), 
	 .wCOrigPC(wCOrigPC),
	 .wCALUControl(wCALUControl),
	 
	 
    // Barramento de dados
    .DwReadEnable(DwReadEnable), .DwWriteEnable(DwWriteEnable),
    .DwByteEnable(DwByteEnable),
    .DwWriteData(DwWriteData),
    .DwReadData(DwReadData),
    .DwAddress(DwAddress),
	 
    // Barramento de instrucoes
    .IwReadEnable(IwReadEnable), .IwWriteEnable(IwWriteEnable),
    .IwByteEnable(IwByteEnable),
    .IwWriteData(IwWriteData),
    .IwReadData(IwReadData),
    .IwAddress(IwAddress)
);
 `endif

 

/*************  MULTICICLO **********************************/

`ifdef MULTICICLO

assign IwReadEnable     = OFF;
assign IwWriteEnable    = OFF;
assign IwByteEnable     = 4'b0000;
assign IwWriteData      = ZERO;
assign IwAddress        = ZERO;

assign mControlState    = wCState;


// Unidade de Controle
wire			 wCEscreveIR;
wire			 wCEscrevePC;
wire			 wCEscrevePCCond;
wire			 wCEscrevePCBack;
wire	[ 1:0] wCOrigAULA;
wire	[ 1:0] wCOrigBULA;	 
wire	[ 1:0] wCMem2Reg;
wire	[ 1:0] wCOrigPC;
wire			 wCIouD;
wire			 wCRegWrite;
wire			 wCMemWrite;
wire			 wCMemRead;
wire	[ 4:0] wCALUControl;	 
wire	[ 5:0] wCState;	
	
Control_MULTI CONTROLE0(
	.iCLK(iCLK),
	.iRST(iRST),
	.iInstr(wInstr),
	.oEscreveIR(wCEscreveIR),
	.oEscrevePC(wCEscrevePC),
	.oEscrevePCCond(wCEscrevePCCond),
	.oEscrevePCBack(wCEscrevePCBack),
   .oOrigAULA(wCOrigAULA),
   .oOrigBULA(wCOrigBULA),	 
   .oMem2Reg(wCMem2Reg),
	.oOrigPC(wCOrigPC),
	.oIouD(wCIouD),
   .oRegWrite(wCRegWrite),
   .oMemWrite(wCMemWrite),
	.oMemRead(wCMemRead),
	.oALUControl(wCALUControl),
	.oState(wCState)
	);

	


// Caminho de Dados
wire	[31:0] wInstr;
	
Datapath_MULTI DATAPATH0 (
    .iCLK(iCLK),
    .iCLK50(iCLK50),
    .iRST(iRST),
    .iInitialPC(iInitialPC),

	 // Sinais de monitoramento
    .mPC(mPC),
    .mInstr(mInstr),
    .mDebug(mDebug),
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
    .mVGASelect(mVGASelect),
    .mVGARead(mVGARead),
	 .mRead1(mRead1),
	 .mRead2(mRead2),
	 .mRegWrite(mRegWrite),
	 .mULA(mULA),

	// Sinais do Controle
	.wInstr(wInstr),
	.wCEscreveIR(wCEscreveIR),
	.wCEscrevePC(wCEscrevePC),
	.wCEscrevePCCond(wCEscrevePCCond),
	.wCEscrevePCBack(wCEscrevePCBack),
   .wCOrigAULA(wCOrigAULA),
   .wCOrigBULA(wCOrigBULA),	 
   .wCMem2Reg(wCMem2Reg),
	.wCOrigPC(wCOrigPC),
	.wCIouD(wCIouD),
   .wCRegWrite(wCRegWrite),
   .wCMemWrite(wCMemWrite),
	.wCMemRead(wCMemRead),
	.wCALUControl(wCALUControl),	 

	 
    // Barramento
    .DwWriteEnable(DwWriteEnable), .DwReadEnable(DwReadEnable),
    .DwByteEnable(DwByteEnable),
    .DwWriteData(DwWriteData),
    .DwAddress(DwAddress),
    .DwReadData(DwReadData)
	 
	 
);
`endif





/*************  PIPELINE **********************************/

`ifdef PIPELINE

assign mControlState    = 6'b111111;



// Unidade de Controle
wire        wID_CRegWrite;
wire 		   wID_COrigAULA;
wire 			wID_COrigBULA;
wire [ 1:0] wID_COrigPC;
wire [ 1:0] wID_CMem2Reg;
wire 			wID_CMemRead;
wire 			wID_CMemWrite;
wire [ 4:0] wID_CALUControl;
wire [ 7:0] wID_InstrType;

wire			wID_COrigAFPULA;
wire			wID_CData2Mem;
wire [ 5:0]	wID_CFPALUContro;
wire			wID_CFPRegWrite;


Control_PIPEM CONTROL0 (
    .iInstr(wID_Instr),
    .oOrigAULA(wID_COrigAULA),
    .oOrigBULA(wID_COrigBULA),	 
    .oMem2Reg(wID_CMem2Reg),
    .oRegWrite(wID_CRegWrite),
    .oMemWrite(wID_CMemWrite),
	 .oMemRead(wID_CMemRead),
    .oALUControl(wID_CALUControl),
    .oOrigPC(wID_COrigPC),
	 .oInstrType(wID_InstrType),
	 
	 .oOrigAFPULA(wID_COrigAFPULA),
	 .oData2Mem(wID_CData2Mem),
	 .oFPALUContro(wID_CFPALUContro),
	 .oFPRegWrite(wID_CFPRegWrite)
);


// Caminho de Dados
wire	[31:0] wID_Instr;

Datapath_PIPEM DATAPATH0 (
    .iCLK(iCLK),
    .iCLK50(iCLK50),
    .iRST(iRST),
    .iInitialPC(iInitialPC),

	  // Sinais de monitoramento
    .mPC(mPC),
    .mInstr(mInstr),
    .mDebug(mDebug),
    .mRegDispSelect(mRegDispSelect),
    .mRegDisp(mRegDisp),
    .mVGASelect(mVGASelect),
    .mVGARead(mVGARead),
	 .mRead1(mRead1),
	 .mRead2(mRead2),
	 .mRegWrite(mRegWrite),
	 .mULA(mULA),
	 

	// Sinais do Controle
    .wID_Instr(wID_Instr),
    .wID_COrigAULA(wID_COrigAULA),
    .wID_COrigBULA(wID_COrigBULA),	 
    .wID_CMem2Reg(wID_CMem2Reg),
    .wID_CRegWrite(wID_CRegWrite),
    .wID_CMemWrite(wID_CMemWrite),
	 .wID_CMemRead(wID_CMemRead),
    .wID_CALUControl(wID_CALUControl),
    .wID_COrigPC(wID_COrigPC),
	 .wID_InstrType(wID_InstrType),
	 
	 .wID_COrigAFPULA(wID_COrigAFPULA),
	 .wID_CData2Mem(wID_CData2Mem),
	 .wID_CFPALUContro(wID_CFPALUContro),
	 .wID_CFPRegWrite(wID_CFPRegWrite),

	 
    // Barramento de dados
    .DwReadEnable(DwReadEnable), .DwWriteEnable(DwWriteEnable),
    .DwByteEnable(DwByteEnable),
    .DwWriteData(DwWriteData),
    .DwReadData(DwReadData),
    .DwAddress(DwAddress),
	 
    // Barramento de instrucoes
    .IwReadEnable(IwReadEnable), .IwWriteEnable(IwWriteEnable),
    .IwByteEnable(IwByteEnable),
    .IwWriteData(IwWriteData),
    .IwReadData(IwReadData),
    .IwAddress(IwAddress),
	 
	 // Para Debug
	 .oiIF_PC(oiIF_PC),
	 .oiIF_Instr(oiIF_Instr),
	 .oiIF_PC4(oiIF_PC4),
	 .oRegIFID(oRegIFID),
	 .oRegIDEX(oRegIDEX),
	 .oRegEXMEM(oRegEXMEM),
	 .oRegMEMWB(oRegMEMWB),
	 .oWB_RegWrite(oWB_RegWrite) 

);

`endif


endmodule
