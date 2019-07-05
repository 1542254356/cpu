
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
	output reg wreg_o,
	//�Ƿ���Ҫд���Ŀ�ļĴ���
	output reg[`RegBus] wdata_o
	//Ҫд���Ŀ�ļĴ�����ֵ
	
);

	reg[`RegBus] arithmeticres;
	///����������
	wire ov_sum;
	//�Ƿ����
	wire[`RegBus] result_sum;
	//�ӷ��Ľ��

	wire[`RegBus] reg1_i_not;
	//��һ��������ȡ��
	
	

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
	
		always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADD_OP, `EXE_ADDI_OP:		
				begin
					arithmeticres <= result_sum; 
				end
				
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end
	
	assign reg1_i_not = ~reg1_i;
	
	assign result_sum = reg1_i + reg2_i;		
	
	//�ж��Ƿ�����������ӵø������������ӵ���
	assign ov_sum = ((!reg1_i[31] && !reg2_i[31]) && result_sum[31]) ||
									((reg1_i[31] && reg2_i[31]) && (!result_sum[31]));  

//������
 always @ (*) 
 begin
	 wd_o <= wd_i;	 
	 
	 //�����д��Ŀ�ļĴ���
	 if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP)) 
	 && (ov_sum == 1'b1)) 
	 begin
	 	wreg_o <= `WriteDisable;
	 end else 
	 begin
	  wreg_o <= wreg_i;
	 end
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		
		begin
	 		wdata_o <= logicout;
	 	end
		`EXE_RES_ARITHMETIC:	
		begin
	 		wdata_o <= arithmeticres;
	 	end
	 	default:					
		begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule