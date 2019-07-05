
//ִ�н׶�
`include "defines.v"

module ex(

	input wire										rst,
	
	//�͵�ִ�н׶ε���Ϣ
	input wire[`AluOpBus]         aluop_i,
	//����������
	input wire[`AluSelBus]        alusel_i,
	//��������
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	//������1��2
	input wire[`RegAddrBus]       wd_i,
	//Ҫд���Ŀ�ļĴ�����ַ
	input wire                    wreg_i,
	//�Ƿ���Ҫд���Ŀ�ļĴ���

	
	output reg[`RegAddrBus]       wd_o,
	//����Ҫд���Ŀ�ļĴ�����ַ
	output reg                    wreg_o,
	//�Ƿ���Ҫд���Ŀ�ļĴ���
	output reg[`RegBus]						wdata_o
	//Ҫд���Ŀ�ļĴ�����ֵ
	
);

	//����
	reg[`RegBus] logicout;
	always @ (*) begin
		if(rst == `RstEnable) 
		begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			
				begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		
				begin
					logicout <= reg1_i & reg2_i;
				end
				default:				
				begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

//������
 always @ (*) begin
	 wd_o <= wd_i;	 	 	
	 wreg_o <= wreg_i;
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		
		begin
	 		wdata_o <= logicout;
	 	end
	 	default:					
		begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule