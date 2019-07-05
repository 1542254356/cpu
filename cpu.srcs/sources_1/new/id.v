
//����׶�
`include "defines.v"
/**
��ָ��������룬�õ��������ͣ������ͣ�Դ��������Ŀ�Ĳ��������������ǼĴ����Ļ���Ҫ���Ĵ���
*/

module id(

	
	input wire rst,
	input wire[`InstAddrBus] pc_i,	
	//��IF/ID��������ָ���ַ��PCֵ��
	input wire[`InstBus] inst_i,
	//��IF/ID��������ָ�����ݣ�����ָ��ROM��

	input wire[`RegBus] reg1_data_i,
	//regfileģ���һ�����ӿ����������
	input wire[`RegBus] reg2_data_i,
	//regfileģ��ڶ������ӿ����������
	
	//����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire ex_wreg_i,
	//ִ�н׶��Ƿ�Ҫд��Ŀ�ļĴ���
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,
	//Ҫд��ĵ�ַ������
	
	//���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
	input wire mem_wreg_i,
	//�ô�׶��Ƿ�Ҫд��Ŀ�ļĴ���
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,
	//Ҫд��ĵ�ַ������

	//�͵�regfile����Ϣ
	output reg reg1_read_o,
	//regfile�˿�1�ɶ�
	output reg reg2_read_o,     
	output reg[`RegAddrBus] reg1_addr_o,
	//regfile��ȡ�ĵ�ַ
	output reg[`RegAddrBus] reg2_addr_o, 	      
	
	//�͵�ִ�н׶ε���Ϣ
	output reg[`AluOpBus] aluop_o,
	//�����������
	output reg[`AluSelBus] alusel_o,
	//���������
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	//����Դ������
	output reg[`RegAddrBus] wd_o,
	//Ŀ�ļĴ�����ַ
	output reg wreg_o,
	//�Ƿ���Ҫд���
	
	output reg                    branch_flag_o,
	output reg[`RegBus]           branch_target_address_o
	//��ǰ�����ָ���ǲ������ӳٲ���
);

  wire[5:0] op = inst_i[31:26];	
  //ָ����
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  //������
  wire[4:0] op4 = inst_i[20:16];
  reg[`RegBus]	imm;
  //ָ���Ƿ���Ч
  reg instvalid;
  wire[`RegBus] pc_plus_4;
  assign pc_plus_4 = pc_i +4;
  
  wire[`RegBus] imm_sll2_signedext;  
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };
 
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			
			
	  end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;			
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			
		  case (op)
		    `EXE_SPECIAL_INST:		begin
		    	case (op2)
		    		5'b00000:			begin
		    			case (op3)
		    				//R��
		    				`EXE_AND:	
							begin
		    					wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
							end  
							//R��
							`EXE_ADD: 
							begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end	
			//I��ָ�
		  	`EXE_ORI:			
			begin                        //ORIָ��
				//��Ҫд�Ĵ���
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;
				//������ΪEXE_OR_OP
		  		alusel_o <= `EXE_RES_LOGIC;
				//����ΪEXE_RES_LOGIC
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;
				//���ʼĴ�����־
				imm <= {16'h0, inst_i[15:0]};	
				//ȡ��������
				wd_o <= inst_i[20:16];
				//ȡĿ�ļĴ���
				instvalid <= `InstValid;	
		  	end 
			//I��ָ�
			`EXE_ADDI:			
			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			//J��ָ��
			`EXE_J:			
			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	
				reg2_read_o <= 1'b0;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			   
			    instvalid <= `InstValid;	
			end
			//I��ָ��
			`EXE_BEQ:			
			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b1;
		  		instvalid <= `InstValid;	
		  		if(reg1_o == reg2_o) 
				begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    		  	
			    end
				end
			
		    default:			
			begin
				
		    end
		  endcase		  //case op			
		end       //if
	end         //always
	

	//���Ĵ���
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
	  end  else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;	
		//��Ҫ���ʼĴ�����ȡ�Ĵ���ֵ
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;			
		//������ֱ�Ӹ�ֵ
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
	  end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			//Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд�ļĴ�����ֱ�Ӱ�ִ�н׶ε�ֵex_wdata_i��Ϊreg1_o��ֵ
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			//���Ҫ��ȡ�ļĴ�����ִ�н׶�Ҫд��ļĴ�����ֱ�ӽ��ô�Ľ��mem_wdata_i��Ϊreg1_o��ֵ
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

endmodule